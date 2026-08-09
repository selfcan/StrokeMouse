import Foundation

enum SyncProviderKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case githubGist
    case webDAV

    var id: String { rawValue }
}

enum SyncConnectionDescriptor: Codable, Equatable, Sendable {
    case githubGist(gistID: String?)
    case webDAV(baseURL: URL, username: String)

    var provider: SyncProviderKind {
        switch self {
        case .githubGist: .githubGist
        case .webDAV: .webDAV
        }
    }
}

struct SyncConnectionDraft: Sendable {
    var provider: SyncProviderKind
    var gistIDOrURL: String = ""
    var webDAVURL: String = ""
    var webDAVUsername: String = ""
    var deviceName: String
    var scope: SyncScope
    var encryption: BackupEncryptionKind
    var automaticBackupEnabled: Bool
    var confirmsPlaintextRisk = false
    var confirmsExistingGistVisibilityRisk = false
    var confirmsInsecureHTTP = false
    var confirmedInsecureHTTPURL: String?
}

struct SyncSecretChanges: Sendable {
    /// GitHub PAT or WebDAV password. `nil` keeps an existing Keychain value.
    var providerSecret: String?
    /// Required when AES is enabled for the first time or its password changes.
    var encryptionPassword: String?

    init(providerSecret: String? = nil, encryptionPassword: String? = nil) {
        self.providerSecret = providerSecret
        self.encryptionPassword = encryptionPassword
    }
}

struct DecryptionAttempt: Sendable {
    var password: String
    var savesOnThisMac: Bool
}

enum SyncIntent: Sendable {
    case saveConnection(SyncConnectionDraft, SyncSecretChanges)
    case disconnect
    case backupNow
    case loadHistory(BackupHistoryQuery)
    case preview(RemoteBackupID, DecryptionAttempt?)
    case restore(RestoreRequest)
}

enum SyncRestoreMode: Sendable {
    case overwrite
    case merge(
        decisions: BackupMergeDecisions,
        defaultDuplicatePolicy: BackupContentDuplicatePolicy
    )
}

struct RestoreRequest: Sendable {
    var backupID: RemoteBackupID
    var mode: SyncRestoreMode
    var confirmsScriptRisk: Bool
    var confirmsExperimentalTrackpadRisk: Bool
}

enum SyncResult: Sendable {
    case success
    case queued
    case requiresDecryption(RemoteBackupID)
    case failure(String)
}

enum SyncActivity: String, Equatable, Sendable {
    case idle
    case validating
    case backingUp
    case loadingHistory
    case previewing
    case restoring
    case disconnecting
}

struct SyncConnectionSummary: Equatable, Sendable {
    var provider: SyncProviderKind
    var destination: String
    var deviceName: String
    var deviceID: UUID
    var scope: SyncScope
    var encryption: BackupEncryptionKind
    var automaticBackupEnabled: Bool
    var hasStoredProviderSecret: Bool
    var usesInsecureHTTP: Bool
    var gistID: String?
    var webDAVBaseURL: String?
    var webDAVUsername: String?
}

struct SyncOperationRecord: Codable, Equatable, Sendable {
    var date: Date
    var backupID: RemoteBackupID?
    var kind: BackupKind?
}

struct SyncFailureRecord: Equatable, Sendable {
    var date: Date
    var message: String
}

struct SyncState: Equatable, Sendable {
    var connection: SyncConnectionSummary?
    var activity: SyncActivity = .idle
    var hasPendingBackup = false
    var lastSuccess: SyncOperationRecord?
    var lastFailure: SyncFailureRecord?
    var nextHourlyCheck: Date?
    var pendingDecryptionID: RemoteBackupID?
    var lastRollbackURL: URL?

    var isBusy: Bool { activity != .idle }
}

struct BackupHistoryState: Equatable, Sendable {
    var items: [RemoteBackupHistoryItem] = []
    var nextCursor: String?
    var preview: BackupPreviewState?
}

struct RemoteBackupHistoryItem: Identifiable, Equatable, Sendable {
    var id: RemoteBackupID
    var providerCreatedAt: Date
    var byteCount: Int?
    var metadata: BackupMetadataV1?
    var encryption: BackupEncryptionKind?
    var inspectionError: String?
}

struct BackupGestureConflictSummary: Identifiable, Equatable, Sendable {
    var id: UUID
    var localName: String
    var backupName: String
}

struct BackupContentDuplicateSummary: Identifiable, Equatable, Sendable {
    var id: UUID
    var backupName: String
    var matchingLocalName: String
}

struct BackupSettingConflictSummary: Identifiable, Equatable, Sendable {
    var id: String { key }
    var key: String
    var localValue: PortableSettingValue
    var backupValue: PortableSettingValue
}

struct BackupPreviewState: Equatable, Sendable {
    var backupID: RemoteBackupID
    var metadata: BackupMetadataV1
    var localGestureCount: Int
    var backupGestureCount: Int
    var gesturesAddedByMerge: Int
    var gestureConflicts: [BackupGestureConflictSummary]
    var contentDuplicates: [BackupContentDuplicateSummary]
    var settingConflicts: [BackupSettingConflictSummary]
    /// Names only; script bodies must never be exposed through public sync state.
    var privilegedGestureNames: [String]
    var containsExperimentalTrackpadGestures: Bool

    var containsScripts: Bool { !privilegedGestureNames.isEmpty }
}

enum PortableSettingValue: Codable, Equatable, Sendable {
    case bool(Bool)
    case number(Double)
    case string(String)
    case strings([String])
}

enum ConfigurationSyncError: Error, Equatable, Sendable {
    case notConnected
    case operationInProgress
    case providerSwitchRequiresDisconnect
    case invalidDeviceName
    case invalidGistIdentifier
    case invalidWebDAVURL
    case insecureHTTPConfirmationRequired
    case plaintextConfirmationRequired
    case gistVisibilityConfirmationRequired
    case providerSecretRequired
    case encryptionPasswordRequired
    case missingEncryptionKey
    case previewRequired
    case previewOutdated
    case backupMismatch
    case scriptConfirmationRequired
    case experimentalTrackpadConfirmationRequired
    case rollbackFailed(String)
    case restoreFailed(String, rollbackURL: URL)
    case compensationFailed(
        original: String,
        rollback: String,
        rollbackURL: URL
    )
    case localTransactionCompensationFailed
    case invalidStoredConfiguration
}
