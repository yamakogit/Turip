//
//  NotificationClient.swift
//  Turip
//
//  Created by 山田航輝 on 2023/10/01.
//

import UIKit

class NotificationClient {
    
    static let shared = NotificationClient()
    
    //MARK: 通知
    //通知許可の取得
    func requestNotification(_ vc: UNUserNotificationCenterDelegate) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]){
                (granted, _) in
                if granted {
                    print("granted 通知")
                    UNUserNotificationCenter.current().delegate = vc
                }
            }
    }
    
    
    //通知 全削除
    func deleteAllNotification() {
        let unc = UNUserNotificationCenter.current()  //設定済の通知の全削除
        unc.removeAllPendingNotificationRequests()
    }
    
    
    //指定時間に通知セット
    func setNotification(title: String, message: String, hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = hour    // 指定した時間(__:00)に設定
        print("通知時刻: \(hour):00")
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: true)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        scheduleRequest(request: request)
    }
    
    
    func setTourNotification(from: Int, to: Int) {
        
        let randomTimeLater = Int.random(in: from..<to) //何分後に送信するか決定
        print("通知:\(randomTimeLater)分後")
        
        let content = UNMutableNotificationContent()
        content.title = "“発見”を見つけよう"
        content.body = "まわりを見回して、\n今見つけた”発見”を写真に収めよう！"
        
        let triggerDate = Calendar.current.date(byAdding: .minute, value: randomTimeLater, to: Date())!
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let identifier = "tourNotification"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        
        scheduleRequest(request: request)
    }
    
    
    func deleteTourNotification() {
        print("通知:削除")
        let identifiers = ["tourNotification"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    
    func scheduleRequest(request: UNNotificationRequest) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("通知エラー")
            } else {
                print("通知設定完了")
            }
        }
    }
    
    
    
}
