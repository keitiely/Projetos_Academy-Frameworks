//
//  ContentView.swift
//  CloudKitPushNotifcation
//
//  Created by Keitiely Silva Viana on 15/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CloudKitCrudBootcamp()
                .tabItem {
                    Label("Notas", systemImage: "note.text")
                }
            
            CloudKitPushNotificationBootcamp()
                .tabItem {
                    Label("Notificações", systemImage: "bell")
                }
        }
    }
}

#Preview {
    ContentView()
}
