//
//  AppDelegate.swift
//  RunMapGB
//
//  Created by emil kurbanov on 27.04.2022.
//

import UIKit
import GoogleMaps
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyDZwCvimIW30M_Qyj3Zr9NSpBxeNoLshtQ")
        requestCenter()
      
        return true
    }

    // MARK: NotificationCenter
    func requestCenter() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
          
            guard granted else {
                print("Ошибка")
                return
            }
       
            guard let self = self else { return }
            
            // TODO: Content
        let content = self.createContent()
            // TODO: Triger
        let triger = self.createTriger()
        
        self.sendNotificationRequest(content: content, trigers: triger)
        
    }
    }
    
    func createContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Открой приложение"
        content.subtitle = "Ты давно его не открывал"
        content.body = "Посмотри свою Геолокацию!"
        content.badge = 3
        return content
    }
    
    func createTriger() -> UNNotificationTrigger {
        //1 Вариант показа (30 минут - 1800 секунд!)
        UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: false)
        // Второй вариант!
        /*var dateInfo = DateComponents()
        dateInfo.minute = 30
        return UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)*/
        
    }
    
    func sendNotificationRequest(content: UNNotificationContent, trigers: UNNotificationTrigger) {
        let request = UNNotificationRequest(identifier: "timeNotification", content: content, trigger: trigers)
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
            print(error.localizedDescription)
                
            }
        }
            
    }
}
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    

    

   /* func applicationDidEnterBackground(_ application: UIApplication) {
        self.view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
    }*/
        

        





