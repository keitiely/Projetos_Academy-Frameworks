//
//  ContactsManager.swift
//  WeatherTest
//
//  Created by Keitiely Silva Viana on 21/10/25.
//

@preconcurrency import Contacts
import ContactsUI
import Combine
import CloudKit

@MainActor
class ContactsManager: NSObject, ObservableObject {
    @Published var activeContacts: [CNContact] = []
    @Published var isLoading = false
    @Published var permissionGranted = false
    
    private let container = CKContainer.default()
    private let publicDB = CKContainer.default().publicCloudDatabase //conatainer de contatos
    private let store = CNContactStore()
    
    // Pede permissão e atualiza o estado
    func requestContactsPermission() async {
        do {
            let granted = try await store.requestAccess(for: .contacts)
            self.permissionGranted = granted
        } catch {
            print("Erro ao pedir permissão de contatos: \(error.localizedDescription)")
            self.permissionGranted = false
        }
    }
    
    //  A função principal que orquestra tudo
    func fetchAndFilterContacts() async {
        guard permissionGranted else {
            print("Permissão de contatos negada. Não é possível buscar.")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Busca todos os contatos do telefone
            let allContacts = try await fetchContactsFromDevice()
            
            // Pega apenas os números de telefone normalizados
            let phoneNumbers = allContacts.compactMap { $0.phoneNumbers.first?.value.stringValue }.map { normalizePhone($0) }
            guard !phoneNumbers.isEmpty else { return }
            
            // Descobre quais desses telefones existem no CloudKit
            let activePhoneNumbers = try await discoverActiveUsers(with: phoneNumbers)
            
            print("Todos os contatos do telefone (normalizados): \(phoneNumbers)")
            print("Contatos ativos do CloudKit: \(activePhoneNumbers)")
            
            // Filtra a lista de contatos original para mostrar apenas os ativos
            self.activeContacts = allContacts.filter { contact in
                guard let phone = contact.phoneNumbers.first?.value.stringValue else { return false }
                return activePhoneNumbers.contains(normalizePhone(phone))
            }
            print("Contatos ativos encontrados: \(self.activeContacts.count)")
        } catch {
            print("Falha no processo de buscar e filtrar contatos: \(error.localizedDescription)")
        }
    }
    
    
    // Função interna para buscar contatos do dispositivo
    private nonisolated func fetchContactsFromDevice() async throws -> [CNContact] {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var contacts: [CNContact] = []
                let store = CNContactStore()
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)
                
                do {
                    try store.enumerateContacts(with: request) { contact, _ in
                        if !contact.phoneNumbers.isEmpty {
                            contacts.append(contact)
                        }
                    }
                    continuation.resume(returning: contacts)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    // Função interna que pergunta ao CloudKit quais usuários existem
    private func discoverActiveUsers(with phoneNumbers: [String]) async throws -> Set<String> {
        let predicate = NSPredicate(format: "phoneNumber IN %@", phoneNumbers)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        // No CloudKit
        let (matchResults, _) = try await publicDB.records(matching: query)
        
        // Extrai os números de telefone dos resultados
        let activePhoneNumbers = matchResults.compactMap { _, result in
            switch result {
            case .success(let record):
                return record["phoneNumber"] as? String
            case .failure:
                return nil
            }
        }
        
        return Set(activePhoneNumbers)
    }
    
    // Salva o registro do usuário atual no CloudKit
    // Chama isso uma vez quando o usuário configurar o app
    func createUserRecordIfNeeded(phoneNumber: String) async {
        let normalizedPhoneNumber = normalizePhone(phoneNumber)
        let recordID = CKRecord.ID(recordName: normalizedPhoneNumber)
        
        // Verifica se o usuário já existe
        if let _ = try? await publicDB.record(for: recordID) {
            print("Registro de usuário já existe para o telefone: \(normalizedPhoneNumber)")
            return
        }
        
        let userRecord = CKRecord(recordType: "User", recordID: recordID)
        userRecord["phoneNumber"] = normalizedPhoneNumber
        
        do {
            try await publicDB.save(userRecord)
            print("Registro de usuário salvo com sucesso!")
        } catch {
            print("Erro ao salvar registro de usuário: \(error.localizedDescription)")
        }
    }
    
    
    
    func normalizePhone(_ phone: String) -> String {
        // Remove tudo que não for número
        return phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
}

//
//#Preview {
//    ContactsManager()
//}
