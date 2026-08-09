import XCTest
@testable import StrokeMouse

final class BackupRemoteAdapterTests: XCTestCase {
    override func setUp() {
        super.setUp()
        BackupStubURLProtocol.reset()
    }

    override func tearDown() {
        BackupStubURLProtocol.reset()
        super.tearDown()
    }

    func testGistCreateStoresSecretFileAndVerifiesReturnedRevision() async throws {
        let backup = try makeBackup()
        let content = try XCTUnwrap(String(data: backup.data, encoding: .utf8))
        let session = stubSession()
        var step = 0
        BackupStubURLProtocol.handler = { request in
            defer { step += 1 }
            switch step {
            case 0:
                XCTAssertEqual(request.httpMethod, "POST")
                XCTAssertEqual(request.url?.path, "/gists")
                XCTAssertEqual(
                    request.value(forHTTPHeaderField: "Authorization"),
                    "Bearer pat-secret"
                )
                XCTAssertEqual(
                    request.value(forHTTPHeaderField: "X-GitHub-Api-Version"),
                    GitHubGistBackupAdapter.apiVersion
                )
                let body = try XCTUnwrap(requestBodyData(request))
                let object = try XCTUnwrap(
                    JSONSerialization.jsonObject(with: body) as? [String: Any]
                )
                XCTAssertEqual(object["public"] as? Bool, false)
                let files = try XCTUnwrap(object["files"] as? [String: Any])
                let file = try XCTUnwrap(
                    files[GitHubGistBackupAdapter.fixedFileName]
                        as? [String: Any]
                )
                XCTAssertEqual(file["content"] as? String, content)
                return .json([
                    "id": "abc123",
                    "history": [["version": "def456"]],
                ], status: 201, url: request.url!)
            case 1:
                XCTAssertEqual(request.httpMethod, "GET")
                XCTAssertEqual(request.url?.path, "/gists/abc123/def456")
                return .json([
                    "id": "abc123",
                    "files": [
                        GitHubGistBackupAdapter.fixedFileName: [
                            "size": backup.data.count,
                            "truncated": false,
                            "content": content,
                        ],
                    ],
                ], url: request.url!)
            default:
                return .status(500, url: request.url!)
            }
        }
        let adapter = try GitHubGistBackupAdapter(
            personalAccessToken: "pat-secret",
            session: session
        )

        let id = try await adapter.storeBackup(
            backup.data,
            createdAt: backup.envelope.createdAt
        )

        XCTAssertEqual(id, RemoteBackupID(
            providerID: BackupRemoteProviderID.githubGist,
            containerID: "abc123",
            revisionID: "def456"
        ))
        XCTAssertEqual(step, 2)
    }

    func testGistExistingUploadUsesPatchAndRejectsVerificationMismatch() async throws {
        let backup = try makeBackup()
        let session = stubSession()
        var step = 0
        BackupStubURLProtocol.handler = { request in
            defer { step += 1 }
            if step == 0 {
                XCTAssertEqual(request.httpMethod, "PATCH")
                XCTAssertEqual(request.url?.path, "/gists/existing1")
                let body = try XCTUnwrap(requestBodyData(request))
                let object = try XCTUnwrap(
                    JSONSerialization.jsonObject(with: body) as? [String: Any]
                )
                XCTAssertNil(object["public"])
                XCTAssertEqual(
                    Set(object.keys),
                    Set(["description", "files"])
                )
                return .json([
                    "id": "existing1",
                    "history": [["version": "revision2"]],
                ], url: request.url!)
            }
            return .json([
                "id": "existing1",
                "files": [
                    GitHubGistBackupAdapter.fixedFileName: [
                        "truncated": false,
                        "content": "different",
                    ],
                ],
            ], url: request.url!)
        }
        let adapter = try GitHubGistBackupAdapter(
            personalAccessToken: "pat-secret",
            gistID: "existing1",
            session: session
        )

        await XCTAssertThrowsBackupError(
            try await adapter.storeBackup(
                backup.data,
                createdAt: backup.envelope.createdAt
            )
        ) { error in
            guard case .invalidResponse(let message) = error else {
                return XCTFail("Expected verification failure, got \(error)")
            }
            XCTAssertTrue(message.contains("verification"))
            XCTAssertFalse(message.contains("pat-secret"))
        }
    }

