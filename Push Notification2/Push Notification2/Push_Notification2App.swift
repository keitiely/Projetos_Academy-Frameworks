//
//  Push_Notification2App.swift
//  Push Notification2
//
//  Created by Keitiely Silva Viana on 12/10/25.
//

import SwiftUI

@main
struct Push_Notification2App: App {
    //conectar o delegate com o app swift ui
    @UIApplicationDelegateAdaptor var appDelegate: CustomAppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            //adicionando um modificador onApear para dizer que o nosso appDelegate é igual ao aplicativo
                .onAppear {
                    appDelegate.app = self
                }
        }
    }
}
