//
//  SettingsViewController.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/25.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                let userData = try await FirebaseClient.shared.getUserData()
                
                DispatchQueue.main.async {
                    let userName = userData.name
                    self.userNameLabel.text = userName
                }
                
            } catch {
                print("Error fetching spot data: \(error)")
                DispatchQueue.main.async {
                    //失敗
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logout() {
        
        
        AlertHost.alertDoubleDef(view: self, alertTitle: "ログアウトしますか？", alertMessage: "一度ログアウトすると、\n再ログインするまで使用できません。", b1Title: "ログアウト", b1Style: .destructive, b2Title: "キャンセル") { _ in
            
            OtherHosts.activityIndicatorView(view: self.view).startAnimating()
            
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                
                OtherHosts.activityIndicatorView(view: self.view).stopAnimating()
                AlertHost.alertDef(view: self, title: "ログアウト完了", message: "トップページへ戻ります") { _ in
                    
                    UserDefaults.standard.removeObject(forKey: "todaySteps")
                    UserDefaults.standard.removeObject(forKey: "calculatedDistance")
                    UserDefaults.standard.removeObject(forKey: "goalUID")
                    UserDefaults.standard.removeObject(forKey: "newCoordinate")
                    
                    guard let window = UIApplication.shared.keyWindow else { return }
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    if window.rootViewController?.presentedViewController != nil {
                        // モーダルを開いていたら閉じてから差し替え
                        window.rootViewController?.dismiss(animated: true) {
                            window.rootViewController = storyboard.instantiateViewController(withIdentifier: "register") as! UINavigationController
                        }
                    } else {
                        // モーダルを開いていなければそのまま差し替え
                        window.rootViewController = storyboard.instantiateViewController(withIdentifier: "register") as! UINavigationController
                    }
                }
                
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
                OtherHosts.activityIndicatorView(view: self.view).stopAnimating()
                AlertHost.alertDef(view:self, title: "エラー", message: "ログアウトに失敗しました")
            }
        }
        
        
    }
    
    @IBAction func deleteAccount() {
        
            AlertHost.alertDoubleDef(view: self, alertTitle: "アカウント削除しますか？", alertMessage: "アカウントを削除すると、再度ログインするまでアプリを利用できません。", b1Title: "アカウント削除", b1Style: .destructive, b2Title: "キャンセル") { _ in
                
                OtherHosts.activityIndicatorView(view: self.view).startAnimating()
                
                UserDefaults.standard.removeObject(forKey: "todaySteps")
                UserDefaults.standard.removeObject(forKey: "calculatedDistance")
                UserDefaults.standard.removeObject(forKey: "goalUID")
                UserDefaults.standard.removeObject(forKey: "newCoordinate")
                
                let user = Auth.auth().currentUser
                user?.delete { error in
                    if error != nil {
                        // An error happened.
                        OtherHosts.activityIndicatorView(view: self.view).stopAnimating()
                        AlertHost.alertDef(view:self, title: "エラー", message: "アカウント削除に失敗しました")
                        
                    } else {
                        // Account deleted.
                        OtherHosts.activityIndicatorView(view: self.view).stopAnimating()
                        AlertHost.alertDef(view: self, title: "アカウント削除完了", message: "トップページへ戻ります") { _ in
                            guard let window = UIApplication.shared.keyWindow else { return }
                            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            if window.rootViewController?.presentedViewController != nil {
                                // モーダルを開いていたら閉じてから差し替え
                                window.rootViewController?.dismiss(animated: true) {
                                    window.rootViewController = storyboard.instantiateInitialViewController()
                                }
                            } else {
                                // モーダルを開いていなければそのまま差し替え
                                window.rootViewController = storyboard.instantiateInitialViewController()
                            }
                        }
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