    func testGistHistoryUsesCommitPagination() async throws {
        let session = stubSession()
        BackupStubURLProtocol.handler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.path, "/gists/gist1/commits")
            let components = try XCTUnwrap(
                URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            )
            XCTAssertEqual(
                components.queryItems?.first { $0.name == "per_page" }?.value,
                "2"
            )
            XCTAssertEqual(
                components.queryItems?.first { $0.name == "page" }?.value,
                "3"
            )
            return .json([
                ["version": "rev31", "committed_at": "2026-08-09T10:00:00Z"],
                ["version": "rev30", "committed_at": "2026-08-09T09:00:00Z"],
            ], url: request.url!)
        }
        let adapter = try GitHubGistBackupAdapter(
            personalAccessToken: "pat-secret",
            gistID: "gist1",
            session: session
        )

        let page = try await adapter.listHistory(
            BackupHistoryQuery(cursor: "3", limit: 2)
        )

        XCTAssertEqual(page.backups.map(\.id.revisionID), ["rev31", "rev30"])
        XCTAssertEqual(page.nextCursor, "4")
        XCTAssertTrue(page.backups.allSatisfy { $0.byteCount == nil })
    }

    func testGistTruncatedRevisionUsesRawURLWithoutPAT() async throws {
        let rawURL = URL(
            string: "https://gist.githubusercontent.com/user/gist/raw/rev/strokemouse"
        )!
        let expected = Data("raw-backup".utf8)
        let session = stubSession()
        var step = 0
        BackupStubURLProtocol.handler = { request in
            defer { step += 1 }
            if step == 0 {
                XCTAssertNotNil(request.value(forHTTPHeaderField: "Authorization"))
                return .json([
                    "id": "gist1",
                    "files": [
                        GitHubGistBackupAdapter.fixedFileName: [
                            "size": expected.count,
                            "truncated": true,
                            "raw_url": rawURL.absoluteString,
                        ],
                    ],
                ], url: request.url!)
            }
            XCTAssertEqual(request.url, rawURL)
            XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
            XCTAssertNil(request.value(forHTTPHeaderField: "X-GitHub-Api-Version"))
            return .data(expected, status: 200, url: rawURL)
        }
        let adapter = try GitHubGistBackupAdapter(
            personalAccessToken: "pat-secret",
            gistID: "gist1",
            session: session
        )
        let id = RemoteBackupID(
            providerID: BackupRemoteProviderID.githubGist,
            containerID: "gist1",
            revisionID: "rev1"
        )

        let fetched = try await adapter.fetchBackup(id)
        XCTAssertEqual(fetched, expected)
        XCTAssertEqual(step, 2)
    }

    func testGistRejectsOversizedStoreAndListResponses() async throws {
        let oversized = Data(
            repeating: 0x61,
            count: BackupRemoteLimits.maximumPayloadByteCount + 1
        )
        let session = stubSession()
        var requestCount = 0
        BackupStubURLProtocol.handler = { request in
            requestCount += 1
            return .data(oversized, status: 200, url: request.url!)
        }
        let adapter = try GitHubGistBackupAdapter(
            personalAccessToken: "pat-secret",
            gistID: "gist1",
            session: session
        )

        await XCTAssertThrowsBackupError(
            try await adapter.storeBackup(oversized, createdAt: Date())
        ) { error in
            guard case .payloadTooLarge = error else {
                return XCTFail("Expected size failure, got \(error)")
            }
        }
        XCTAssertEqual(requestCount, 0)

        await XCTAssertThrowsBackupError(
            try await adapter.listHistory(BackupHistoryQuery(limit: 1))
        ) { error in
            guard case .payloadTooLarge = error else {
                return XCTFail("Expected size failure, got \(error)")
            }
        }
        XCTAssertEqual(requestCount, 1)
    }

    func testWebDAVStoreUsesEnvelopeIdentityAndImmutableMonthlyPath() async throws {
        let createdAt = Date(timeIntervalSince1970: 1_754_738_553)
        let deviceID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let snapshotID = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
        let backup = try makeBackup(
            snapshotID: snapshotID,
            createdAt: createdAt,
            deviceID: deviceID,
            deviceName: " My/Mac\n--Name "
        )
        let session = stubSession()
        var requests: [URLRequest] = []
        var putBody: Data?
        BackupStubURLProtocol.handler = { request in
            requests.append(request)
            switch request.httpMethod {
            case "OPTIONS":
                return .data(
                    Data(),
                    status: 204,
                    headers: ["DAV": "1, 2"],
                    url: request.url!
                )
            case "PROPFIND":
                XCTAssertEqual(request.value(forHTTPHeaderField: "Depth"), "0")
                return .status(207, url: request.url!)
            case "MKCOL":
                return .status(201, url: request.url!)
            case "PUT":
                putBody = requestBodyData(request)
                return .status(201, url: request.url!)
            default:
                return .status(500, url: request.url!)
            }
        }
        let adapter = try WebDAVBackupAdapter(
            baseURL: URL(string: "https://dav.example/user")!,
            username: "alice",
            password: "dav-secret",
            session: session
        )

        let id = try await adapter.storeBackup(
            backup.data,
            createdAt: backup.envelope.createdAt
        )

        XCTAssertEqual(requests.map(\.httpMethod), [
            "OPTIONS", "PROPFIND", "MKCOL", "MKCOL", "MKCOL", "PUT",
        ])
        XCTAssertEqual(
            requests[2].url?.absoluteString,
            "https://dav.example/user/StrokeMouse/"
        )
        XCTAssertEqual(
            requests[3].url?.absoluteString,
            "https://dav.example/user/StrokeMouse/2025/"
        )
        XCTAssertEqual(
            requests[4].url?.absoluteString,
            "https://dav.example/user/StrokeMouse/2025/08/"
        )
        let expectedFile = [
            "My-Mac-Name",
            deviceID.uuidString.lowercased(),
            webDAVTimestamp(backup.envelope.createdAt),
            snapshotID.uuidString.lowercased(),
        ].joined(separator: "--") + ".strokemouse-backup"
        XCTAssertEqual(
            requests[5].url?.path,
            "/user/StrokeMouse/2025/08/\(expectedFile)"
        )
        XCTAssertEqual(
            requests[5].value(forHTTPHeaderField: "If-None-Match"),
            "*"
        )
        XCTAssertEqual(putBody, backup.data)
        XCTAssertTrue(requests.allSatisfy {
            $0.value(forHTTPHeaderField: "Authorization") == nil
        })
        XCTAssertEqual(id.containerID, "https://dav.example/user/StrokeMouse/")
        XCTAssertEqual(id.revisionID, "2025/08/\(expectedFile)")
    }

    func testWebDAVStoreRejectsCreatedAtMismatchBeforeNetwork() async throws {
        let backup = try makeBackup()
        let session = stubSession()
        var requestCount = 0
        BackupStubURLProtocol.handler = { request in
            requestCount += 1
            return .status(500, url: request.url!)
        }
        let adapter = try WebDAVBackupAdapter(
            baseURL: URL(string: "https://dav.example/backups")!,
            username: "alice",
            password: "dav-secret",
            session: session
        )

        await XCTAssertThrowsBackupError(
            try await adapter.storeBackup(
                backup.data,
                createdAt: backup.envelope.createdAt.addingTimeInterval(1)
            )
        ) { error in
            guard case .invalidPayload = error else {
                return XCTFail("Expected envelope date failure, got \(error)")
            }
        }
        XCTAssertEqual(requestCount, 0)
    }

    func testWebDAVStoreAcceptsCreatedAtLostFractionalSecondsInEnvelope() async throws {
        let createdAt = Date(timeIntervalSince1970: 1_754_738_553.789)
        let backup = try makeBackup(createdAt: createdAt)
        XCTAssertNotEqual(backup.envelope.createdAt, createdAt)
        let session = stubSession()
        BackupStubURLProtocol.handler = { request in
            switch request.httpMethod {
            case "OPTIONS":
                return .data(
                    Data(),
                    status: 204,
                    headers: ["DAV": "1"],
                    url: request.url!
                )
            case "PROPFIND":
                return .status(207, url: request.url!)
            case "MKCOL", "PUT":
                return .status(201, url: request.url!)
            default:
                return .status(500, url: request.url!)
            }
        }
        let adapter = try WebDAVBackupAdapter(
            baseURL: URL(string: "https://dav.example/user")!,
            username: "alice",
            password: "dav-secret",
            session: session
        )

        let id = try await adapter.storeBackup(backup.data, createdAt: createdAt)

        XCTAssertTrue(id.revisionID.contains("2025-08-09T11-22-33.000Z"))
    }

    func testWebDAVValidationRequiresAuthenticatedPropfindAccess() async throws {
        let session = stubSession()
        var methods: [String] = []
        BackupStubURLProtocol.handler = { request in
            methods.append(request.httpMethod ?? "")
            if request.httpMethod == "OPTIONS" {
                return .data(
                    Data(),
                    status: 204,
                    headers: ["DAV": "1"],
                    url: request.url!
                )
            }
            XCTAssertEqual(request.httpMethod, "PROPFIND")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Depth"), "0")
            return .status(401, url: request.url!)
        }
        let adapter = try WebDAVBackupAdapter(
            baseURL: URL(string: "https://dav.example/user")!,
            username: "alice",
            password: "wrong-password",
            session: session
        )

        await XCTAssertThrowsBackupError(
            try await adapter.validateConnection()
        ) {
            XCTAssertEqual($0, .authenticationRequired)
        }
        XCTAssertEqual(methods, ["OPTIONS", "PROPFIND"])
    }

    func testWebDAVHistoryRecursesAndIgnoresUnknownFiles() async throws {
        let deviceID = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
        let snapshotID = "11111111-2222-3333-4444-555555555555"
        let validName = "Office-Mac--\(deviceID)--2026-08-09T10-00-00.000Z--\(snapshotID).strokemouse-backup"
        let session = stubSession()
        BackupStubURLProtocol.handler = { request in
            XCTAssertEqual(request.httpMethod, "PROPFIND")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Depth"), "1")
            switch request.url?.path {
            case "/user/StrokeMouse":
                return .xml(multistatus([
                    collection("/user/StrokeMouse/"),
                    collection("/user/StrokeMouse/2026/"),
                    collection("/user/StrokeMouse/not-a-year/"),
                ]), url: request.url!)
            case "/user/StrokeMouse/2026":
                return .xml(multistatus([
                    collection("/user/StrokeMouse/2026/"),
                    collection("/user/StrokeMouse/2026/08/"),
                ]), url: request.url!)
            case "/user/StrokeMouse/2026/08":
                return .xml(multistatus([
                    collection("/user/StrokeMouse/2026/08/"),
                    file("/user/StrokeMouse/2026/08/\(validName)", size: 321),
                    file("/user/StrokeMouse/2026/08/unknown.json", size: 12),
                    file("/user/StrokeMouse/2026/08/bad.strokemouse-backup", size: 12),
                ]), url: request.url!)
            default:
                return .status(404, url: request.url!)
            }
        }
        let adapter = try WebDAVBackupAdapter(
            baseURL: URL(string: "https://dav.example/user")!,
            username: "alice",
            password: "dav-secret",
            session: session
        )

        let page = try await adapter.listHistory(BackupHistoryQuery(limit: 1))

        let summary = try XCTUnwrap(page.backups.first)
        XCTAssertEqual(page.backups.count, 1)
        XCTAssertEqual(summary.byteCount, 321)
        XCTAssertEqual(
            summary.id.revisionID,
            "2026/08/\(validName)"
        )
        XCTAssertNil(page.nextCursor)
    }

    func testWebDAVHistoryPaginatesLazilyAcrossMonthDirectories() async throws {
        let deviceID = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
        let names = [
            "Office-Mac--\(deviceID)--2026-08-09T10-00-00.000Z--11111111-2222-3333-4444-555555555555.strokemouse-backup",
            "Office-Mac--\(deviceID)--2026-08-09T09-00-00.000Z--22222222-3333-4444-5555-666666666666.strokemouse-backup",
            "Office-Mac--\(deviceID)--2026-08-09T08-00-00.000Z--33333333-4444-5555-6666-777777777777.strokemouse-backup",
            "Office-Mac--\(deviceID)--2026-07-31T23-00-00.000Z--44444444-5555-6666-7777-888888888888.strokemouse-backup",
        ]
        let session = stubSession()
        var monthContentRequests: [String] = []
        BackupStubURLProtocol.handler = { request in
            XCTAssertEqual(request.httpMethod, "PROPFIND")
            switch request.url?.path {
            case "/user/StrokeMouse":
                return .xml(multistatus([
                    collection("/user/StrokeMouse/"),
                    collection("/user/StrokeMouse/2026/"),
                ]), url: request.url!)
            case "/user/StrokeMouse/2026":
                return .xml(multistatus([
                    collection("/user/StrokeMouse/2026/"),
                    collection("/user/StrokeMouse/2026/07/"),
                    collection("/user/StrokeMouse/2026/08/"),
                ]), url: request.url!)
            case "/user/StrokeMouse/2026/08":
                monthContentRequests.append(request.url!.path)
                return .xml(multistatus([
                    collection("/user/StrokeMouse/2026/08/"),
                    file("/user/StrokeMouse/2026/08/\(names[2])", size: 102),
                    file("/user/StrokeMouse/2026/08/\(names[0])", size: 100),
                    file("/user/StrokeMouse/2026/08/\(names[1])", size: 101),
                ]), url: request.url!)
            case "/user/StrokeMouse/2026/07":
                monthContentRequests.append(request.url!.path)
                return .xml(multistatus([
                    collection("/user/StrokeMouse/2026/07/"),
                    file("/user/StrokeMouse/2026/07/\(names[3])", size: 103),
                ]), url: request.url!)
            default:
                return .status(404, url: request.url!)
            }
        }
        let adapter = try WebDAVBackupAdapter(
            baseURL: URL(string: "https://dav.example/user")!,
            username: "alice",
            password: "dav-secret",
            session: session
        )

        let first = try await adapter.listHistory(
            BackupHistoryQuery(limit: 2)
        )

        XCTAssertEqual(
            first.backups.map(\.id.revisionID),
            names[0...1].map { "2026/08/\($0)" }
        )
        let cursor = try XCTUnwrap(first.nextCursor)
        XCTAssertNil(Int(cursor), "WebDAV cursor must remain opaque")
        XCTAssertEqual(monthContentRequests, ["/user/StrokeMouse/2026/08"])

        let second = try await adapter.listHistory(
            BackupHistoryQuery(cursor: cursor, limit: 2)
        )

        XCTAssertEqual(second.backups.map(\.id.revisionID), [
            "2026/08/\(names[2])",
            "2026/07/\(names[3])",
        ])
        XCTAssertNil(second.nextCursor)
        XCTAssertEqual(monthContentRequests, [
            "/user/StrokeMouse/2026/08",
            "/user/StrokeMouse/2026/08",
            "/user/StrokeMouse/2026/07",
        ])
    }

    func testWebDAVHistoryKeepsOversizedBackupAsSummary() async throws {
        let deviceID = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
        let oversizedName = "Office-Mac--\(deviceID)--2026-08-09T10-00-00.000Z--11111111-2222-3333-4444-555555555555.strokemouse-backup"
        let normalName = "Office-Mac--\(deviceID)--2026-08-09T09-00-00.000Z--22222222-3333-4444-5555-666666666666.strokemouse-backup"
        let oversizedByteCount = BackupRemoteLimits.maximumPayloadByteCount + 1
        let session = stubSession()
        BackupStubURLProtocol.handler = { request in
            switch request.url?.path {
            case "/user/StrokeMouse":
                return .xml(multistatus([
                    collection("/user/StrokeMouse/"),
                    collection("/user/StrokeMouse/2026/"),
                ]), url: request.url!)
            case "/user/StrokeMouse/2026":
                return .xml(multistatus([
                    collection("/user/StrokeMouse/2026/"),
                    collection("/user/StrokeMouse/2026/08/"),
                ]), url: request.url!)
            case "/user/StrokeMouse/2026/08":
                return .xml(multistatus([
                    collection("/user/StrokeMouse/2026/08/"),
                    file(
                        "/user/StrokeMouse/2026/08/\(oversizedName)",
                        size: oversizedByteCount
                    ),
                    file(
                        "/user/StrokeMouse/2026/08/\(normalName)",
                        size: 321
                    ),
                ]), url: request.url!)
            default:
                return .status(404, url: request.url!)
            }
        }
        let adapter = try WebDAVBackupAdapter(
            baseURL: URL(string: "https://dav.example/user")!,
            username: "alice",
            password: "dav-secret",
            session: session
        )

        let page = try await adapter.listHistory(BackupHistoryQuery(limit: 10))

        XCTAssertEqual(page.backups.count, 2)
        XCTAssertEqual(page.backups[0].id.revisionID, "2026/08/\(oversizedName)")
        XCTAssertEqual(page.backups[0].byteCount, oversizedByteCount)
        XCTAssertEqual(page.backups[1].byteCount, 321)
        XCTAssertNil(page.nextCursor)
    }

    func testWebDAVFetchRejectsOversizedAndCrossHostResponses() async throws {
        let id = RemoteBackupID(
            providerID: BackupRemoteProviderID.webDAV,
            containerID: "https://dav.example/user/StrokeMouse/",
            revisionID: "2026/08/Mac--aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee--2026-08-09T10-00-00.000Z--11111111-2222-3333-4444-555555555555.strokemouse-backup"
        )
        let session = stubSession()
        var returnsCrossHost = true
        BackupStubURLProtocol.handler = { request in
            if returnsCrossHost {
                return .data(
                    Data("wrong".utf8),
                    status: 200,
                    url: URL(string: "https://evil.example/stolen")!
                )
            }
            return .data(
                Data(
                    repeating: 0x61,
                    count: BackupRemoteLimits.maximumPayloadByteCount + 1
                ),
                status: 200,
                url: request.url!
            )
        }
        let adapter = try WebDAVBackupAdapter(
            baseURL: URL(string: "https://dav.example/user")!,
            username: "alice",
            password: "dav-secret",
            session: session
        )

        await XCTAssertThrowsBackupError(try await adapter.fetchBackup(id)) {
            XCTAssertEqual($0, .unsafeRedirect)
        }
        returnsCrossHost = false
        await XCTAssertThrowsBackupError(try await adapter.fetchBackup(id)) {
            guard case .payloadTooLarge = $0 else {
                return XCTFail("Expected size failure, got \($0)")
            }
        }
    }

    func testWebDAVFetchRejectsEnvelopeThatDoesNotMatchPathIdentity() async throws {
        let createdAt = Date(timeIntervalSince1970: 1_754_738_553)
        let deviceID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let pathSnapshotID = UUID(
            uuidString: "11111111-2222-3333-4444-555555555555"
        )!
        let payloadSnapshotID = UUID(
            uuidString: "99999999-2222-3333-4444-555555555555"
        )!
        let backup = try makeBackup(
            snapshotID: payloadSnapshotID,
            createdAt: createdAt,
            deviceID: deviceID
        )
        let name = [
            "Test-Mac",
            deviceID.uuidString.lowercased(),
            webDAVTimestamp(createdAt),
            pathSnapshotID.uuidString.lowercased(),
        ].joined(separator: "--") + ".strokemouse-backup"
        let id = RemoteBackupID(
            providerID: BackupRemoteProviderID.webDAV,
            containerID: "https://dav.example/user/StrokeMouse/",
            revisionID: "2025/08/\(name)"
        )
        let session = stubSession()
        BackupStubURLProtocol.handler = { request in
            .data(backup.data, status: 200, url: request.url!)
        }
        let adapter = try WebDAVBackupAdapter(
            baseURL: URL(string: "https://dav.example/user")!,
            username: "alice",
            password: "dav-secret",
            session: session
        )

        await XCTAssertThrowsBackupError(try await adapter.fetchBackup(id)) {
            guard case .invalidPayload(let message) = $0 else {
                return XCTFail("Expected identity failure, got \($0)")
            }
            XCTAssertTrue(message.contains("identity"))
        }
    }

    func testGitHub403RateLimitHeadersRemainDistinctFromForbidden() throws {
        let url = URL(string: "https://api.github.com/gists")!
        let limited = try XCTUnwrap(HTTPURLResponse(
            url: url,
            statusCode: 403,
            httpVersion: nil,
            headerFields: [
                "X-RateLimit-Remaining": "0",
                "Retry-After": "17",
            ]
        ))
        let forbidden = try XCTUnwrap(HTTPURLResponse(
            url: url,
            statusCode: 403,
            httpVersion: nil,
            headerFields: nil
        ))

        XCTAssertEqual(
            BackupHTTP.statusError(for: limited),
            .rateLimited(retryAfter: 17)
        )
        XCTAssertEqual(BackupHTTP.statusError(for: forbidden), .forbidden)
    }

    func testWebDAVBasicAndDigestChallengesUseConfiguredCredential() {
        for method in [
            NSURLAuthenticationMethodHTTPBasic,
            NSURLAuthenticationMethodHTTPDigest,
        ] {
            let delegate = BackupURLSessionDelegate(
                credentialHost: "dav.example",
                credential: URLCredential(
                    user: "alice",
                    password: "dav-secret",
                    persistence: .forSession
                )
            )
            let protectionSpace = URLProtectionSpace(
                host: "dav.example",
                port: 443,
                protocol: "https",
                realm: "backup",
                authenticationMethod: method
            )
            let challenge = URLAuthenticationChallenge(
                protectionSpace: protectionSpace,
                proposedCredential: nil,
                previousFailureCount: 0,
                failureResponse: nil,
                error: nil,
                sender: BackupChallengeSender()
            )
            let task = URLSession.shared.dataTask(
                with: URL(string: "https://dav.example/user")!
            )
            let result = BackupChallengeResult()

            delegate.urlSession(
                .shared,
                task: task,
                didReceive: challenge
            ) {
                result.record(disposition: $0, credential: $1)
            }

            let value = result.value
            XCTAssertEqual(value.disposition, .useCredential)
            XCTAssertEqual(value.credential?.user, "alice")
            XCTAssertEqual(value.credential?.password, "dav-secret")
        }
    }

    func testRedirectPolicyRejectsCrossHostAndHTTPSDowngrade() {
        let https = URL(string: "https://dav.example/backups")!
        XCTAssertFalse(BackupHTTP.isSafeRedirect(
            from: https,
            to: URL(string: "https://evil.example/backups")!
        ))
        XCTAssertFalse(BackupHTTP.isSafeRedirect(
            from: https,
            to: URL(string: "http://dav.example/backups")!
        ))
        XCTAssertTrue(BackupHTTP.isSafeRedirect(
            from: URL(string: "http://dav.example/backups")!,
            to: URL(string: "https://dav.example/backups")!
        ))
    }

    private func stubSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [BackupStubURLProtocol.self]
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }

    private func makeBackup(
        snapshotID: UUID = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!,
        createdAt: Date = Date(timeIntervalSince1970: 1_754_738_400),
        deviceID: UUID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!,
        deviceName: String = "Test Mac"
    ) throws -> BackupEncodingResult {
        let result = try BackupCodec.encodePlaintext(
            payload: BackupPayloadV1(
                gestures: .empty,
                settings: nil,
                restoredFromSnapshotID: nil
            ),
            metadata: BackupMetadataV1(
                snapshotID: snapshotID,
                createdAt: createdAt,
                kind: .manual,
                deviceID: deviceID,
                deviceName: deviceName,
                appVersion: "0.0.22",
                appBuild: "22",
                scope: .gesturesOnly
            )
        )
        return BackupEncodingResult(
            data: result.data,
            envelope: try BackupCodec.decodeEnvelope(from: result.data),
            derivedKey: result.derivedKey
        )
    }

    private func webDAVTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH-mm-ss.SSS'Z'"
        return formatter.string(from: date)
    }
}

