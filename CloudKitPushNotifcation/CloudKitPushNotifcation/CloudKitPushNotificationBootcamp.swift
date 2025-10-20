//
//  CloudKitPushNotificationBootcamp.swift
//  CloudKitPushNotifcation
//
//  Created by Keitiely Silva Viana on 16/10/25.
//

import SwiftUI
import Combine
import CloudKit
import UserNotifications

class CloudKitPushNotificationBootcampViewModel: ObservableObject {
    
    //solicita permissao
    func requestNotificationPermission(){
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options){ sucess, error in
        if let error = error {
                print(error)
            } else if sucess {
                print("Notification Permission Success!")
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
              
            } else{
                print("Notification Permission Failure!")
            }
        
        }
        
    }
    //assina notificacao
    func subscribeToNotifications(){
        
        let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(recordType: "Notes", predicate: predicate, subscriptionID: "note_add_to_database", options: .firesOnRecordCreation) //.firesOnRecordCreation toda vez que criar enviar notificacao
        
        //aparencia da notificacao
        let notification = CKSubscription.NotificationInfo()
        notification.title = ("There's a new Note!")
        notification.alertBody = ("Open the app to check your fruits.")// mostra o texto da nota
        notification.soundName = "default"
      
        
        subscription.notificationInfo = notification
        
        //salvar no banco
     CKContainer.default().publicCloudDatabase.save(subscription) { returnedSubscription, returnedError in
            if let error = returnedError {
                print(error)
            } else {
                print("Successfuly subscribed to notifications!")
            }
        }
    }
    
    func unsubscribeToNotifications(){
        
        CKContainer.default().publicCloudDatabase.delete(withSubscriptionID: "note_add_to_database") { returnedID, returnedError in
            if let error = returnedError {
                print(error)
            } else {
                print("Sucessfuly unsubscribed!")
            }
            
        }
    }
    
}

struct CloudKitPushNotificationBootcamp: View {
    
    @StateObject private var vm = CloudKitPushNotificationBootcampViewModel()
    var body: some View {
        
        VStack(spacing: 40){
            
            Button("Request Notification Permission"){
                vm.requestNotificationPermission()
            }
            
            Button("Subscribe to Notifications"){
                vm.subscribeToNotifications()
            }
            
            Button("Unsubscribe to Notifications"){
                vm.unsubscribeToNotifications()
            }
        }
        
    }
}

#Preview {
    CloudKitPushNotificationBootcamp()
}
