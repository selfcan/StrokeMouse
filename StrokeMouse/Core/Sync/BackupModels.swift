import Foundation

enum SyncScope: String, Codable, CaseIterable, Identifiable, Sendable {
    case gesturesOnly
    case allConfiguration

    var id: String { rawValue }
}

enum BackupKind: String, Codable, CaseIterable, Sendable {
    case automaticChange
    case hourly
    case manual
    case preRestore
}

enum BackupEncryptionKind: String, Codable, Sendable {
    case none
    case aes256GCM
}

struct BackupEncryptionDescriptorV1: Codable, Equatable, Sendable {
    var kind: BackupEncryptionKind
    var keyID: UUID?
    var salt: Data?
    var iterations: Int?

    static let plaintext = BackupEncryptionDescriptorV1(
        kind: .none,
        keyID: nil,
        salt: nil,
        iterations: nil
    )

    static func aes256GCM(
        keyID: UUID,
        salt: Data,
        iterations: Int
    ) -> BackupEncryptionDescriptorV1 {
        BackupEncryptionDescriptorV1(
            kind: .aes256GCM,
            keyID: keyID,
            salt: salt,
            iterations: iterations
        )
    }
}

/// Metadata kept outside the encrypted payload so backup history can be listed
/// without a password or a Keychain lookup.
struct BackupMetadataV1: Equatable, Sendable {
    var snapshotID: UUID
    var createdAt: Date
    var kind: BackupKind
    var deviceID: UUID
    var deviceName: String
    var appVersion: String
    var appBuild: String
    var scope: SyncScope
}

struct BackupEnvelopeV1: Codable, Equatable, Sendable {
    static let currentFormatVersion = 1

    var formatVersion: Int
    var snapshotID: UUID
    var createdAt: Date
    var kind: BackupKind
    var deviceID: UUID
    var deviceName: String
    var appVersion: String
    var appBuild: String
    var scope: SyncScope
    var encryption: BackupEncryptionDescriptorV1
    /// SHA-256 of the canonical plaintext `BackupPayloadV1` JSON.
    var payloadDigest: Data
    /// Canonical payload JSON for plaintext backups, or AES.GCM combined data.
    var payloadRepresentation: Data

    init(
        metadata: BackupMetadataV1,
        encryption: BackupEncryptionDescriptorV1,
        payloadDigest: Data,
        payloadRepresentation: Data
    ) {
        formatVersion = Self.currentFormatVersion
        snapshotID = metadata.snapshotID
        createdAt = metadata.createdAt
        kind = metadata.kind
        deviceID = metadata.deviceID
        deviceName = metadata.deviceName
        appVersion = metadata.appVersion
        appBuild = metadata.appBuild
        scope = metadata.scope
        self.encryption = encryption
        self.payloadDigest = payloadDigest
        self.payloadRepresentation = payloadRepresentation
    }

    var metadata: BackupMetadataV1 {
        BackupMetadataV1(
            snapshotID: snapshotID,
            createdAt: createdAt,
            kind: kind,
            deviceID: deviceID,
            deviceName: deviceName,
            appVersion: appVersion,
            appBuild: appBuild,
            scope: scope
        )
    }
}

struct BackupPayloadV1: Codable, Equatable, Sendable {
    var gestures: GestureConfigFile
    var settings: PortableSettingsV1?
    var restoredFromSnapshotID: UUID?
}

struct BackupDerivedKey: Equatable, Sendable {
    static let byteCount = 32

    var keyID: UUID
    var salt: Data
    var iterations: Int
    var keyData: Data

    var encryptionDescriptor: BackupEncryptionDescriptorV1 {
        .aes256GCM(
            keyID: keyID,
            salt: salt,
            iterations: iterations
        )
    }
}

struct BackupEncodingResult: Sendable {
    var data: Data
    var envelope: BackupEnvelopeV1
    /// Present for encrypted output so callers can persist it in Keychain.
    var derivedKey: BackupDerivedKey?
}

struct BackupDecodedBackup: Equatable, Sendable {
    var envelope: BackupEnvelopeV1
    var payload: BackupPayloadV1
}
