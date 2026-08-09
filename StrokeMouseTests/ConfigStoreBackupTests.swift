import XCTest
@testable import StrokeMouse

@MainActor
final class ConfigStoreBackupTests: XCTestCase {
    func testBackupFilePreservesCompleteLibraryOrderAndIDs() throws {
        try withStore { store, _ in
            let first = profile(name: "First", points: PathTemplates.up)
            let second = profile(name: "Second", points: PathTemplates.down)
            store.replaceAll([first, second])

            let backup = try store.makeBackupGestureFile()

            XCTAssertEqual(backup.version, Constants.configVersion)
            XCTAssertEqual(backup.gestures, [first, second])
            XCTAssertEqual(backup.gestures.map(\.id), [first.id, second.id])
        }
    }

    func testReplaceFromBackupPersistsAndPublishesExactOrderAndIDs()
        throws
    {
        try withStore { store, url in
            let first = profile(name: "First", points: PathTemplates.left)
            let second = profile(name: "Second", points: PathTemplates.right)
            var publishCount = 0
            store.onGesturesChanged = { publishCount += 1 }

            try store.replaceFromBackup(file([second, first]))

            XCTAssertEqual(store.gestures, [second, first])
            XCTAssertEqual(publishCount, 1)
            let reloaded = ConfigStore(configURL: url)
            XCTAssertEqual(reloaded.gestures, [second, first])
        }
    }

    func testEmptyLibraryIsAValidBackupAndRestore() throws {
        try withStore { store, url in
            try store.replaceFromBackup(.empty)

            XCTAssertTrue(store.gestures.isEmpty)
            XCTAssertEqual(try store.makeBackupGestureFile(), .empty)
            XCTAssertTrue(ConfigStore(configURL: url).gestures.isEmpty)
        }
    }

    func testInvalidBackupDoesNotChangeMemoryOrDisk() throws {
        try withStore { store, url in
            let beforeGestures = store.gestures
            let beforeData = try Data(contentsOf: url)
            let duplicate = profile(
                name: "Duplicate",
                points: PathTemplates.up
            )

            XCTAssertThrowsError(try store.replaceFromBackup(
                file([duplicate, duplicate])
            )) { error in
                guard case .invalidConfiguration = error as? ConfigStoreFailure else {
                    return XCTFail("Expected invalid configuration, got \(error)")
                }
            }

            XCTAssertEqual(store.gestures, beforeGestures)
            XCTAssertEqual(try Data(contentsOf: url), beforeData)
        }
    }

    func testUnsupportedBackupVersionDoesNotChangeStore() throws {
        try withStore { store, url in
            let beforeGestures = store.gestures
            let beforeData = try Data(contentsOf: url)

            XCTAssertThrowsError(try store.replaceFromBackup(
                GestureConfigFile(version: 99, gestures: [])
            )) { error in
                XCTAssertEqual(
                    error as? ConfigStoreFailure,
                    .unsupportedVersion(99)
                )
            }

            XCTAssertEqual(store.gestures, beforeGestures)
            XCTAssertEqual(try Data(contentsOf: url), beforeData)
        }
    }

    func testBackupPreflightRejectsInvalidPathWithoutMutatingStoreState()
        throws
    {
        try withStore { store, url in
            let beforeGestures = store.gestures
            let beforeData = try Data(contentsOf: url)
            let invalid = GestureProfile(
                name: "Invalid path",
                input: .drawn(DrawnGesture(
                    activation: .modifier(.function),
                    points: [CodablePoint(x: 0, y: 0)]
                ))
            )

            XCTAssertThrowsError(try store.validateBackupGestureFile(
                file([invalid])
            )) { error in
                XCTAssertEqual(
                    error as? ConfigStoreFailure,
                    .invalidConfiguration(.drawnPathTooShort(invalid.id))
                )
            }
            XCTAssertEqual(store.gestures, beforeGestures)
            XCTAssertEqual(try Data(contentsOf: url), beforeData)
            XCTAssertNil(store.lastFailure)
            XCTAssertNil(store.lastError)
        }
    }

    func testBackupPreflightRejectsDuplicateIDsWithoutMutatingErrorState()
        throws
    {
        try withStore { store, _ in
            let duplicate = profile(
                name: "Duplicate",
                points: PathTemplates.up
            )

            XCTAssertThrowsError(try store.validateBackupGestureFile(
                file([duplicate, duplicate])
            )) { error in
                XCTAssertEqual(
                    error as? ConfigStoreFailure,
                    .invalidConfiguration(.duplicateProfileID(duplicate.id))
                )
            }
            XCTAssertNil(store.lastFailure)
            XCTAssertNil(store.lastError)
        }
    }

    func testRecoveryBlocksBackupAndRestoreWithoutTouchingCorruptFile()
        throws
    {
        let directory = temporaryDirectory()
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("gestures.json")
        let corrupt = Data("not-json".utf8)
        try corrupt.write(to: url)
        let store = ConfigStore(configURL: url)

        XCTAssertTrue(store.requiresRecovery)
        XCTAssertThrowsError(try store.makeBackupGestureFile()) { error in
            XCTAssertEqual(error as? ConfigStoreFailure, .recoveryRequired)
        }
        XCTAssertThrowsError(try store.replaceFromBackup(.empty)) { error in
            XCTAssertEqual(error as? ConfigStoreFailure, .recoveryRequired)
        }
        XCTAssertEqual(try Data(contentsOf: url), corrupt)
    }

    func testReplacementFailureDoesNotPublishCandidate() throws {
        let directory = temporaryDirectory()
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("gestures.json")
        let store = ConfigStore(
            configURL: url,
            replaceItem: { _, _ in throw CocoaError(.fileWriteUnknown) }
        )
        let before = store.gestures
        let beforeData = try Data(contentsOf: url)
        var publishCount = 0
        store.onGesturesChanged = { publishCount += 1 }
        let candidate = profile(name: "Candidate", points: PathTemplates.left)

        XCTAssertThrowsError(try store.replaceFromBackup(file([candidate]))) {
            error in
            guard case .persistenceFailed = error as? ConfigStoreFailure else {
                return XCTFail("Expected persistence failure, got \(error)")
            }
        }

        XCTAssertEqual(store.gestures, before)
        XCTAssertEqual(try Data(contentsOf: url), beforeData)
        XCTAssertEqual(publishCount, 0)
    }

    private func withStore(
        _ body: (ConfigStore, URL) throws -> Void
    ) throws {
        let directory = temporaryDirectory()
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("gestures.json")
        try body(ConfigStore(configURL: url), url)
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(
            "StrokeMouseBackupTests-\(UUID().uuidString)",
            isDirectory: true
        )
    }

    private func file(_ gestures: [GestureProfile]) -> GestureConfigFile {
        GestureConfigFile(
            version: Constants.configVersion,
            gestures: gestures
        )
    }

    private func profile(
        name: String,
        points: [CodablePoint]
    ) -> GestureProfile {
        GestureProfile(name: name, pattern: .freePath(points))
    }
}
