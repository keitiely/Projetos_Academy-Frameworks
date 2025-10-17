//
//  FocusTextFieldIntent.swift
//  AppIntentsDemo
//
//  Created by Keitiely Silva Viana on 16/10/25.
//

import AppIntents

struct FocusTextFieldIntent: AppIntent {
    
    
    static var title = LocalizedStringResource ("Focus Text Field")
    static var description = IntentDescription ("Enter your credencial")
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Focused Field") var focusedField: String
    
    func perform() async throws -> some IntentResult{
        if #available(iOS 17.0, *) {
            DispatchQueue.main.async(){
                AppIntentsController.shared.focusedField = FocusedField(rawValue: focusedField.lowercased())!
            }
                } else {
            // Fallback on earlier versions
        }
        return .result()
    }
    
}
