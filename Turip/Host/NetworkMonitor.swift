//
//  NetworkMonitor.swift
//  Turip
//
//  Created by 山田航輝 on 2023/10/01.
//

import Network
import UIKit

class NetworkMonitor {
    
    
    var queue: DispatchQueue?
    
    static func checkMonitor(view: UIViewController) {
        var monitor = NWPathMonitor()
        var queue = DispatchQueue(label: "Monitor")
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connected") //接続あり
                
            } else {
                print("No Connection") //接続なし
                AlertHost.alertDef(view: view, title: "インターネット接続なし", message: "インターネット接続がないため、\nTourismモードは使用できません。")
                
            }
        }
        
        monitor.start(queue: queue)
    }

    
}
