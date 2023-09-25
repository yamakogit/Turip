//
//  LookBackStepVC.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/09.
//

import UIKit
import MapKit

class LookBackLocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var remainingDistance = 0
    var todaySteps = 0
    
    var userPlace :String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        mapView.isUserInteractionEnabled = false
        
        mapView.layer.cornerRadius = 5
        mapView.clipsToBounds = true
        
        
        Task {
            do {
                
                let userData = try await FirebaseClient.shared.getUserData()
                let goalData = try await FirebaseClient.shared.getGoalData()
                
                
                DispatchQueue.main.async {
                    
                    let userCoordinateDict = userData.currentCoordinate
                    let goalCoordinateDict = goalData.coordinate
                    
                    print("goalData.id!!!!!!")
                    print(goalData.id!)
                    
                    UserDefaults.standard.set(goalData.id!, forKey: "goalUID")
                    
                    
                    //歩数の計算
                    let distance: Int = MapClient.calculateDistance(startCoordinateDict: userCoordinateDict!, endCoordinateDict: goalCoordinateDict!) //現在地〜ゴールまでの距離(Int)
                    self.todaySteps = UserDefaults.standard.integer(forKey: "todaySteps")
                    self.remainingDistance = self.todaySteps - distance
                    
                    var centerCoordinateDict: [String:String]!
                    var centerCoordinate :CLLocationCoordinate2D!
                    
                    
                    if self.remainingDistance >= 0 { //ゴール到着 準備
                        
                        centerCoordinateDict = userCoordinateDict
                        UserDefaults.standard.removeObject(forKey: "newCoordinate")
                        
                    } else { //ゴールへ行かない・旅を続ける
                        
                        centerCoordinateDict = MapClient.decideNewLocation(startCoordinateDict: userCoordinateDict!, endCoordinateDict: goalCoordinateDict!, distance: Double(self.todaySteps)) //新現在地の算出
                        UserDefaults.standard.set(centerCoordinateDict, forKey: "newCoordinate")
                        
                        
                    }
                    
                    
                    //MARK: MAPの適正表示
                    
                    
                    //中心座標
                    if let latString = centerCoordinateDict!["lat"], let lngString = centerCoordinateDict!["lng"],
                       let latitude = Double(latString), let longitude = Double(lngString) {
                        centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    } else {
                        //エラー
                    }
                    
                    let coordinateRegion = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 250, longitudinalMeters: 250)
                    self.mapView.setRegion(coordinateRegion, animated: true)
                    
                    //ピン立て
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = centerCoordinate
                    self.mapView.addAnnotation(annotation)
                    
                    
                    if self.remainingDistance < 0 {
                        //アドレスの取得
                        Task {
                            do {
                                //現在地の住所
                                self.userPlace = try await OtherHosts.conversionAdress(lat: centerCoordinate.latitude, lng: centerCoordinate.longitude)
                                
                            }
                        }
                    }
                    
                    
                    
                }
                
            } catch {
                print("Error fetching spot date7/8: \(error)")
                DispatchQueue.main.async {
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func goNext() {
        
        //goalUIDの引渡しが必要
        //現在地の更新保存
        
        if remainingDistance >= 0 {
            //ゴール！へ
            UserDefaults.standard.set(remainingDistance, forKey: "calculatedDistance")
            performSegue(withIdentifier: "goGoal", sender: self)
            
        } else {
            //ゴールなし
            UserDefaults.standard.set(todaySteps, forKey: "calculatedDistance")
            performSegue(withIdentifier: "goLB", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goLB" {
            let LookBackCountVC = segue.destination as! LookBackCountViewController
            LookBackCountVC.userPlace = userPlace
            print("userPlace")
            print("\(userPlace)")
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