private func XCTAssertThrowsBackupError<T>(
    _ expression: @autoclosure () async throws -> T,
    file: StaticString = #filePath,
    line: UInt = #line,
    _ assertion: (BackupRemoteError) -> Void
) async {
    do {
        _ = try await expression()
        XCTFail("Expected BackupRemoteError", file: file, line: line)
    } catch let error as BackupRemoteError {
        assertion(error)
    } catch {
        XCTFail("Unexpected error: \(error)", file: file, line: line)
    }
}

private func requestBodyData(_ request: URLRequest) -> Data? {
    if let body = request.httpBody { return body }
    guard let stream = request.httpBodyStream else { return nil }

    stream.open()
    defer { stream.close() }
    var data = Data()
    var buffer = [UInt8](repeating: 0, count: 4_096)
    while stream.hasBytesAvailable {
        let count = stream.read(&buffer, maxLength: buffer.count)
        guard count >= 0 else { return nil }
        if count == 0 { break }
        data.append(contentsOf: buffer[..<count])
    }
    return data
}

private final class BackupChallengeSender: NSObject,
    URLAuthenticationChallengeSender
{
    func use(
        _ credential: URLCredential,
        for challenge: URLAuthenticationChallenge
    ) {}

    func continueWithoutCredential(
        for challenge: URLAuthenticationChallenge
    ) {}

    func cancel(_ challenge: URLAuthenticationChallenge) {}

    func performDefaultHandling(
        for challenge: URLAuthenticationChallenge
    ) {}

    func rejectProtectionSpaceAndContinue(
        with challenge: URLAuthenticationChallenge
    ) {}
}

