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
        let notificationCenter = UNUserNotificationCenter.current() // instância central que gerencia todas as notificações do app.
        notificationCenter.getNotificationSettings { (settings) in //Pega as configurações atuais de notificação do usuário.
            switch settings.authorizationStatus {
               // Se permitir, já dispara a notificação.
            case .authorized:
                self.dispatchNotification()
                //Se negou, não faz nada.
            case .denied:
                return
                //Se ainda não decidiu, solicita permissão para mostrar alerta e som.
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow { // se aceitar o didAllow envia notificacao
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
        //configuarando a notificacao
        let identifier = "my-morning-notification"
        let title = "Versículo do Dia!"
        let body = "Josué 1:9 - Seja forte e corajoso! Deus está contigo onde quer que vás."
//        let hour = 19
//        let minute = 45
//        let isDaily = true
        
        // Acessa o centro de notificações
        let notificationCenter = UNUserNotificationCenter.current()
        
        // Cria o conteúdo
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
       // Cria a data de disparo da notificação usando hora e minuto.
//        let calendar = Calendar.current
//        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
//        dateComponents.hour = hour
//        dateComponents.minute = minute
        
    
       // Define quando a notificação será disparada.
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily) //repeats: isDaily significa que será diária.
        
        //Aqui agenda para disparar **5 segundos depois de clicar**
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        
       // Cria a requisição de notificação que o iOS vai agendar.
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        //Remove notificações antigas com o mesmo identifier para não duplicar.
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)//Adiciona a nova requisição ao centro de notificações.
        
        
    }
   // Ação do botão (ligado ao Storyboard) ao clicar inicia a 
    @IBAction func IniciarAgendamento(_ sender: Any) {
     checkForPermission()
        
    }
    
}

