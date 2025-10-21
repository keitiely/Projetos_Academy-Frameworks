//
//  ContentView.swift
//  WeatherTest
//
//  Created by Keitiely Silva Viana on 20/10/25.
//

import SwiftUI
import Contacts

struct ContentView: View {
    @StateObject private var pushManager = PushManagerViewModel.shared
    @StateObject private var contactsManager = ContactsManager()
    
    // MUDANÇA 1: Precisamos saber quem é o usuário atual.
    // No seu app final, você pegará isso de um login ou pedirá ao usuário.
    // Por enquanto, vamos usar um valor fixo para teste.
    private let currentUserPhoneNumber = "997464017" // <-- SUBSTITUA PELO SEU NÚMERO DE TESTE
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Status: \(pushManager.lastMessageStatus)")
                .padding()
            
            Text("Amigos no App:")
                .font(.headline)
            
            // MUDANÇA 2: A UI agora reage ao estado do ContactsManager.
            if contactsManager.isLoading {
                ProgressView() // Mostra um "rodando" enquanto busca...
            } else if contactsManager.activeContacts.isEmpty {
                // ...mostra uma mensagem se não encontrar ninguém...
                Text("Nenhum contato seu está usando o app ainda.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                // ...ou mostra a lista se encontrar amigos.
                List(contactsManager.activeContacts, id: \.identifier) { contact in
                    Button(action: {
                        // MUDANÇA 3: Usamos os dados reais para enviar a notificação.
                        let phone = contact.phoneNumbers.first!.value.stringValue
                        print("Enviando para: \(phone)")
                        pushManager.sendMessage(
                            senderID: currentUserPhoneNumber, // Quem está enviando
                            receiverID: phone,               // Para quem vai
                            message: "Lembrete do seu amigo para beber água! 💧"
                        )
                    }) {
                        Text("\(contact.givenName) \(contact.familyName)")
                    }
                }
            }
        }
        // MUDANÇA 4: Usamos .task para o trabalho pesado e assíncrono.
        .task {
            // Esta é a sequência de inicialização do app
            await contactsManager.requestContactsPermission()
            await contactsManager.createUserRecordIfNeeded(phoneNumber: currentUserPhoneNumber)
            pushManager.subscribeToMessages(for: currentUserPhoneNumber)
            await contactsManager.fetchAndFilterContacts()
        }
        // Deixamos o .onAppear para tarefas rápidas e síncronas.
        .onAppear {
            pushManager.requestNotificationPermission()
            pushManager.registerDelegate()
        }
    }
}

#Preview {
    ContentView()
}

