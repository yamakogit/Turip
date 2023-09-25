//
//  LookBackStepVC.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/09.
//

import UIKit

class GoalNewTripViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var spotNameTF: UITextField!
    @IBOutlet weak var spotPlaceTF: UITextField!
    
    @IBOutlet weak var remainingSteps: UILabel!
    
    @IBOutlet weak var spotBackImage: UIImageView!
    
    var titleLabelText: String = ""
    var subtitleLabelText: String = ""
    var naviTitle: String = ""
    var goalUID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        spotBackImage.layer.cornerRadius = 5
        spotBackImage.clipsToBounds = true
        
        titleLabel.text = titleLabelText
        subtitleLabel.text = subtitleLabelText
        navigationItem.title = naviTitle
        
        Task {
            do {
                
                let goalSpotData = try await FirebaseClient.shared.getSpotData(spotUID: goalUID)
                let userData = try await FirebaseClient.shared.getUserData()
                
                DispatchQueue.main.async {
                    self.spotNameTF.text = goalSpotData.name
                    self.spotPlaceTF.text = goalSpotData.place
                    
                    let goalCoordinateDict = goalSpotData.coordinate
                    let userCoordinateDict = userData.currentCoordinate
                    
                    let totaldistance: Int = MapClient.calculateDistance(startCoordinateDict: userCoordinateDict!, endCoordinateDict: goalCoordinateDict!) //現在地〜ゴールまでの距離(Int)
                    let todayDistance = UserDefaults.standard.integer(forKey: "calculatedDistance")
                    
                    let remainingDistance = totaldistance - todayDistance //残歩数
                    self.remainingSteps.text = "\(remainingDistance)"
                    
                    
                    //今日はゴールしなかった場合 -> 新現在地は算出済/UDにあり
                    var newUserLocation: [String : Any]? = UserDefaults.standard.dictionary(forKey: "newCoordinate")
                    print("newCoordinate: \(newUserLocation ?? ["！":"値がないお"])")
                    var newUserLocation2 = newUserLocation as? [String:String] //型変換
                    
                    //今日ゴールしている場合 -> 新現在地は未算出/UDになしのためこれから算出
                    if newUserLocation2 == nil {
                        newUserLocation2 = MapClient.decideNewLocation(startCoordinateDict: userCoordinateDict!, endCoordinateDict: goalCoordinateDict!, distance: Double(todayDistance)) //最新の現在地
                    }
                    
                    print("newCoordinate2: \(newUserLocation2 ?? ["!!":"値がないお2"])")
                    
                    Task {
                        do {
                            
                            var startCoordinateDict = userData.startCoordinate
                            
                            if self.naviTitle == "New Trip" {
                                //新旅のためstartCoordinateDictも更新
                                startCoordinateDict = newUserLocation2
                                
                            }
                            
                            try await FirebaseClient.shared.saveUserDatas(currentCoordinateDict: newUserLocation2, steps: "\(remainingDistance)", startCoordinateDict: startCoordinateDict)
                            DispatchQueue.main.async {
                                print("現在地更新保存完了")
                            }
                            
                        } catch {
                            print("Error fetching spot data5/6: \(error)")
                            DispatchQueue.main.async {
                                
                            }
                        }
                    }
                    
                    
                }
            } catch {
                print("Error")
                DispatchQueue.main.async {
                    self.spotNameTF.text = "Error"
                    self.spotPlaceTF.text = "Error"
                }
            }
        }
        
    }
    
    @IBAction func finButton() {
        self.performSegue(withIdentifier: "goHome", sender: self)
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
