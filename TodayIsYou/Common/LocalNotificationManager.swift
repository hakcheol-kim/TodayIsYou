//
//  LocalNotificationManager.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/30.
//

import Foundation
import UserNotifications
import UIKit

struct LocalNotification {
    var id: String
    var title: String
    var body: String
}
enum LocalNotificationDurationType {
    case days, hours, minutes, seconds
}

class LocalNotificationManager {
    static private var notificaions = [LocalNotification]()
    
    static private func requestPermission() ->Void {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted == true && error == nil {
                
            }
        }
    }
    static private func scheduleNotifications(_ durationSeconds:Int, repeats:Bool, userInfo:[AnyHashable:Any]) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        for notification in notificaions {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = UNNotificationSound.default
            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
            content.userInfo = userInfo
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(durationSeconds), repeats: repeats)
            let request = UNNotificationRequest.init(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else { return }
                print("scheduling notification with id: \(notification.id)")
            }
        }
        notificaions.removeAll()
    }
    static private func addNotification(title:String, body:String) ->Void {
        notificaions.append(LocalNotification(id: UUID().uuidString, title: title, body: body))
    }
    static private func scheduleNotifications(_ duration:Int, of type:LocalNotificationDurationType, repeats:Bool, userInfo:[AnyHashable:Any]) {
        var seconds = 0
        switch type {
        case .seconds:
            seconds = duration
        case .minutes:
            seconds = duration * 60
        case .hours:
            seconds = duration * 60 * 60
        case .days:
            seconds = duration * 60 * 60 * 24
        }
        scheduleNotifications(seconds, of: type, repeats: repeats, userInfo: userInfo)
    }
    
    static func cancel() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    static func setNotification(_ duration: Int, of type:LocalNotificationDurationType, repeats:Bool, title:String, body:String, userInfo:[AnyHashable:Any]) {
        requestPermission()
        addNotification(title: title, body: body)
        scheduleNotifications(duration, of: type, repeats: repeats, userInfo: userInfo)
    }
}
