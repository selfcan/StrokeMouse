import Foundation

actor GitHubGistBackupAdapter: BackupRemoteAdapter {
    nonisolated let providerID = BackupRemoteProviderID.githubGist

    static let fixedFileName = "strokemouse-backup.json"
    static let apiVersion = "2026-03-10"

    private let personalAccessToken: String
    private let session: URLSession
    private let sessionDelegate: BackupURLSessionDelegate?
    private var gistID: String?

    init(
        personalAccessToken: String,
        gistID: String? = nil,
        session: URLSession? = nil
    ) throws {
        let token = personalAccessToken.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !token.isEmpty else {
            throw BackupRemoteError.invalidConfiguration(
                "A GitHub personal access token is required."
            )
        }
        if let gistID, !Self.isValidIdentifier(gistID) {
            throw BackupRemoteError.invalidConfiguration(
                "The configured Gist identifier is invalid."
            )
        }

        self.personalAccessToken = token
        self.gistID = gistID
        if let session {
            self.session = session
            sessionDelegate = nil
        } else {
            let delegate = BackupURLSessionDelegate()
            self.session = BackupHTTP.ephemeralSession(delegate: delegate)
            sessionDelegate = delegate
        }
    }

    func validateConnection() async throws {
        let url: URL
        if let gistID {
            url = try endpoint(pathComponents: ["gists", gistID])
        } else {
            url = try endpoint(pathComponents: ["user"])
        }
        let (data, response) = try await send(request(url: url))
        try BackupHTTP.requireStatus(response, allowed: [200])
        try enforceResponseSize(data)
    }

    func storeBackup(
        _ data: Data,
        createdAt: Date
    ) async throws -> RemoteBackupID {
        try enforcePayloadSize(data)
        guard let content = String(data: data, encoding: .utf8) else {
            throw BackupRemoteError.invalidPayload(
                "GitHub Gist backups must contain valid UTF-8 data."
            )
        }

        let targetGistID = gistID
        let url: URL
        let method: String
        if let targetGistID {
            url = try endpoint(pathComponents: ["gists", targetGistID])
            method = "PATCH"
        } else {
            url = try endpoint(pathComponents: ["gists"])
            method = "POST"
        }

        let description = "StrokeMouse configuration backup"
        let files = [Self.fixedFileName: GistWriteFile(content: content)]
        var request = request(url: url, method: method)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if targetGistID == nil {
            request.httpBody = try JSONEncoder().encode(GistCreateRequest(
                description: description,
                isPublic: false,
                files: files
            ))
        } else {
            request.httpBody = try JSONEncoder().encode(GistUpdateRequest(
                description: description,
                files: files
            ))
        }

        let (responseData, response) = try await send(request)
        try BackupHTTP.requireStatus(response, allowed: [200, 201])
        try enforceResponseSize(responseData)
        let result = try decode(GistResponse.self, from: responseData)
        guard Self.isValidIdentifier(result.id),
              let revision = result.history?.first?.version,
              Self.isValidIdentifier(revision)
        else {
            throw BackupRemoteError.invalidResponse(
                "GitHub did not return a valid Gist revision."
            )
        }

        gistID = result.id
        let backupID = RemoteBackupID(
            providerID: providerID,
            containerID: result.id,
            revisionID: revision
        )
        let verified = try await fetchBackup(backupID)
        guard verified == data else {
            throw BackupRemoteError.invalidResponse(
                "GitHub Gist upload verification did not match the stored revision."
            )
        }
        return backupID
    }

    func listHistory(
        _ query: BackupHistoryQuery
    ) async throws -> BackupHistoryPage {
        try BackupHTTP.validateHistoryQuery(query)
        let gistID = try requiredGistID()
        let page = try pageNumber(from: query.cursor)
        var components = URLComponents(
            url: try endpoint(pathComponents: ["gists", gistID, "commits"]),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "per_page", value: String(query.limit)),
            URLQueryItem(name: "page", value: String(page)),
        ]
        guard let url = components?.url else {
            throw BackupRemoteError.invalidConfiguration(
                "Could not construct the GitHub history URL."
            )
        }

        let (data, response) = try await send(request(url: url))
        try BackupHTTP.requireStatus(response, allowed: [200])
        try enforceResponseSize(data)
        let commits = try decode([GistCommit].self, from: data)
        let backups = try commits.map { commit in
            guard Self.isValidIdentifier(commit.version) else {
                throw BackupRemoteError.invalidResponse(
                    "GitHub returned an invalid Gist revision identifier."
                )
            }
            return BackupSummary(
                id: RemoteBackupID(
                    providerID: providerID,
                    containerID: gistID,
                    revisionID: commit.version
                ),
                createdAt: commit.committedAt,
                byteCount: nil
            )
        }
        return BackupHistoryPage(
            backups: backups,
            nextCursor: commits.count == query.limit ? String(page + 1) : nil
        )
    }

    func fetchBackup(_ id: RemoteBackupID) async throws -> Data {
        let gistID = try validate(id: id)
        let url = try endpoint(
            pathComponents: ["gists", gistID, id.revisionID]
        )
        let (data, response) = try await send(request(url: url))
        try BackupHTTP.requireStatus(response, allowed: [200])
        try enforceResponseSize(data)
        let gist = try decode(GistResponse.self, from: data)
        guard gist.id == gistID,
              let file = gist.files?[Self.fixedFileName]
        else {
            throw BackupRemoteError.notFound
        }
        if let size = file.size,
           size > BackupRemoteLimits.maximumPayloadByteCount
        {
            throw BackupRemoteError.payloadTooLarge(
                limit: BackupRemoteLimits.maximumPayloadByteCount,
                actual: size
            )
        }
        if file.truncated == true {
            guard let rawURL = file.rawURL else {
                throw BackupRemoteError.invalidResponse(
                    "GitHub omitted the raw URL for a truncated Gist file."
                )
            }
            return try await fetchRawFile(from: rawURL)
        }
        guard let content = file.content,
              let contentData = content.data(using: .utf8)
        else {
            throw BackupRemoteError.invalidResponse(
                "GitHub omitted the fixed backup file content."
            )
        }
        try enforcePayloadSize(contentData)
        return contentData
    }

    private func fetchRawFile(from url: URL) async throws -> Data {
        guard url.scheme?.lowercased() == "https",
              url.host?.lowercased() == "gist.githubusercontent.com",
              url.user == nil,
              url.password == nil
        else {
            throw BackupRemoteError.invalidResponse(
                "GitHub returned an invalid raw Gist URL."
            )
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Accept")
        let (data, response) = try await BackupHTTP.data(
            for: request,
            session: session
        )
        try BackupHTTP.requireStatus(response, allowed: [200])
        try enforcePayloadSize(data)
        return data
    }

    private func send(
        _ request: URLRequest
    ) async throws -> (Data, HTTPURLResponse) {
        try await BackupHTTP.data(for: request, session: session)
    }

    private func request(
        url: URL,
        method: String = "GET"
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(
            "application/vnd.github+json",
            forHTTPHeaderField: "Accept"
        )
        request.setValue(
            "Bearer \(personalAccessToken)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue(Self.apiVersion, forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("StrokeMouse", forHTTPHeaderField: "User-Agent")
        return request
    }

    private func endpoint(pathComponents: [String]) throws -> URL {
        var url = Self.apiBaseURL
        for component in pathComponents {
            guard component == "gists"
                    || component == "commits"
                    || component == "user"
                    || Self.isValidIdentifier(component)
            else {
                throw BackupRemoteError.invalidConfiguration(
                    "A GitHub path identifier is invalid."
                )
            }
            url.appendPathComponent(component)
        }
        return url
    }

    private func requiredGistID() throws -> String {
        guard let gistID else {
            throw BackupRemoteError.notConfigured(
                "Create a Gist backup before requesting its history."
            )
        }
        return gistID
    }

    private func validate(id: RemoteBackupID) throws -> String {
        let configuredGistID = try requiredGistID()
        guard id.providerID == providerID,
              id.containerID == configuredGistID,
              Self.isValidIdentifier(id.revisionID)
        else {
            throw BackupRemoteError.invalidConfiguration(
                "The remote backup identifier does not belong to this Gist."
            )
        }
        return configuredGistID
    }

    private func pageNumber(from cursor: String?) throws -> Int {
        guard let cursor else { return 1 }
        guard let page = Int(cursor), page > 0 else {
            throw BackupRemoteError.invalidQuery(
                "The GitHub history cursor is invalid."
            )
        }
        return page
    }

    private func enforcePayloadSize(_ data: Data) throws {
        guard data.count <= BackupRemoteLimits.maximumPayloadByteCount else {
            throw BackupRemoteError.payloadTooLarge(
                limit: BackupRemoteLimits.maximumPayloadByteCount,
                actual: data.count
            )
        }
    }

    private func enforceResponseSize(_ data: Data) throws {
        try enforcePayloadSize(data)
    }

    private func decode<Value: Decodable>(
        _ type: Value.Type,
        from data: Data
    ) throws -> Value {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
            return try decoder.decode(type, from: data)
        } catch let error as BackupRemoteError {
            throw error
        } catch {
            throw BackupRemoteError.invalidResponse(
                "GitHub returned malformed Gist metadata."
            )
        }
    }

    private static func isValidIdentifier(_ value: String) -> Bool {
        !value.isEmpty && value.unicodeScalars.allSatisfy {
            CharacterSet.alphanumerics.contains($0)
        }
    }

    private static let apiBaseURL = URL(string: "https://api.github.com")!
}

private struct GistCreateRequest: Encodable {
    let description: String
    let isPublic: Bool
    let files: [String: GistWriteFile]

    private enum CodingKeys: String, CodingKey {
        case description
        case isPublic = "public"
        case files
    }
}

private struct GistUpdateRequest: Encodable {
    let description: String
    let files: [String: GistWriteFile]
}

private struct GistWriteFile: Encodable {
    let content: String
}

private struct GistResponse: Decodable {
    let id: String
    let files: [String: GistFile]?
    let history: [GistHistory]?
}

private struct GistHistory: Decodable {
    let version: String
}

private struct GistFile: Decodable {
    let size: Int?
    let truncated: Bool?
    let content: String?
    let rawURL: URL?

    private enum CodingKeys: String, CodingKey {
        case size
        case truncated
        case content
        case rawURL = "raw_url"
    }
}

private struct GistCommit: Decodable {
    let version: String
    let committedAt: Date

    private enum CodingKeys: String, CodingKey {
        case version
        case committedAt = "committed_at"
    }
}

private extension JSONDecoder.DateDecodingStrategy {
    static let iso8601WithFractionalSeconds = custom { decoder in
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: value) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: value) {
            return date
        }
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Invalid ISO-8601 date"
        )
    }
}
