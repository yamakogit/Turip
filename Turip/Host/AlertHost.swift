//
//  AlertHost.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/12.
//

import UIKit

class AlertHost {
    
    //1ボタン
    static func alertDef(view: UIViewController, title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        view.present(alertVC, animated: true)
    }
    
    //2ボタン
    static func alertDoubleDef(view: UIViewController, alertTitle: String, alertMessage: String, b1Title: String, b1Style: UIAlertAction.Style, b2Title: String, b1Handler: ((UIAlertAction) -> Void)? = nil) {
        let alertVC = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: b1Title, style: b1Style, handler: b1Handler))
        alertVC.addAction(UIAlertAction(title: b2Title, style: .cancel, handler: nil))
        view.present(alertVC, animated: true)
    }

    //TF付きAlert
    static func alertTF(view: UIViewController, alertTitle: String, alertMessage: String, tfPlaceText: String, b1Title: String, b1Style: UIAlertAction.Style, b2Title: String, b1Handler: ((UIAlertAction, String?) -> Void)? = nil) {
        let alertVC = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        alertVC.addTextField { (textField) in
            textField.placeholder = tfPlaceText
        }
        
        let b1Action = UIAlertAction(title: b1Title, style: b1Style) { (action) in
            let textFieldText = alertVC.textFields?.first?.text
            b1Handler?(action, textFieldText)
        }
        
        alertVC.addAction(b1Action)
        alertVC.addAction(UIAlertAction(title: b2Title, style: .cancel, handler: nil))
        view.present(alertVC, animated: true)
    }
    
    
}
