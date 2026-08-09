import Foundation
import Security

protocol CredentialVault: Sendable {
    func credential(for account: String) async throws -> Data?
    func setCredential(_ credential: Data, for account: String) async throws
    func deleteCredential(for account: String) async throws
}

/// Generic-password Keychain adapter. Entries are explicitly non-synchronizing
/// and device-only so provider credentials never travel with backup content or
/// through iCloud Keychain.
struct KeychainCredentialVault: CredentialVault {
    let service: String
    let accessGroup: String?

    init(service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }

    func credential(for account: String) async throws -> Data? {
        try validate(account: account)
        var query = baseQuery(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw CredentialVaultError.invalidStoredData
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw CredentialVaultError.unexpectedStatus(status)
        }
    }

    func setCredential(
        _ credential: Data,
        for account: String
    ) async throws {
        try validate(account: account)
        guard !credential.isEmpty else {
            throw CredentialVaultError.emptyCredential
        }

        let query = baseQuery(account: account)
        let update: [String: Any] = [
            kSecValueData as String: credential,
            kSecAttrAccessible as String:
                kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        var status = SecItemUpdate(
            query as CFDictionary,
            update as CFDictionary
        )
        if status == errSecItemNotFound {
            var item = query
            update.forEach { item[$0.key] = $0.value }
            status = SecItemAdd(item as CFDictionary, nil)
        }
        guard status == errSecSuccess else {
            throw CredentialVaultError.unexpectedStatus(status)
        }
    }

    func deleteCredential(for account: String) async throws {
        try validate(account: account)
        let status = SecItemDelete(baseQuery(account: account) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw CredentialVaultError.unexpectedStatus(status)
        }
    }

    private func baseQuery(account: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any,
        ]
        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        return query
    }

    private func validate(account: String) throws {
        guard !service.isEmpty else {
            throw CredentialVaultError.emptyService
        }
        guard !account.isEmpty else {
            throw CredentialVaultError.emptyAccount
        }
    }
}

actor InMemoryCredentialVault: CredentialVault {
    private var credentials: [String: Data]

    init(credentials: [String: Data] = [:]) {
        self.credentials = credentials
    }

    func credential(for account: String) throws -> Data? {
        try validate(account: account)
        return credentials[account]
    }

    func setCredential(_ credential: Data, for account: String) throws {
        try validate(account: account)
        guard !credential.isEmpty else {
            throw CredentialVaultError.emptyCredential
        }
        credentials[account] = credential
    }

    func deleteCredential(for account: String) throws {
        try validate(account: account)
        credentials.removeValue(forKey: account)
    }

    private func validate(account: String) throws {
        guard !account.isEmpty else {
            throw CredentialVaultError.emptyAccount
        }
    }
}

enum CredentialVaultError: Error, Equatable, Sendable {
    case emptyService
    case emptyAccount
    case emptyCredential
    case invalidStoredData
    case unexpectedStatus(OSStatus)
}
