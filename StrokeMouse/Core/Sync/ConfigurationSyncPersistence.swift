import Foundation

struct StoredSyncConfiguration: Codable, Equatable, Sendable {
    static let currentVersion = 1

    var version = currentVersion
    var connection: SyncConnectionDescriptor
    var deviceID: UUID
    var deviceName: String
    var scope: SyncScope
    var encryption: BackupEncryptionKind
    var currentEncryptionKeyID: UUID?
    var knownEncryptionKeyIDs: [UUID]
    var automaticBackupEnabled: Bool
    var lastSuccessfulContentHash: Data?
    var lastSuccess: SyncOperationRecord?
    var lastHourlyCheck: Date?
}

struct StoredBackupDerivedKey: Codable, Sendable {
    var keyID: UUID
    var salt: Data
    var iterations: Int
    var keyData: Data

    init(_ key: BackupDerivedKey) {
        keyID = key.keyID
        salt = key.salt
        iterations = key.iterations
        keyData = key.keyData
    }

    var derivedKey: BackupDerivedKey {
        BackupDerivedKey(
            keyID: keyID,
            salt: salt,
            iterations: iterations,
            keyData: keyData
        )
    }
}

protocol ConfigurationSyncPersisting {
    func loadConfiguration() throws -> StoredSyncConfiguration?
    func saveConfiguration(_ configuration: StoredSyncConfiguration) throws
    func removeConfiguration() throws
    func stableDeviceID() -> UUID
}

struct ConfigurationSyncPersistence: ConfigurationSyncPersisting {
    private let defaults: UserDefaults
    private let configurationKey = "configurationSync.configuration.v1"
    private let deviceIDKey = "configurationSync.deviceID"

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func loadConfiguration() throws -> StoredSyncConfiguration? {
        guard let data = defaults.data(forKey: configurationKey) else {
            return nil
        }
        do {
            let value = try JSONDecoder().decode(
                StoredSyncConfiguration.self,
                from: data
            )
            guard value.version == StoredSyncConfiguration.currentVersion else {
                throw ConfigurationSyncError.invalidStoredConfiguration
            }
            return value
        } catch let error as ConfigurationSyncError {
            throw error
        } catch {
            throw ConfigurationSyncError.invalidStoredConfiguration
        }
    }

    func saveConfiguration(_ configuration: StoredSyncConfiguration) throws {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            defaults.set(try encoder.encode(configuration), forKey: configurationKey)
        } catch {
            throw ConfigurationSyncError.invalidStoredConfiguration
        }
    }

    func removeConfiguration() throws {
        defaults.removeObject(forKey: configurationKey)
    }

    func stableDeviceID() -> UUID {
        if let raw = defaults.string(forKey: deviceIDKey),
           let id = UUID(uuidString: raw)
        {
            return id
        }
        let id = UUID()
        defaults.set(id.uuidString, forKey: deviceIDKey)
        return id
    }

    static func encodeDerivedKey(_ key: BackupDerivedKey) throws -> Data {
        try JSONEncoder().encode(StoredBackupDerivedKey(key))
    }

    static func decodeDerivedKey(_ data: Data) throws -> BackupDerivedKey {
        do {
            return try JSONDecoder().decode(
                StoredBackupDerivedKey.self,
                from: data
            ).derivedKey
        } catch {
            throw ConfigurationSyncError.invalidStoredConfiguration
        }
    }
}
