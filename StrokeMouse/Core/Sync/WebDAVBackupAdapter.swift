import Foundation

final class WebDAVBackupAdapter: BackupRemoteAdapter, @unchecked Sendable {
    let providerID = BackupRemoteProviderID.webDAV

    private let accountBaseURL: URL
    private let backupRootURL: URL
    private let containerID: String
    private let session: URLSession
    private let sessionDelegate: BackupURLSessionDelegate?

    init(
        baseURL: URL,
        username: String,
        password: String,
        session: URLSession? = nil
    ) throws {
        let normalizedURL = try Self.normalizedBaseURL(baseURL)
        let backupRootURL = normalizedURL.appendingPathComponent(
            Self.backupRootDirectoryName,
            isDirectory: true
        )
        let trimmedUsername = username.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmedUsername.isEmpty else {
            throw BackupRemoteError.invalidConfiguration(
                "A WebDAV username is required."
            )
        }
        guard !password.isEmpty else {
            throw BackupRemoteError.invalidConfiguration(
                "A WebDAV password is required."
            )
        }

        accountBaseURL = normalizedURL
        self.backupRootURL = backupRootURL
        containerID = backupRootURL.absoluteString
        if let session {
            self.session = session
            sessionDelegate = nil
        } else {
            let credential = URLCredential(
                user: trimmedUsername,
                password: password,
                persistence: .forSession
            )
            let delegate = BackupURLSessionDelegate(
                credentialHost: normalizedURL.host,
                credential: credential
            )
            self.session = BackupHTTP.ephemeralSession(delegate: delegate)
            sessionDelegate = delegate
        }
    }

