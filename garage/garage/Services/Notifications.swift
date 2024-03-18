//
//  Notifications.swift
//  garage
//
//  Created by Apple on 5.02.24.
//

import UIKit
import UserNotifications

class Notifications: NSObject, UNUserNotificationCenterDelegate {
    
    enum TriggerType {
        case date(Date)
        case time(TimeInterval)
    }
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        requestAutorization()
        notificationCenter.delegate = self
        
    }
    // MARK: - проверяем настройка доступа к уведомлениям
    func requestAutorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            
            print("Permission granted: \(granted)")
            
            if granted {
                self.getNotificationSettings()
            } else {
                // открыть настройки уведомлений в телефоне
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    // MARK: - метод для получения информации по настройкам уведомлений
    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
        }
    }
    
    // MARK: - метод отвечает за созжание и управление уведомлением
    func scheduleNotification(serviceId: String, title: String, message: String, triggerType: TriggerType) {
        
        let content = UNMutableNotificationContent() // Содержимое уведомления
            
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        switch triggerType {
        case .date(let date):
            let triggerDate = Calendar.current.dateComponents([.year,.month,.day], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(identifier: serviceId, content: content, trigger: trigger)
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error \(error.localizedDescription)")
                }
            }
            
        case .time(let time):
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
            
            let request = UNNotificationRequest(identifier: serviceId, content: content, trigger: trigger)
            notificationCenter.add(request) { error in
                
                if let error = error {
                    print("Error \(error.localizedDescription)")
                }
            }
        }
    }

    //метод по срабатыванию нотификации без сварачивания
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
