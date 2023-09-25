//
//  TutorialHealthViewController.swift
//  Turip
//
//  Created by 山田航輝 on 2023/09/08.
//

// MARK: チュートリアルで全アクセスを要求

import UIKit
import HealthKit
import CoreMotion
import CoreLocation

class TutorialAccessVC: UIViewController, CLLocationManagerDelegate {
    
    
    let healthStore = HKHealthStore()
    let pedometer = CMPedometer()
    let locationManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: HealthKit 許可
        let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .stepCount)!]
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if success {
                print("HealthKit authorization success!")
            } else {
                print("HealthKit authorization denied.")
            }
        }
        
        
        //MARK: CMPedometer 許可
        //データ取ろうとすると勝手に許可メッセ出す
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { (data, error) in
                if let error = error {
                    print("Steps Access is denied.\nAn error occurred: \(error.localizedDescription)")
                    return
                }
                
                if let data = data {
                    print("Steps Access is granted.")
                }
            }
        }
        
        
        //MARK: 位置情報 許可ダイアログ
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        
        //MARK: 通知許可 ダイアログ
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge] //オプション
        //ダイアログ表示
        center.requestAuthorization(options: options) { (granted, error) in
            if granted {
                print("Notification authorization granted.")
            } else {
                print("Notification authorization denied.")
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