    func validateConnection() async throws {
        let (_, response) = try await send(
            request(url: accountBaseURL, method: "OPTIONS")
        )
        try BackupHTTP.requireStatus(response, allowed: [200, 204])
        guard let dav = response.value(forHTTPHeaderField: "DAV"),
              !dav.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            throw BackupRemoteError.unsupportedServer(
                "The configured server did not advertise WebDAV support."
            )
        }
        var accessRequest = request(url: accountBaseURL, method: "PROPFIND")
        accessRequest.setValue("0", forHTTPHeaderField: "Depth")
        accessRequest.setValue(
            "application/xml; charset=utf-8",
            forHTTPHeaderField: "Content-Type"
        )
        accessRequest.httpBody = Data(Self.propfindBody.utf8)
        let (data, accessResponse) = try await send(accessRequest)
        try BackupHTTP.requireStatus(accessResponse, allowed: [207])
        try enforceSize(data)
    }

    func storeBackup(
        _ data: Data,
        createdAt: Date
    ) async throws -> RemoteBackupID {
        try enforceSize(data)
        let envelope: BackupEnvelopeV1
        do {
            envelope = try BackupCodec.decodeEnvelope(from: data)
        } catch {
            throw BackupRemoteError.invalidPayload(
                "The WebDAV backup is not a valid StrokeMouse backup envelope."
            )
        }
        guard Self.sameEnvelopeSecond(envelope.createdAt, createdAt) else {
            throw BackupRemoteError.invalidPayload(
                "The supplied backup date does not match the backup envelope."
            )
        }
        try await validateConnection()

        let path = backupPath(envelope: envelope)
        let components = path.split(separator: "/").map(String.init)
        let yearURL = backupRootURL.appendingPathComponent(components[0], isDirectory: true)
        let monthURL = yearURL.appendingPathComponent(components[1], isDirectory: true)
        try await ensureCollection(at: backupRootURL)
        try await ensureCollection(at: yearURL)
        try await ensureCollection(at: monthURL)

        let backupURL = monthURL.appendingPathComponent(components[2])
        var put = request(url: backupURL, method: "PUT")
        put.setValue("application/json", forHTTPHeaderField: "Content-Type")
        put.setValue("*", forHTTPHeaderField: "If-None-Match")
        put.httpBody = data
        let (responseData, response) = try await send(put)
        try BackupHTTP.requireStatus(response, allowed: [201, 204])
        try enforceSize(responseData)
        return RemoteBackupID(
            providerID: providerID,
            containerID: containerID,
            revisionID: path
        )
    }

    func listHistory(
        _ query: BackupHistoryQuery
    ) async throws -> BackupHistoryPage {
        try BackupHTTP.validateHistoryQuery(query)
        let cursor = try historyCursor(from: query.cursor)
        guard let directoryIndex = try await monthDirectoryIndex() else {
            return BackupHistoryPage(backups: [], nextCursor: nil)
        }
        guard cursor.monthIndex <= directoryIndex.monthURLs.count,
              cursor.monthIndex < directoryIndex.monthURLs.count
                || cursor.offset == 0
        else {
            throw BackupRemoteError.invalidQuery(
                "The WebDAV history cursor is out of range."
            )
        }

        var metadataByteCount = directoryIndex.metadataByteCount
        var backups: [BackupSummary] = []
        var monthIndex = cursor.monthIndex
        var monthOffset = cursor.offset
        while monthIndex < directoryIndex.monthURLs.count {
            let monthURL = directoryIndex.monthURLs[monthIndex]
            let month = try await propfind(monthURL)
            try addMetadataBytes(month.byteCount, total: &metadataByteCount)
            let monthBackups = try backupSummaries(
                in: month.resources,
                monthURL: monthURL
            ).sorted(by: Self.isNewerBackup)
            guard monthOffset <= monthBackups.count else {
                throw BackupRemoteError.invalidQuery(
                    "The WebDAV history cursor is out of range."
                )
            }

            let remaining = query.limit - backups.count
            let end = min(monthOffset + remaining, monthBackups.count)
            backups.append(contentsOf: monthBackups[monthOffset..<end])
            if end < monthBackups.count {
                return BackupHistoryPage(
                    backups: backups,
                    nextCursor: try encodeHistoryCursor(
                        monthIndex: monthIndex,
                        offset: end
                    )
                )
            }

            monthIndex += 1
            monthOffset = 0
            if backups.count == query.limit {
                let nextCursor = monthIndex < directoryIndex.monthURLs.count
                    ? try encodeHistoryCursor(monthIndex: monthIndex, offset: 0)
                    : nil
                return BackupHistoryPage(
                    backups: backups,
                    nextCursor: nextCursor
                )
            }
        }
        return BackupHistoryPage(backups: backups, nextCursor: nil)
    }

    func fetchBackup(_ id: RemoteBackupID) async throws -> Data {
        let path = try validate(id: id)
        guard let expected = Self.metadataFromBackupPath(path) else {
            throw BackupRemoteError.invalidConfiguration(
                "The WebDAV backup identifier is invalid."
            )
        }
        var url = backupRootURL
        for component in path.split(separator: "/") {
            url.appendPathComponent(String(component))
        }
        let (data, response) = try await send(request(url: url, method: "GET"))
        try BackupHTTP.requireStatus(response, allowed: [200])
        try enforceSize(data)
        let envelope: BackupEnvelopeV1
        do {
            envelope = try BackupCodec.decodeEnvelope(from: data)
        } catch {
            throw BackupRemoteError.invalidPayload(
                "The WebDAV file is not a valid StrokeMouse backup envelope."
            )
        }
        guard envelope.snapshotID == expected.snapshotID,
              envelope.deviceID == expected.deviceID,
              Self.sameEnvelopeSecond(envelope.createdAt, expected.createdAt)
        else {
            throw BackupRemoteError.invalidPayload(
                "The WebDAV file identity does not match its backup path."
            )
        }
        return data
    }

    private func ensureCollection(at url: URL) async throws {
        let (data, response) = try await send(request(url: url, method: "MKCOL"))
        try enforceSize(data)
        try BackupHTTP.requireStatus(response, allowed: [201, 405])
    }

    private func propfind(_ url: URL) async throws -> WebDAVListing {
        var request = request(url: url, method: "PROPFIND")
        request.setValue("1", forHTTPHeaderField: "Depth")
        request.setValue(
            "application/xml; charset=utf-8",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = Data(Self.propfindBody.utf8)
        let (data, response) = try await send(request)
        try BackupHTTP.requireStatus(response, allowed: [207])
        try enforceSize(data)
        return WebDAVListing(
            resources: try WebDAVMultiStatusParser.parse(
                data,
                requestURL: url,
                baseURL: backupRootURL
            ),
            byteCount: data.count
        )
    }

    private func monthDirectoryIndex() async throws -> WebDAVMonthDirectoryIndex? {
        let root: WebDAVListing
        do {
            root = try await propfind(backupRootURL)
        } catch BackupRemoteError.notFound {
            return nil
        }
        var metadataByteCount = root.byteCount
        let years = childCollections(in: root.resources, of: backupRootURL)
            .filter { Self.isYear($0.lastPathComponent) }
            .sorted { $0.lastPathComponent > $1.lastPathComponent }
        var monthURLs: [URL] = []
        for yearURL in years {
            let year = try await propfind(yearURL)
            try addMetadataBytes(year.byteCount, total: &metadataByteCount)
            monthURLs.append(contentsOf:
                childCollections(in: year.resources, of: yearURL)
                    .filter { Self.isMonth($0.lastPathComponent) }
                    .sorted { $0.lastPathComponent > $1.lastPathComponent }
            )
        }
        return WebDAVMonthDirectoryIndex(
            monthURLs: monthURLs,
            metadataByteCount: metadataByteCount
        )
    }

    private func backupSummaries(
        in resources: [WebDAVResource],
        monthURL: URL
    ) throws -> [BackupSummary] {
        try resources.compactMap { resource in
            guard !resource.isCollection,
                  isDirectChild(resource.url, of: monthURL),
                  resource.url.lastPathComponent.hasSuffix(Self.backupFileExtension)
            else {
                return nil
            }
            let relativePath = try relativePath(for: resource.url)
            guard let filenameMetadata = Self.metadataFromBackupPath(
                relativePath
            ) else { return nil }
            return BackupSummary(
                id: RemoteBackupID(
                    providerID: providerID,
                    containerID: containerID,
                    revisionID: relativePath
                ),
                createdAt: filenameMetadata.createdAt,
                byteCount: resource.byteCount
            )
        }
    }

    private func childCollections(
        in resources: [WebDAVResource],
        of parent: URL
    ) -> [URL] {
        resources.compactMap { resource in
            guard resource.isCollection,
                  isDirectChild(resource.url, of: parent)
            else { return nil }
            return resource.url
        }
    }

    private func isDirectChild(_ child: URL, of parent: URL) -> Bool {
        guard BackupHTTP.isSafeRedirect(from: backupRootURL, to: child) else {
            return false
        }
        let parentPath = Self.directoryPath(parent.path)
        guard child.path.hasPrefix(parentPath) else { return false }
        let remainder = child.path.dropFirst(parentPath.count)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return !remainder.isEmpty && !remainder.contains("/")
    }

    private func relativePath(for url: URL) throws -> String {
        let basePath = Self.directoryPath(backupRootURL.path)
        guard BackupHTTP.isSafeRedirect(from: backupRootURL, to: url),
              url.path.hasPrefix(basePath)
        else {
            throw BackupRemoteError.invalidResponse(
                "The WebDAV server returned a resource outside the configured backup directory."
            )
        }
        return String(url.path.dropFirst(basePath.count))
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    private func validate(id: RemoteBackupID) throws -> String {
        guard id.providerID == providerID,
              id.containerID == containerID,
              Self.isValidBackupPath(id.revisionID)
        else {
            throw BackupRemoteError.invalidConfiguration(
                "The remote backup identifier does not belong to this WebDAV directory."
            )
        }
        return id.revisionID
    }

    private func historyCursor(
        from encodedCursor: String?
    ) throws -> WebDAVHistoryCursor {
        guard let encodedCursor else { return .initial }
        guard !encodedCursor.isEmpty,
              encodedCursor.count <= Self.maximumHistoryCursorLength,
              encodedCursor.unicodeScalars.allSatisfy(
                Self.historyCursorCharacterSet.contains
              )
        else { throw Self.invalidHistoryCursorError }

        var base64 = encodedCursor
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)
        guard let data = Data(base64Encoded: base64),
              let cursor = try? JSONDecoder().decode(
                WebDAVHistoryCursor.self,
                from: data
              ),
              cursor.version == WebDAVHistoryCursor.currentVersion,
              cursor.monthIndex >= 0,
              cursor.offset >= 0
        else { throw Self.invalidHistoryCursorError }
        return cursor
    }

    private func encodeHistoryCursor(
        monthIndex: Int,
        offset: Int
    ) throws -> String {
        let cursor = WebDAVHistoryCursor(
            version: WebDAVHistoryCursor.currentVersion,
            monthIndex: monthIndex,
            offset: offset
        )
        let data: Data
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            data = try encoder.encode(cursor)
        } catch {
            throw BackupRemoteError.invalidResponse(
                "Could not encode the WebDAV history cursor."
            )
        }
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private func addMetadataBytes(_ count: Int, total: inout Int) throws {
        total += count
        guard total <= BackupRemoteLimits.maximumPayloadByteCount else {
            throw BackupRemoteError.payloadTooLarge(
                limit: BackupRemoteLimits.maximumPayloadByteCount,
                actual: total
            )
        }
    }

    private func backupPath(envelope: BackupEnvelopeV1) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(
            in: TimeZone(secondsFromGMT: 0)!,
            from: envelope.createdAt
        )
        let year = String(format: "%04d", components.year ?? 0)
        let month = String(format: "%02d", components.month ?? 0)
        let filename = [
            Self.sanitizedDeviceName(envelope.deviceName),
            envelope.deviceID.uuidString.lowercased(),
            Self.backupDateFormatter.string(from: envelope.createdAt),
            envelope.snapshotID.uuidString.lowercased(),
        ].joined(separator: Self.filenameSeparator) + Self.backupFileExtension
        return "\(year)/\(month)/\(filename)"
    }

    private func request(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("StrokeMouse", forHTTPHeaderField: "User-Agent")
        return request
    }

    private func send(
        _ request: URLRequest
    ) async throws -> (Data, HTTPURLResponse) {
        let result = try await BackupHTTP.data(for: request, session: session)
        try enforceSize(result.0)
        return result
    }

    private func enforceSize(_ data: Data) throws {
        guard data.count <= BackupRemoteLimits.maximumPayloadByteCount else {
            throw BackupRemoteError.payloadTooLarge(
                limit: BackupRemoteLimits.maximumPayloadByteCount,
                actual: data.count
            )
        }
    }

    private static func normalizedBaseURL(_ url: URL) throws -> URL {
        guard let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              url.host != nil,
              url.user == nil,
              url.password == nil,
              url.query == nil,
              url.fragment == nil
        else {
            throw BackupRemoteError.invalidConfiguration(
                "The WebDAV URL must use HTTP or HTTPS and must not contain credentials, a query, or a fragment."
            )
        }
        var components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )
        guard var path = components?.percentEncodedPath else {
            throw BackupRemoteError.invalidConfiguration(
                "The WebDAV URL is invalid."
            )
        }
        if !path.hasSuffix("/") { path += "/" }
        components?.percentEncodedPath = path
        guard let normalized = components?.url else {
            throw BackupRemoteError.invalidConfiguration(
                "The WebDAV URL is invalid."
            )
        }
        return normalized
    }

    fileprivate static func directoryPath(_ path: String) -> String {
        path.hasSuffix("/") ? path : path + "/"
    }

    private static func isYear(_ value: String) -> Bool {
        value.count == 4 && value.allSatisfy(\.isNumber)
    }

    private static func isMonth(_ value: String) -> Bool {
        guard value.count == 2,
              value.allSatisfy(\.isNumber),
              let month = Int(value)
        else { return false }
        return (1...12).contains(month)
    }

    private static func isValidBackupPath(_ path: String) -> Bool {
        metadataFromBackupPath(path) != nil
    }

    private static func metadataFromBackupPath(
        _ path: String
    ) -> WebDAVFilenameMetadata? {
        let components = path.split(separator: "/", omittingEmptySubsequences: false)
        guard components.count == 3,
              isYear(String(components[0])),
              isMonth(String(components[1])),
              !components[2].isEmpty,
              String(components[2]).hasSuffix(backupFileExtension),
              !path.contains("\\")
        else { return nil }
        guard let metadata = metadataFromBackupFileName(String(components[2])) else {
            return nil
        }
        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = calendar.dateComponents(
            in: TimeZone(secondsFromGMT: 0)!,
            from: metadata.createdAt
        )
        guard Int(components[0]) == dateComponents.year,
              Int(components[1]) == dateComponents.month
        else { return nil }
        return metadata
    }

    private static func metadataFromBackupFileName(
        _ filename: String
    ) -> WebDAVFilenameMetadata? {
        guard filename.hasSuffix(backupFileExtension) else { return nil }
        let stem = String(filename.dropLast(backupFileExtension.count))
        let parts = stem.components(separatedBy: filenameSeparator)
        guard parts.count == 4,
              !parts[0].isEmpty,
              parts[0] == sanitizedDeviceName(parts[0]),
              let deviceID = UUID(uuidString: parts[1]),
              let createdAt = backupDateFormatter.date(from: parts[2]),
              let snapshotID = UUID(uuidString: parts[3])
        else { return nil }
        return WebDAVFilenameMetadata(
            deviceID: deviceID,
            snapshotID: snapshotID,
            createdAt: createdAt
        )
    }

    private static func sanitizedDeviceName(_ name: String) -> String {
        let forbidden = CharacterSet.controlCharacters
            .union(CharacterSet(charactersIn: "/\\:"))
        var result = ""
        result.reserveCapacity(min(name.unicodeScalars.count, maximumDeviceNameLength))
        var previousWasSeparator = false
        var scalarCount = 0
        for scalar in name.unicodeScalars {
            let isForbidden = forbidden.contains(scalar)
            let isWhitespace = CharacterSet.whitespacesAndNewlines.contains(scalar)
            if isForbidden || isWhitespace || scalar == "-" {
                if !result.isEmpty, !previousWasSeparator {
                    result.append("-")
                    previousWasSeparator = true
                }
            } else {
                result.unicodeScalars.append(scalar)
                previousWasSeparator = false
            }
            scalarCount = result.unicodeScalars.count
            if scalarCount >= maximumDeviceNameLength { break }
        }
        result = result.trimmingCharacters(
            in: CharacterSet(charactersIn: "-. ")
        )
        return result.isEmpty ? "Mac" : result
    }

    private static func sameEnvelopeSecond(_ lhs: Date, _ rhs: Date) -> Bool {
        envelopeDateFormatter.string(from: lhs)
            == envelopeDateFormatter.string(from: rhs)
    }

    private static func isNewerBackup(
        _ lhs: BackupSummary,
        _ rhs: BackupSummary
    ) -> Bool {
        if lhs.createdAt != rhs.createdAt {
            return lhs.createdAt > rhs.createdAt
        }
        return lhs.id.revisionID > rhs.id.revisionID
    }

    private static let envelopeDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    private static let backupDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH-mm-ss.SSS'Z'"
        return formatter
    }()

    private static let backupRootDirectoryName = "StrokeMouse"
    private static let backupFileExtension = ".strokemouse-backup"
    private static let filenameSeparator = "--"
    private static let maximumDeviceNameLength = 48
    private static let maximumHistoryCursorLength = 256
    private static let historyCursorCharacterSet = CharacterSet.alphanumerics
        .union(CharacterSet(charactersIn: "-_"))
    private static let invalidHistoryCursorError = BackupRemoteError.invalidQuery(
        "The WebDAV history cursor is invalid."
    )

    private static let propfindBody = """
    <?xml version="1.0" encoding="utf-8" ?>
    <d:propfind xmlns:d="DAV:">
      <d:prop>
        <d:resourcetype />
        <d:getcontentlength />
        <d:getlastmodified />
      </d:prop>
    </d:propfind>
    """
}

