//
//  teste.swift
//  TestFoundationModels
//
//  Created by Keitiely Silva Viana on 13/10/25.
//

import Playgrounds
import FoundationModels

#Playground {
    if #available(iOS 26.0, *) {
        let session = LanguageModelSession()
        let response = try await session.respond(to: "create an intinary")
    }
  
    
}
