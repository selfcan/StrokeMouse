import Foundation

struct RemoteBackupID: Codable, Equatable, Hashable, Sendable {
    let providerID: String
    let containerID: String
    let revisionID: String

    init(providerID: String, containerID: String, revisionID: String) {
        self.providerID = providerID
        self.containerID = containerID
        self.revisionID = revisionID
    }
}

struct BackupHistoryQuery: Equatable, Sendable {
    var cursor: String?
    var limit: Int

    init(cursor: String? = nil, limit: Int = 50) {
        self.cursor = cursor
        self.limit = limit
    }
}

struct BackupHistoryPage: Equatable, Sendable {
    let backups: [BackupSummary]
    let nextCursor: String?
}

struct BackupSummary: Equatable, Sendable {
    let id: RemoteBackupID
    let createdAt: Date
    let byteCount: Int?
}

protocol BackupRemoteAdapter: Sendable {
    var providerID: String { get }

    func validateConnection() async throws
    func storeBackup(_ data: Data, createdAt: Date) async throws -> RemoteBackupID
    func listHistory(_ query: BackupHistoryQuery) async throws -> BackupHistoryPage
    func fetchBackup(_ id: RemoteBackupID) async throws -> Data
}

enum BackupRemoteProviderID {
    static let githubGist = "github-gist"
    static let webDAV = "webdav"
}

enum BackupRemoteLimits {
    static let maximumPayloadByteCount = 10 * 1_024 * 1_024
    static let maximumHistoryPageSize = 100
}

enum BackupRemoteError: Error, Equatable, LocalizedError, Sendable {
    case invalidConfiguration(String)
    case invalidQuery(String)
    case notConfigured(String)
    case invalidPayload(String)
    case payloadTooLarge(limit: Int, actual: Int)
    case authenticationRequired
    case forbidden
    case notFound
    case conflict
    case rateLimited(retryAfter: TimeInterval?)
    case unsupportedServer(String)
    case unsafeRedirect
    case invalidResponse(String)
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .invalidConfiguration(let message),
             .invalidQuery(let message),
             .notConfigured(let message),
             .invalidPayload(let message),
             .unsupportedServer(let message),
             .invalidResponse(let message),
             .transport(let message):
            return message
        case .payloadTooLarge(let limit, let actual):
            return "Backup payload is \(actual) bytes; the limit is \(limit) bytes."
        case .authenticationRequired:
            return "The backup server rejected the configured credentials."
        case .forbidden:
            return "The backup server denied this operation."
        case .notFound:
            return "The requested remote backup was not found."
        case .conflict:
            return "The remote backup changed or already exists."
        case .rateLimited(let retryAfter):
            guard let retryAfter else {
                return "The backup provider rate-limited this request."
            }
            return "The backup provider rate-limited this request; retry after \(Int(retryAfter)) seconds."
        case .unsafeRedirect:
            return "The backup provider attempted an unsafe redirect."
        }
    }
}

final class BackupURLSessionDelegate: NSObject, URLSessionTaskDelegate,
    @unchecked Sendable
{
    private let credentialHost: String?
    private let credential: URLCredential?

    init(credentialHost: String? = nil, credential: URLCredential? = nil) {
        self.credentialHost = credentialHost?.lowercased()
        self.credential = credential
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping @Sendable (
            URLSession.AuthChallengeDisposition,
            URLCredential?
        ) -> Void
    ) {
        let protectionSpace = challenge.protectionSpace
        let method = protectionSpace.authenticationMethod
        let supported = method == NSURLAuthenticationMethodHTTPBasic
            || method == NSURLAuthenticationMethodHTTPDigest
        guard supported,
              !protectionSpace.isProxy(),
              challenge.previousFailureCount == 0,
              protectionSpace.host.lowercased() == credentialHost,
              let credential
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        completionHandler(.useCredential, credential)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping @Sendable (URLRequest?) -> Void
    ) {
        guard let sourceURL = task.currentRequest?.url
            ?? task.originalRequest?.url,
              let targetURL = request.url,
              BackupHTTP.isSafeRedirect(from: sourceURL, to: targetURL)
        else {
            completionHandler(nil)
            return
        }
        completionHandler(request)
    }
}

enum BackupHTTP {
    static func ephemeralSession(delegate: URLSessionDelegate) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        return URLSession(
            configuration: configuration,
            delegate: delegate,
            delegateQueue: nil
        )
    }

    static func data(
        for request: URLRequest,
        session: URLSession
    ) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BackupRemoteError.invalidResponse(
                    "The backup provider returned a non-HTTP response."
                )
            }
            guard let requestURL = request.url,
                  let responseURL = httpResponse.url,
                  isSafeRedirect(from: requestURL, to: responseURL)
            else {
                throw BackupRemoteError.unsafeRedirect
            }
            return (data, httpResponse)
        } catch let error as BackupRemoteError {
            throw error
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw BackupRemoteError.transport(error.localizedDescription)
        }
    }

    static func requireStatus(
        _ response: HTTPURLResponse,
        allowed: Set<Int>
    ) throws {
        guard allowed.contains(response.statusCode) else {
            throw statusError(for: response)
        }
    }

    static func statusError(for response: HTTPURLResponse) -> BackupRemoteError {
        switch response.statusCode {
        case 300...399:
            return .unsafeRedirect
        case 401, 407:
            return .authenticationRequired
        case 403:
            if response.value(forHTTPHeaderField: "X-RateLimit-Remaining") == "0"
                || response.value(forHTTPHeaderField: "Retry-After") != nil
            {
                let retryAfter = response.value(
                    forHTTPHeaderField: "Retry-After"
                ).flatMap(TimeInterval.init)
                return .rateLimited(retryAfter: retryAfter)
            }
            return .forbidden
        case 404:
            return .notFound
        case 409, 412:
            return .conflict
        case 413:
            return .payloadTooLarge(
                limit: BackupRemoteLimits.maximumPayloadByteCount,
                actual: BackupRemoteLimits.maximumPayloadByteCount + 1
            )
        case 429:
            let retryAfter = response.value(forHTTPHeaderField: "Retry-After")
                .flatMap(TimeInterval.init)
            return .rateLimited(retryAfter: retryAfter)
        default:
            return .invalidResponse(
                "The backup provider returned HTTP \(response.statusCode)."
            )
        }
    }

    static func isSafeRedirect(from source: URL, to target: URL) -> Bool {
        guard target.user == nil,
              target.password == nil,
              let sourceHost = source.host?.lowercased(),
              let targetHost = target.host?.lowercased(),
              sourceHost == targetHost
        else {
            return false
        }

        let sourceScheme = source.scheme?.lowercased()
        let targetScheme = target.scheme?.lowercased()
        guard sourceScheme == "http" || sourceScheme == "https",
              targetScheme == "http" || targetScheme == "https"
        else { return false }
        if sourceScheme == "https", targetScheme != "https" {
            return false
        }
        if sourceScheme == targetScheme {
            return effectivePort(for: source) == effectivePort(for: target)
        }
        return sourceScheme == "http" && targetScheme == "https"
    }

    static func validateHistoryQuery(_ query: BackupHistoryQuery) throws {
        guard (1...BackupRemoteLimits.maximumHistoryPageSize).contains(query.limit) else {
            throw BackupRemoteError.invalidQuery(
                "History page size must be between 1 and \(BackupRemoteLimits.maximumHistoryPageSize)."
            )
        }
    }

    private static func effectivePort(for url: URL) -> Int? {
        if let port = url.port { return port }
        switch url.scheme?.lowercased() {
        case "http": return 80
        case "https": return 443
        default: return nil
        }
    }
}