private struct WebDAVListing {
    let resources: [WebDAVResource]
    let byteCount: Int
}

private struct WebDAVMonthDirectoryIndex {
    let monthURLs: [URL]
    let metadataByteCount: Int
}

private struct WebDAVHistoryCursor: Codable {
    static let currentVersion = 1
    static let initial = WebDAVHistoryCursor(
        version: currentVersion,
        monthIndex: 0,
        offset: 0
    )

    let version: Int
    let monthIndex: Int
    let offset: Int
}

private struct WebDAVResource {
    let url: URL
    let isCollection: Bool
    let byteCount: Int?
    let lastModified: Date?
}

private struct WebDAVFilenameMetadata {
    let deviceID: UUID
    let snapshotID: UUID
    let createdAt: Date
}

private final class WebDAVMultiStatusParser: NSObject, XMLParserDelegate {
    private let requestURL: URL
    private let baseURL: URL
    private var resources: [WebDAVResource] = []
    private var currentHref: String?
    private var currentIsCollection = false
    private var currentByteCount: Int?
    private var currentLastModified: Date?
    private var currentText = ""

    private init(requestURL: URL, baseURL: URL) {
        self.requestURL = requestURL
        self.baseURL = baseURL
    }

    static func parse(
        _ data: Data,
        requestURL: URL,
        baseURL: URL
    ) throws -> [WebDAVResource] {
        let delegate = WebDAVMultiStatusParser(
            requestURL: requestURL,
            baseURL: baseURL
        )
        let parser = XMLParser(data: data)
        parser.shouldProcessNamespaces = true
        parser.delegate = delegate
        guard parser.parse() else {
            throw BackupRemoteError.invalidResponse(
                "The WebDAV server returned malformed PROPFIND XML."
            )
        }
        return delegate.resources
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        let name = Self.localName(elementName, qualifiedName: qName)
        currentText = ""
        if name == "response" {
            currentHref = nil
            currentIsCollection = false
            currentByteCount = nil
            currentLastModified = nil
        } else if name == "collection" {
            currentIsCollection = true
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        let name = Self.localName(elementName, qualifiedName: qName)
        let value = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        switch name {
        case "href":
            currentHref = value
        case "getcontentlength":
            currentByteCount = Int(value)
        case "getlastmodified":
            currentLastModified = Self.httpDateFormatter.date(from: value)
        case "response":
            appendCurrentResource()
        default:
            break
        }
        currentText = ""
    }

    private func appendCurrentResource() {
        guard let href = currentHref,
              let url = URL(string: href, relativeTo: requestURL)?.absoluteURL,
              BackupHTTP.isSafeRedirect(from: baseURL, to: url),
              url.path.hasPrefix(WebDAVBackupAdapter.directoryPath(baseURL.path))
        else { return }
        resources.append(WebDAVResource(
            url: url,
            isCollection: currentIsCollection,
            byteCount: currentByteCount,
            lastModified: currentLastModified
        ))
    }

    private static func localName(
        _ elementName: String,
        qualifiedName: String?
    ) -> String {
        let raw = qualifiedName ?? elementName
        return raw.split(separator: ":").last.map(String.init)?
            .lowercased() ?? raw.lowercased()
    }

    private static let httpDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss z"
        return formatter
    }()
}
