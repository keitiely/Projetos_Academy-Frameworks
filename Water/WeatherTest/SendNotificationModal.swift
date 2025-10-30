//
//  SendNotificationModal.swift
//  WeatherTest
//
//  Created by Keitiely Silva Viana on 21/10/25.
//

import SwiftUI
import Contacts

struct SendNotificationModal: View {
    @ObservedObject var contactsManager: ContactsManager
    @ObservedObject var pushManager: PushManagerViewModel
    @State private var selectedContact: CNContact? = nil
    
    let currentUserPhoneNumber: String
    
    @State private var message: String = ""
    @State private var showPicker = false
    @Environment(\.dismiss) private var dismiss
    

    var body: some View {
        VStack(spacing: 20) {
            TextField("Digite a mensagem", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button {
                showPicker = true
            } label: {
                HStack {
                    Image(systemName: "person.crop.circle.badge.plus")
                    Text(selectedContact != nil ?
                         "\(selectedContact!.givenName) \(selectedContact!.familyName)" :
                         "Selecionar Contato")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple.opacity(0.9))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .sheet(isPresented: $showPicker) {
                ContactPickerView { contact in
                    selectedContact = contact
                }
            }
            
            Button("Enviar Notificação") {
                sendMessage()
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedContact == nil ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(selectedContact == nil)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Enviar Notificação") // Adicionado
        .toolbar { // Adicionado
            ToolbarItem(placement: .cancellationAction) {
                Button("Fechar") { dismiss() }
            }
        }
        
        
    }
    
    private func sendMessage() {
        guard let contact = selectedContact,
              let phone = contact.phoneNumbers.first?.value.stringValue else { return }
        
        let normalizedPhone = phone.normalized()
        let name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
        
        Task {
            // 3. VERIFICA SE O AMIGO EXISTE
            let isActive = await contactsManager.isUserActive(phoneNumber: normalizedPhone)
            
            if isActive {
                // 4. USA O NÚMERO DE QUEM FEZ LOGIN
                pushManager.sendMessage(
                    senderID: currentUserPhoneNumber,
                    receiverID: normalizedPhone,
                    message: message.isEmpty ? "Lembrete do seu amigo 💧" : message,
                    senderName: name.isEmpty ? currentUserPhoneNumber : name
                )
            } else {
                print("⚠️ Usuário não encontrado no CloudKit: \(normalizedPhone)")
                // Aqui você pode adicionar um alerta para o usuário
            }
        }
    }
}