private final class BackupChallengeResult: @unchecked Sendable {
    private let lock = NSLock()
    private var storedDisposition: URLSession.AuthChallengeDisposition?
    private var storedCredential: URLCredential?

    var value: (
        disposition: URLSession.AuthChallengeDisposition?,
        credential: URLCredential?
    ) {
        lock.withLock { (storedDisposition, storedCredential) }
    }

    func record(
        disposition: URLSession.AuthChallengeDisposition,
        credential: URLCredential?
    ) {
        lock.withLock {
            storedDisposition = disposition
            storedCredential = credential
        }
    }
}

private final class BackupStubURLProtocol: URLProtocol, @unchecked Sendable {
    struct StubResponse {
        let data: Data
        let response: HTTPURLResponse

        static func status(_ status: Int, url: URL) -> StubResponse {
            data(Data(), status: status, url: url)
        }

        static func data(
            _ data: Data,
            status: Int,
            headers: [String: String] = [:],
            url: URL
        ) -> StubResponse {
            StubResponse(
                data: data,
                response: HTTPURLResponse(
                    url: url,
                    statusCode: status,
                    httpVersion: "HTTP/1.1",
                    headerFields: headers
                )!
            )
        }

        static func json(
            _ object: Any,
            status: Int = 200,
            url: URL
        ) -> StubResponse {
            try! data(
                JSONSerialization.data(withJSONObject: object),
                status: status,
                headers: ["Content-Type": "application/json"],
                url: url
            )
        }

