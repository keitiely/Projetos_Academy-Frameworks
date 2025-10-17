//
//  ContentView.swift
//  AppIntentsDemo
//
//  Created by Keitiely Silva Viana on 16/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    @FocusState private var focusedField: FocusedField?
    
    
    var body: some View {
        if #available(iOS 17.0, *) {
            VStack {
                Spacer()
                
                TextField("Email", text: $email)
                    .focused($focusedField, equals: .email)
                
                SecureField("Password", text: $password)
                    .focused($focusedField, equals: .password)
            }
            .textFieldStyle(.roundedBorder)
            .padding()
            .onChange(of: AppIntentsController.shared.focusedField) {
                _, newValue in
                focusedField = newValue
                
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    ContentView()
}
