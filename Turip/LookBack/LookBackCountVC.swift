//
//  LookBackStepVC.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/09.
//

import UIKit
import MapKit

class LookBackCountViewController: UIViewController {
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    var timer: Timer?
    var secondsCount = 3
    var time: String = ""
    
    var userPlace: String = "東京都"
    
    var nextSpotUID: String = ""
    
    var type = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        //time
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(downTimer), userInfo: nil, repeats: true)
        updatetimeUI() //タイマーボタンLabel 適正表示
        
        
        //準備 - 葉の色
        let todaySteps = UserDefaults.standard.integer(forKey: "todaySteps")
        if todaySteps >= 8000 {
            type = 2
        } else {
            type = 1
        }
        
        
        //準備 - 日付の選出
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let date = dateFormatter.string(from: Date())
        
        
        FirebaseClient().getMatchingUIDArray(key: "place", value: userPlace) { (uids, error) in
            if let error = error {
                print("エラー: \(error)")
                AlertHost.alertDef(view: self,title: "エラー", message: "今日のSpot取得に失敗しました1")
                
            } else if let uids = uids {
                print("条件に合致するUIDArray: \(uids)")
                
                if let randomElement = uids.randomElement() {
                    //NextSpotの設定
                    self.nextSpotUID = randomElement
                    
                    Task {
                        do {
                            //SpotのUserへの追加
                            try await FirebaseClient.shared.saveSpotDatatoUser(spotUID: self.nextSpotUID, date: date, type: "\(self.type)")
                            
                        }
                        catch {
                            print("EROOROR")
                            print(error.localizedDescription)
                            AlertHost.alertDef(view: self, title: "エラー(code:2)", message: "しばらく経ってから\nやり直してください")
                        }
                    }
                    
                    
                    
                    
                } else {
                    print("配列が空")
                    AlertHost.alertDef(view: self,title: "海の上に到着", message: "海上に到着しました。\n海上では、Spotをゲットすることができません。")
                }
                
            }
        }
        
    }
    
    
    func updatetimeUI() {
        if secondsCount == 0 {
            timer?.invalidate()
            performSegue(withIdentifier: "goNext", sender: self)
            
        } else {
            countLabel.text = "\(secondsCount)"
            
            if secondsCount == 3 {
                imageView.image = Asset.simpleDarkLeaf.image
            } else if secondsCount == 2 {
                imageView.image = Asset.simpleRedLeaf.image
            } else if secondsCount == 1 {
                imageView.image = Asset.simpleYellowLeaf.image
            }
        }
        print("UISET完了")
    }
    
    
    @objc func downTimer() {
        secondsCount -= 1
        updatetimeUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goNext" {
            let LookBackSpotVC = segue.destination as! LookBackSpotViewController
            LookBackSpotVC.spotUID = nextSpotUID
            LookBackSpotVC.leafType = type
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
