//
//  AppIntentsController.swift
//  AppIntentsDemo
//
//  Created by Keitiely Silva Viana on 16/10/25.
//

import SwiftUI

@available(iOS 17.0, *)
@Observable
class AppIntentsController{
    static let shared = AppIntentsController()
    
    var focusedField: FocusedField = .nome
}
