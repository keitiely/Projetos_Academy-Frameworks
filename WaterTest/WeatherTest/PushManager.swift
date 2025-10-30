//
//  PushManager.swift
//  WeatherTest
//
//  Created by Keitiely Silva Viana on 20/10/25.
//
import SwiftUI
import UserNotifications
import CloudKit
import Combine


class PushManagerViewModel: NSObject, ObservableObject{
    
    static let shared = PushManagerViewModel()
    
    private var db = CKContainer.default().publicCloudDatabase
    
    
    @Published var lastMessageStatus: String = ""
    
    //Solicitar Permissao
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            
            granted, error in if granted {
                print("Notification Permission Success!")
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification Permission Failure! or error: \(error?.localizedDescription ?? "Desconhecido")") }
        }
    }
    
    
    //Enviar Mensagem
    func sendMessage(senderID: String, receiverID: String, message: String, senderName: String){
        let record = CKRecord(recordType: "Messages")
        
        record["senderID"] = senderID.normalized()
        record["receiverID"] = receiverID.normalized()
        record["message"] = message
        record["senderName"] = senderName
        
        DispatchQueue.global().async {
            self.db.save(record) { _, error in
                DispatchQueue.main.async {
                    
                    if let error = error {
                        self.lastMessageStatus = "Erro: \(error.localizedDescription)"
                    } else {
                        self.lastMessageStatus = "Mensagem enviada!"
                    }
                }
            }
        }
    }
    
    
    //Assinar notificação em tese ele aguarda se chegar notificacao no cloud do usuario ele mostra
    func subscribeToMessages(for userID: String) {
        let normalizedUserID = userID.normalized()
        let subscriptionID = "messages_for_\(normalizedUserID)"
        
        
            
        let predicate = NSPredicate(format: "receiverID == %@", normalizedUserID) //para pegar de acordo com o numero de telefone um id do usuario
        let subscription = CKQuerySubscription(recordType: "Messages",
                                               predicate: predicate,
                                               subscriptionID: subscriptionID,
                                               options: .firesOnRecordCreation)//.firesOnRecordCreation toda vez que criar enviar notificacao
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.titleLocalizationKey = "💧 %@ "
        notificationInfo.titleLocalizationArgs = ["senderName"]
        notificationInfo.alertLocalizationArgs = ["message"]
        notificationInfo.soundName = "default"

        
        subscription.notificationInfo = notificationInfo
        
        db.save(subscription) { _, error in
            if let error = error {
                print("Erro ao criar subscription: \(error)")
            } else {
                print("Subscription criada!")
            }
        }
    }
    
    
    //Delegate da Notificação para mostrar mesmo com app aberto
    func registerDelegate() {
        UNUserNotificationCenter.current().delegate = self
    }
    
    
}


extension PushManagerViewModel: UNUserNotificationCenterDelegate {
    // Notificação quando o app está aberto
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        // Aqui pegamos o campo "message" do CloudKit
        if let ckInfo = userInfo["ck"] as? [String: Any],
           let query = ckInfo["qry"] as? [String: Any],
           let fields = query["f"] as? [String: Any],
           let messageDict = fields["message"] as? [String: Any],
           let message = messageDict["value"] as? String {
            
            
            // Criar notificação local com o corpo real
            let content = UNMutableNotificationContent()
            content.title = "💧 Nova mensagem!"
            content.body = message
            content.sound = .default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString,
                                                content: content,
                                                trigger: nil) // dispara imediatamente
            UNUserNotificationCenter.current().add(request)
        }
        // Mostra banner e toca som
        completionHandler([.banner, .sound])
    }
}
    //#Preview {
    //    PushManager()
    //}

