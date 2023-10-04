//
//  TourismViewController.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/06.
//

import UIKit

class TourismTimeViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        
    }
    
    
    
    @IBAction func tapTimebuttons(_ sender: UIButton) {
        NotificationClient.shared.requestNotification(self) //許可を求める
        let buttonTag = sender.tag
        
        if buttonTag == 1 { //5分間
            NotificationClient.shared.setTourNotification(from: 1, to: 5)
            
        } else if buttonTag == 2 { //15分間
            NotificationClient.shared.setTourNotification(from: 3, to: 15)
            
        } else if buttonTag == 3 { //30分間
            NotificationClient.shared.setTourNotification(from: 8, to: 25)
        }
        
        self.performSegue(withIdentifier: "startTourism", sender: self)
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
