//
//  CustomAppDelegate.swift
//  Push Notification2
//
//  Created by Keitiely Silva Viana on 12/10/25.
//

import SwiftUI
import UserNotifications

class CustomAppDelegate: NSObject, UIApplicationDelegate {
    var app: Push_Notification2App?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.registerForRemoteNotifications()//aplicativo ira se notifcar por notificacao remota
        
        UNUserNotificationCenter.current().delegate = self //delegado pelo notification
        
        return true
    }
    //registrar notificacoes pelo token do dispositivo
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()//pega os dados do token e converte em uma string hexadecimal
        print("Token String: \(tokenString)")
        
    }
}

extension CustomAppDelegate: UNUserNotificationCenterDelegate { //extensao para o nosso center notificacao do delegate
    //toda vez que tocar em uma notificacao ele executara esse método aqui
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print("Notification title", response.notification.request.content.title)
    }
    //esse metodo permite exibir notificacao mesmo estando dentro do app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return[.badge, .banner, .list, .sound]
    }
    
}
    
