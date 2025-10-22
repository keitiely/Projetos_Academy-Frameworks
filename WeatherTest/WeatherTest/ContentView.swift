
//  Created by Keitiely Silva Viana on 20/10/25.
//  ContentView.swift
//  WeatherTest
//
//
import SwiftUI

struct ContentView: View {
    @StateObject private var pushManager = PushManagerViewModel.shared
    @StateObject private var contactsManager = ContactsManager()
    @AppStorage("currentUserPhoneNumber") private var currentUserPhoneNumber: String = ""
    
    @State private var showingSendModal = false
    @State private var showingPhonePrompt = false
    @State private var tempPhoneInput = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Enviar Notificação 💧")
                .font(.title2)
                .bold()
            
            Button("Selecionar Contato e Enviar") {
                if currentUserPhoneNumber.isEmpty {
                    showingPhonePrompt = true
                } else {
                    showingSendModal = true
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingSendModal) {
            SendNotificationModal(
                contactsManager: contactsManager,
                pushManager: pushManager,
                currentUserPhoneNumber: currentUserPhoneNumber
            )
        }
        .alert("Digite seu número de telefone", isPresented: $showingPhonePrompt, actions: {
            TextField("Número de telefone", text: $tempPhoneInput)
            Button("Salvar") {
                let normalized = tempPhoneInput.normalized()
                currentUserPhoneNumber = normalized
                Task {
                    // Cria registro no CloudKit
                    await contactsManager.createUserRecordIfNeeded(phoneNumber: normalized)
                    // Faz subscription
                    pushManager.subscribeToMessages(for: normalized)
                    // Solicita permissão de notificações
                    pushManager.requestNotificationPermission()
                    pushManager.registerDelegate()
                    showingSendModal = true
                }
            }
            Button("Cancelar", role: .cancel) { }
        })
        .onAppear {
            Task {
                await contactsManager.requestContactsPermission()
                
                if !currentUserPhoneNumber.isEmpty {
                    await contactsManager.createUserRecordIfNeeded(phoneNumber: currentUserPhoneNumber)
                    pushManager.subscribeToMessages(for: currentUserPhoneNumber)
                    pushManager.requestNotificationPermission()
                    pushManager.registerDelegate()
                }
            }
        }
    }
}



//import SwiftUI
//import Contacts
//
//struct ContentView: View {
//    @StateObject private var pushManager = PushManagerViewModel.shared
//    @StateObject private var contactsManager = ContactsManager()
//    @AppStorage("currentUserPhoneNumber") private var currentUserPhoneNumber: String = ""
//    @State private var showingSendModal = false
//    
//    var body: some View {
//        Group {
//            if currentUserPhoneNumber.isEmpty {
//                LoginView(currentUserPhoneNumber: $currentUserPhoneNumber)
//            } else {
//                Button("Enviar Notificação") {
//                    showingSendModal = true
//                }
//                .padding()
//                .background(Color.purple)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//            }
//        }
//        .task(id: currentUserPhoneNumber) {
//            guard !currentUserPhoneNumber.isEmpty else { return }
//            await contactsManager.requestContactsPermission()
//            await contactsManager.createUserRecordIfNeeded(phoneNumber: currentUserPhoneNumber)
//            pushManager.subscribeToMessages(for: currentUserPhoneNumber)
//            await contactsManager.fetchAndFilterContacts(currentUserPhoneNumber: currentUserPhoneNumber)
//        }
//        .onAppear {
//            pushManager.requestNotificationPermission()
//            pushManager.registerDelegate()
//        }
//        .sheet(isPresented: $showingSendModal) {
//            SendNotificationModal(
//                contactsManager: contactsManager,
//                pushManager: pushManager,
//                currentUserPhoneNumber: currentUserPhoneNumber
//            )
//        }
//    }
//}

