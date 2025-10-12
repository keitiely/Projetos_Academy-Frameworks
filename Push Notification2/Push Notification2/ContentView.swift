//
//  ContentView.swift
//  Push Notification2
//
//  Created by Keitiely Silva Viana on 12/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button("Request For Push Notification"){
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
