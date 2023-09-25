//
//  loginVC.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/10.
//

import UIKit
import Firebase
import FirebaseAuth

class signupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mailTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    
    var mailAdress: String = ""
    var userName: String = ""
    var password: String = ""
    
    var date = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        let tfArray = [mailTF,nameTF,passTF]
        for tf in 0...2 {
            let electedTf = tfArray[tf]
            electedTf?.delegate = self
            electedTf?.tag = tf
            electedTf?.addTarget(self, action: #selector(signupViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
            //UIControl.Event.editingChangedの時#selector呼び出し
        }
        
        passTF.isSecureTextEntry = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        date = dateFormatter.string(from: Date())
        
        //Placeholder設定(文字と色)
        mailTF.attributedPlaceholder = NSAttributedString(string: "Enter MailAdress...",
                                                          attributes: [NSAttributedString.Key.foregroundColor: Asset.colorGray.color])
        nameTF.attributedPlaceholder = NSAttributedString(string: "Enter UserName...",
                                                          attributes: [NSAttributedString.Key.foregroundColor: Asset.colorGray.color])
        passTF.attributedPlaceholder = NSAttributedString(string: "Enter Password...",
                                                          attributes: [NSAttributedString.Key.foregroundColor: Asset.colorGray.color])
        
        // Do any additional setup after loading the view.
    }
    
    
    //TF
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() //キーボードを閉じる
        return true //戻り値
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField.tag == 0 {
            mailAdress = textField.text!
            print("mailAdress: \(mailAdress)")
            
        } else if textField.tag == 1 {
            userName = textField.text!
            print("userName: \(userName)")
            
        } else if textField.tag == 2 {
            password = textField.text!
            print("password: \(password)")
        }
    }
    
    
    @IBAction func login() {
        
        //入力項目の確認...
        var confirmBool = true
        let confirmDict = ["メールアドレス":mailAdress,"ユーザー名":userName,"パスワード":password]
        for (key, value) in confirmDict {
            if value == "" {
                confirmBool = false
                AlertHost.alertDef(view: self ,title: "\(key)が\n正しく入力されていません", message: "\(key)を\nもう一度入れ直してください。")
                print("error: \(key) is not found.")
            }
        }
        
        if password.count < 7 {
            confirmBool = false
            AlertHost.alertDef(view: self,title: "弱いパスワードです", message: "このパスワードは文字数が少なすぎます。\n最低7文字以上入力してください。")
            print("error: password is weak.")
        }
        
        if confirmBool {
            OtherHosts.activityIndicatorView(view: self.view).startAnimating()
            Auth.auth().createUser (withEmail: mailAdress, password: password) {
                authResult, error in
                print("succeed: signup_createUser")
                if let user = authResult?.user { // authResult?.userでuidが
                    OtherHosts.activityIndicatorView(view: self.view).stopAnimating()
                    print(user)
                    
                    
                    Task {
                        do {
//                            try await FirebaseClient.shared.saveLatestOpenedDatetoUser()
                            try await FirebaseClient.shared.saveUserDatas(currentCoordinateDict: ["lat": "35.675079", "lng": "139.759599"], name: self.userName)
                            DispatchQueue.main.async {
                                print("全登録作業完了")
                                
                                //MARK: 遷移
                                let tutorialPageVC = TutorialPageViewController()
                                tutorialPageVC.comeFrom = "signup"
                                self.navigationController?.pushViewController(tutorialPageVC, animated: true)
                                
                                dump(user)
                            }
                            
                        } catch {
                            print("Error fetching spot data5/6: \(error)")
                            DispatchQueue.main.async {
                            }
                        }
                    }
                    
                    
                } else {
                    dump(error)
                    print("エラー")
                    OtherHosts.activityIndicatorView(view: self.view).stopAnimating()  //AIV
                    AlertHost.alertDef(view: self,title: "エラー", message: "以下のいずれかに該当します\n・パスワードが明らかに脆弱\n・無効なメールアドレスをしようしている\n・メールアドレスがすでに使われている\nもう一度ご確認の上、ご登録ください。")
                    print("error: unknown error happend.")
                    //
                }
                
            }
        }
        
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
