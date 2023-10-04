//
//  NetworkMonitor.swift
//  Turip
//
//  Created by 山田航輝 on 2023/10/01.
//

import Network
import UIKit

class NetworkMonitor {
    
    
    var monitor: NWPathMonitor?
    var queue: DispatchQueue?
    
    init(_ view: UIViewController) {
        self.monitor = NWPathMonitor()
        self.queue = DispatchQueue(label: "Monitor")
        
        self.monitor?.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connected") //接続あり
                
            } else {
                print("No Connection") //接続なし
                AlertHost.alertDef(view: view, title: "インターネット接続なし", message: "インターネット接続がないため、\nTourismモードは使用できません。")
            }
        }
        
            self.monitor?.start(queue: self.queue!)
        }
    
    
}
