//
//  ContentView.swift
//  FoundationModelsEstruturado
//
//  Created by Keitiely Silva Viana on 13/10/25.
//

import SwiftUI
import FoundationModels

struct Cidade{
    let name: String
    let population: Int
    let culture: [String]
    
}
struct ContentView: View {
    @State var question = 
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
