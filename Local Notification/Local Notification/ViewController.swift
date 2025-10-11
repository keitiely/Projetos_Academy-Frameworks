//
//  ViewController.swift
//  Local Notification
//
//  Created by Keitiely Silva Viana on 11/10/25.
//

import UIKit
import UserNotifications // Framework de Notificações

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    //verificar permissao
    func checkForPermission(){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatchNotification()
            case .denied:
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
                        self.dispatchNotification()
                    }
                    
                }
            default :
                return
            }
        }
    }
    
    //enviar notificacao
    func dispatchNotification(){
        let identifier = "my-morning-notification"
        let title = "Versículo do Dia!"
        let body = "Josué 1:9 - Seja forte e corajoso! Deus está contigo onde quer que vás."
        let hour = 19
        let minute = 41
        let isDaily = true
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)
        
        
    }
    
    @IBAction func IniciarAgendamento(_ sender: Any) {
     checkForPermission()
        
    }
    
}

