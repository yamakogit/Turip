//
//  LookBackStepVC.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/09.
//

import UIKit
import MapKit

class GoalCountViewController: UIViewController {
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var timer: Timer?
    var secondsCount = 3
    var time: String = ""
    var nextGoalUID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isHidden = false
        
        //time
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(downTimer), userInfo: nil, repeats: true)
        updatetimeUI() //タイマーボタンLabel 適正表示
        
        
        FirebaseClient.shared.getAllUIDs() { documentIDs, error in
            if let error = error {
                print("データの取得に失敗しました：\(error.localizedDescription)")
            } else if let documentIDs = documentIDs {
                print("取得したドキュメントID：\(documentIDs)")
                if let randomElement = documentIDs.randomElement() {
                    
                    var distance = 1000000
                    var count = 0
                    var pregoalUID = ""
                    
                    while (distance >= 200000 && count <= 80) || pregoalUID == self.nextGoalUID  { //ゴールが現在地から200km以内になるまで (問い合わせ80回まで)
                        
                        //NextGoalの設定
                        self.nextGoalUID = randomElement
                        count += 1
                        print("count")
                        print(count)
                        
                        Task {
                            do {
                                let userData = try await FirebaseClient.shared.getUserData()
                                let spotData = try await FirebaseClient.shared.getSpotData(spotUID: self.nextGoalUID) //新ゴール候補のデータ取得
                                
                                distance = MapClient.calculateDistance(startCoordinateDict: userData.currentCoordinate!, endCoordinateDict: spotData.coordinate!)
                                pregoalUID = userData.goalUID!
                                
                            } catch {
                                print("エラー")
                            }
                        }
                        
                    }
                    
                    Task {
                        do {
                            try await FirebaseClient.shared.saveUserDatas(goalUID: self.nextGoalUID) //新ゴールのUID保存
                            print("saveNewGoal完了")
                            
                        } catch {
                            print("エラー")
                        }
                    }
                    
                    
                } else {
                    print("配列が空")
                    AlertHost.alertDef(view: self,title: "エラー", message: "次のGOALの取得に失敗しました")
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
            let GoalNewTripVC = segue.destination as! GoalNewTripViewController
            GoalNewTripVC.goalUID = nextGoalUID
            GoalNewTripVC.titleLabelText = "Start\nNew Trip!"
            GoalNewTripVC.subtitleLabelText = "New GOAL"
            GoalNewTripVC.naviTitle = "New Trip"
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
