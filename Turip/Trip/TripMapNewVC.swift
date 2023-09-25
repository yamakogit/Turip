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
                        
                        DispatchQueue.main.async {
                            print("userData取得完了")
                            let userAllSpotDatas = userData.spots
                            
                            if userAllSpotDatas != [] { //nilじゃないとき表示処理開始
                                
                                for n in 0...userAllSpotDatas!.count-1 {
                                    
                                    let electedSpotData = userAllSpotDatas?[n]
                                    let spotUid = electedSpotData?["UID"]
                                    
                                    Task {
                                        do {
                                            let spotDataDetail = try await FirebaseClient.shared.getSpotData(spotUID: spotUid ?? "")
                                            
                                            DispatchQueue.main.async {
                                                print("spotDataDetail取得完了")
                                                
                                                //緯度
                                                let spotCoordinateDict = spotDataDetail.coordinate
                                                let spotCoordinateLat = spotCoordinateDict?["lat"]
                                                let spotCoordinateLng = spotCoordinateDict?["lng"]
                                                let spotCoordinate2D = CLLocationCoordinate2D(latitude: Double(spotCoordinateLat!)!, longitude: Double(spotCoordinateLng!)!) //String -> CLLocationCoordinate2D
                                                
                                                //月日の割り出し
                                                let spotDateString = electedSpotData?["date"]
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy.MM.dd"
                                                dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
                                                //まずはDate型に↓
                                                let spotDateDate = dateFormatter.date(from: spotDateString!)
                                                //そこからStringで月・日をそれぞれ取得
                                                dateFormatter.dateFormat = "M"
                                                let month = dateFormatter.string(from: spotDateDate!)
                                                dateFormatter.dateFormat = "d"
                                                let day = dateFormatter.string(from: spotDateDate!)
                                                
                                                
                                                //葉っぱの色 表示調整
                                                let spotLeafType = electedSpotData?["type"]
                                                
                                                print("ピン表示処理中:\(n)")
                                                
                                                //写真の取得
                                                let spotPhotoURL = spotDataDetail.photoURL
                                                FirebaseClient().getSpotImage(url: spotPhotoURL ?? "https://firebasestorage.googleapis.com/v0/b/turip-ee2b3.appspot.com/o/spotImages%2FNoneImage.png?alt=media&token=09339f8e-ab1d-4c59-b1a3-02a00840ad4b") { [weak self] image in
                                                    if let image = image {
                                                        DispatchQueue.main.async {
                                                            let annotation = CustomAnnotation(coordinate: spotCoordinate2D, month: month, day: day, imageName: image, leafType: spotLeafType ?? "1", date: spotDateString!, spotData: spotDataDetail)
                                                            print("追加！")
                                                            self?.mapView.addAnnotation(annotation)
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            
                                            
                                        } catch {
                                            print("Error fetching spot data5/6: \(error)")
                                            //エラー
                                        }
                                    }
                                    
                                    
                                }
                            }
                        }
        } catch {
            print("Error fetching spot data5/6: \(error)")
            //エラー
        }
    }

        //ゴール関連
        Task {
            do {
                
                let userData = try await FirebaseClient.shared.getUserData()
                let goalData = try await FirebaseClient.shared.getGoalData()
                try await FirebaseClient.shared.getUserUid()
                
                DispatchQueue.main.async {
                    
                    print("UIII")
                    
                    //ゴールの表示
                    self.spotName = goalData.name ?? "- - - -"
                    self.spotAdress = goalData.place ?? "- - - -"
                    self.remainingSteps = userData.remainingSteps ?? "- - - -"
                    
                    self.spotNameLabel.text = self.spotName
                    self.spotAdressLabel.text = "📍\(self.spotAdress)"
                    self.remainingStepsLabel.text = "「目的地まであと \(self.remainingSteps)歩」"
                    
                    
                    //ゴールとスタートと現在地のAnnotation追加
                    //ゴール
                    self.addTextAnnotation(coordinateDict: goalData.coordinate!, image: Asset.goal.image, type: "2")
                    //スタート
                    self.addTextAnnotation(coordinateDict: userData.startCoordinate!, image: Asset.start.image, type: "1")
                    //現在地
                    self.addTextAnnotation(coordinateDict: userData.currentCoordinate!, image: Asset.currentPlace.image, type: "1")
                    
                    
                    //経路の表示（黄色ライン）
                    //このTourismのスタート地点
                    let startCoordinateDict = userData.startCoordinate
                    let startCoordinateLat = startCoordinateDict?["lat"]
                    let startCoordinateLng = startCoordinateDict?["lng"]
                    let startCoordinate2D = CLLocationCoordinate2D(latitude: Double(startCoordinateLat!)!, longitude: Double(startCoordinateLng!)!) //CLLocationCoordinate2Dに変換
                    //Tourismの現在地
                    let currentCoordinateDict = userData.currentCoordinate
                    let currentCoordinateLat = currentCoordinateDict?["lat"]
                    let currentCoordinateLng = currentCoordinateDict?["lng"]
                    let currentCoordinate2D = CLLocationCoordinate2D(latitude: Double(currentCoordinateLat!)!, longitude: Double(currentCoordinateLng!)!)
                    //ラインの追加
                    let linecoordinates = [startCoordinate2D, currentCoordinate2D]
                    let polyline = MKPolyline(coordinates: linecoordinates, count: linecoordinates.count)
                    self.mapView.addOverlay(polyline)
                    
                }
                
            } catch {
                print("Error fetching spot data5/6: \(error)")
                DispatchQueue.main.async {
                    //エラー
                    AlertHost.alertDef(view: self ,title: "エラー", message: "Goalの取得に失敗しました。")
                }
            }
            
        }
        
        
        //MARK: 通知
        //通知許可の取得を求める
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]){
                (granted, _) in
                if granted{
                    print("granted 通知")
                    UNUserNotificationCenter.current().delegate = self
                }
            }
        
        let unc = UNUserNotificationCenter.current()  //設定済の通知の全削除
        unc.removeAllPendingNotificationRequests()  //設定済の通知の全削除
        
        
        let content = UNMutableNotificationContent()
        content.title = "今日のTrip"
        content.body = "Turipで今日1日のヘルスケアを振り返り、\nSpotを獲得しよう"
        
        // Configure the recurring date.
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current

        dateComponents.hour = 19    // 19:00に設定
           
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
                 dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
                print("通知エラー")
           } else {
               print("通知設定完了")
           }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    func addTextAnnotation(coordinateDict: [String:String], image: UIImage, type: String){
        
        let coordinateLat = coordinateDict["lat"]
        let coordinateLng = coordinateDict["lng"]
        let coordinate2D = CLLocationCoordinate2D(latitude: Double(coordinateLat!)!, longitude: Double(coordinateLng!)!)
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
            
            if leafType123 == "3" {
                //赤
                performSegue(withIdentifier: "show3SpotDetail", sender: self)
                
            } else {
                //黄・緑
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

