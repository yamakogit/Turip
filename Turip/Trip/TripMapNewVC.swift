//
//  ViewController.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/06.
//

import UIKit
import MapKit
import FirebaseFirestoreSwift

class TripMapNewViewController: UIViewController, MKMapViewDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var spotNameLabel: UILabel!
    @IBOutlet weak var spotAdressLabel: UILabel!
    @IBOutlet weak var remainingStepsLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var spotName: String = ""
    var spotAdress: String = ""
    var remainingSteps: String = ""
    var key = 0
    
    var coordinates: [CLLocationCoordinate2D]!
    
    var leafType123: String = ""
    var date123: String = ""
    var spotData123: FirebaseClient.SpotDataSet = FirebaseClient.SpotDataSet() //からのSpotDataSet()を入れる
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        
        Task {
            do {
                let userData = try await FirebaseClient.shared.getUserData()
                let goalData = try await FirebaseClient.shared.getGoalData()
                
                setGoals(userData: userData, goalData: goalData) //ゴール設定
                
                print("userData取得完了")
                let userAllSpotDatas = userData.spots
                
                if userAllSpotDatas != [] { //nilじゃないとき表示処理開始
                    
                    for n in 0...userAllSpotDatas!.count-1 {
                        
                        let electedSpotData = userAllSpotDatas?[n]
                        let spotUid = electedSpotData?["UID"]
                        
                        do {
                            let spotDataDetail = try await FirebaseClient.shared.getSpotData(spotUID: spotUid ?? "")
                            print("spotDataDetail取得完了: \(n)")
                            
                            //緯度
                            let spotCoordinateDict = spotDataDetail.coordinate
                            let spotCoordinate2D = OtherHosts.shared.conversionCoordinate(spotCoordinateDict!)
                            //String -> CLLocationCoordinate2D
                            
                            //月日の割り出し
                            let dateSet = loadDate(stringDate: (electedSpotData?["date"])!)
                            
                            //葉っぱの色 表示調整
                            let spotLeafType = electedSpotData?["type"]
                            
                            //写真の取得
                            let spotPhotoURL = spotDataDetail.photoURL
                            FirebaseClient().getSpotImage(url: spotPhotoURL ?? "https://firebasestorage.googleapis.com/v0/b/turip-ee2b3.appspot.com/o/spotImages%2FNoneImage.png?alt=media&token=09339f8e-ab1d-4c59-b1a3-02a00840ad4b") { [weak self] image in
                                if let image = image {
                                    DispatchQueue.main.async {
                                        let annotation = CustomAnnotation(coordinate: spotCoordinate2D, month: dateSet.month, day: dateSet.day, imageName: image, leafType: spotLeafType ?? "1", date: dateSet.date, spotData: spotDataDetail)
                                        print("追加！")
                                        self?.mapView.addAnnotation(annotation)
                                    }
                                }
                            }
                        } catch {
                            print("Error fetching spot data5/6: \(error)") //エラー
                        }
                    }
                }
                
                
            } catch {
                print("Error fetching spot data5/6: \(error)") //エラー
            }
        }
        
        //旧バージョン対応
        let tripHourChecker = UserDefaults.standard.string(forKey: "tripHourChecker")
        if tripHourChecker == nil {
            UserDefaults.standard.set(19, forKey: "tripHour")
            UserDefaults.standard.set("OK", forKey: "tripHourChecker")
        }
        
        //MARK: 通知
        setNotification()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    func addTextAnnotation(coordinateDict: [String:String], image: UIImage, type: String){
        let coordinate2D = OtherHosts.shared.conversionCoordinate(coordinateDict)
        let annotation = CustomAnnotation(coordinate: coordinate2D, month: "0", day: "0", imageName: image, leafType: type, date: "0", spotData: FirebaseClient.SpotDataSet())
        mapView.addAnnotation(annotation)
    }
    
    
    //MARK: ピン Annotationの設定
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let customAnnotation = annotation as? CustomAnnotation else {
            return nil //CustomAnnotation型でない場合はnil
        }
        
        let identifier = "CustomAnnotationView\(key)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) //annotationView再利用
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: customAnnotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = customAnnotation
        }
        
        if let customView = Bundle.main.loadNibNamed("CustomView", owner: self, options: nil)?.first as? CustomViewVC {
            
            func setCustomViewUI(_ bool: Bool) {
                customView.monthLabel.isHidden = bool
                customView.dayLabel.isHidden = bool
                customView.button2.isHidden = bool
                customView.slashLabel.isHidden = bool
                customView.lightView.isHidden = bool
            }
            
            
            if customAnnotation.month == "0" {
                setCustomViewUI(true)
                
            } else {
                setCustomViewUI(false)
                customView.monthLabel.text = customAnnotation.month
                customView.dayLabel.text = customAnnotation.day
                customView.button2.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                
            }
            
            //共通
            customView.imageView.image = customAnnotation.imageName
            //共通
            if customAnnotation.leafType == "1" {
                customView.leafImage.image = Asset.stemGreen.image
            } else if customAnnotation.leafType == "2" {
                customView.leafImage.image = Asset.stemYellow.image
            } else if customAnnotation.leafType == "3" {
                customView.leafImage.image = Asset.stemRed.image
            }
            
            
            let customViewSize = CGSize(width: 80, height: 176)
            customView.frame = CGRect(origin: .zero, size: customViewSize)
            
            customView.imageView.layer.cornerRadius = customView.imageView.frame.size.width / 2
            customView.imageView.clipsToBounds = true
            
            customView.lightView.layer.cornerRadius = customView.lightView.frame.size.width / 2
            customView.lightView.clipsToBounds = true
            
            annotationView?.frame = CGRect(origin: .zero, size: customViewSize)
            annotationView?.centerOffset = CGPoint(x: 30, y: -75)
            
            annotationView?.addSubview(customView)
        }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polylineOverlay = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: polylineOverlay)
            renderer.strokeColor = Asset.colorLineYellow.color
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    
    @objc func buttonTapped(_ sender: UIButton) {
        // カスタムビュー内のボタンがタップされたときの処理
        
        if let customView = sender.superview as? CustomViewVC,
           let annotationView = customView.superview as? MKAnnotationView,
           let customAnnotation = annotationView.annotation as? CustomAnnotation {
            print("タップ！")
            
            leafType123 = customAnnotation.leafType
            date123 = customAnnotation.date
            spotData123 = customAnnotation.spotData
            
            if leafType123 == "3" { //赤
                performSegue(withIdentifier: "show3SpotDetail", sender: self)
                
            } else { //黄・緑
                performSegue(withIdentifier: "show12SpotDetail", sender: self)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show12SpotDetail" {
            let spotVC = segue.destination as! SpotViewController
            spotVC.spotData = spotData123
            spotVC.leafType = leafType123
            spotVC.date = date123
            
        } else if segue.identifier == "show3SpotDetail" {
            let tourismDetailVC = segue.destination as! TourismDetailViewController
            tourismDetailVC.spotData = spotData123
            tourismDetailVC.date = date123
        }
    }
    
    
    @IBAction func goTutorial() {
        //MARK: 遷移
        let tutorialPageVC = TutorialPageViewController()
        tutorialPageVC.comeFrom = "trip"
        self.present(tutorialPageVC, animated: true, completion: nil)
    }
    
    
    func setNotification() {
        NotificationClient.shared.requestNotification(self) //許可を求める
        NotificationClient.shared.deleteAllNotification()  //設定済の通知の全削除
        
        let tripHour = UserDefaults.standard.integer(forKey: "tripHour")
        NotificationClient.shared.setNotification(title: "今日のTrip", message: "Turipで今日1日のヘルスケアを振り返り、\nSpotを獲得しよう", hour: tripHour)
        
        var spurtHour = tripHour - 1
        if spurtHour < 0 {
            spurtHour = 23
        }
        NotificationClient.shared.setNotification(title: "ラストスパート！", message: "今日のTripまであと1時間！\n目標「1日8000歩」まであと何歩？\nTuripで今日の歩数を確認しよう", hour: spurtHour)
    }
    
    
    func setGoals(userData: FirebaseClient.UserDataSet, goalData:  FirebaseClient.SpotDataSet) {
        
        //ゴールの表示
        self.spotName = goalData.name ?? "- - - -"
        self.spotAdress = goalData.place ?? "- - - -"
        self.remainingSteps = userData.remainingSteps ?? "- - - -"
        
        self.spotNameLabel.text = self.spotName
        self.spotAdressLabel.text = "📍\(self.spotAdress)"
        self.remainingStepsLabel.text = "「目的地まであと \(self.remainingSteps)歩」"
        
        //ゴール / スタート / 現在地のAnnotation追加
        self.addTextAnnotation(coordinateDict: goalData.coordinate!, image: Asset.goal.image, type: "2")
        self.addTextAnnotation(coordinateDict: userData.startCoordinate!, image: Asset.start.image, type: "1")
        self.addTextAnnotation(coordinateDict: userData.currentCoordinate!, image: Asset.currentPlace.image, type: "1")
        
        //経路の表示（黄色ライン）
        let startCoordinateDict = userData.startCoordinate  //このTourismのスタート地点
        let startCoordinate2D = OtherHosts.shared.conversionCoordinate(startCoordinateDict!)
        let currentCoordinateDict = userData.currentCoordinate //Tourismの現在地
        let currentCoordinate2D = OtherHosts.shared.conversionCoordinate(currentCoordinateDict!)
        
        //ラインの追加
        let linecoordinates = [startCoordinate2D, currentCoordinate2D]
        let polyline = MKPolyline(coordinates: linecoordinates, count: linecoordinates.count)
        self.mapView.addOverlay(polyline)
        
    }
    
    
    func loadDate(stringDate: String) -> dateStructure {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let spotDateString = stringDate
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let spotDateDate = dateFormatter.date(from: spotDateString) //Date型に
        dateFormatter.dateFormat = "M" //Stringで月・日をそれぞれ取得
        let month = dateFormatter.string(from: spotDateDate!)
        dateFormatter.dateFormat = "d"
        let day = dateFormatter.string(from: spotDateDate!)
        let dateStructure = dateStructure(month: month, day: day, date: spotDateString)
        
        return dateStructure
    }
    
    struct dateStructure {
        var month: String
        var day: String
        var date: String
    }
    
}



class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var month: String
    var day: String
    var imageName: UIImage
    
    var leafType: String
    var date: String
    var spotData: FirebaseClient.SpotDataSet
    
    init(coordinate: CLLocationCoordinate2D, month: String, day: String, imageName: UIImage, leafType: String, date: String, spotData: FirebaseClient.SpotDataSet) {
        self.coordinate = coordinate
        self.month = month
        self.day = day
        self.imageName = imageName
        self.leafType = leafType
        self.date = date
        self.spotData = spotData
        super.init()
    }
}