        static func xml(_ xml: String, url: URL) -> StubResponse {
            data(
                Data(xml.utf8),
                status: 207,
                headers: ["Content-Type": "application/xml"],
                url: url
            )
        }
    }

    nonisolated(unsafe) static var handler: ((URLRequest) throws -> StubResponse)?

    static func reset() {
        handler = nil
    }

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(
                self,
                didFailWithError: BackupRemoteError.invalidResponse(
                    "No URLProtocol handler was installed."
                )
            )
            return
        }
        do {
            let result = try handler(request)
            client?.urlProtocol(
                self,
                didReceive: result.response,
                cacheStoragePolicy: .notAllowed
            )
            client?.urlProtocol(self, didLoad: result.data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private func multistatus(_ responses: [String]) -> String {
    """
    <?xml version="1.0" encoding="utf-8"?>
    <d:multistatus xmlns:d="DAV:">
      \(responses.joined(separator: "\n"))
    </d:multistatus>
    """
}

private func collection(_ href: String) -> String {
    """
    <d:response>
      <d:href>\(href)</d:href>
      <d:propstat><d:prop><d:resourcetype><d:collection/></d:resourcetype></d:prop></d:propstat>
    </d:response>
    """
}

private func file(_ href: String, size: Int) -> String {
    """
    <d:response>
      <d:href>\(href)</d:href>
      <d:propstat><d:prop>
        <d:resourcetype/>
        <d:getcontentlength>\(size)</d:getcontentlength>
        <d:getlastmodified>Sat, 09 Aug 2026 10:00:00 GMT</d:getlastmodified>
      </d:prop></d:propstat>
    </d:response>
    """
}
