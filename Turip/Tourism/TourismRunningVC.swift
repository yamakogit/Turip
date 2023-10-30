//
//  TourismViewController.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/06.
//

import UIKit
import MapKit
import CoreLocation
import HealthKit
import BackgroundTasks
import CoreMotion

class TourismRunningViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var spotImageView: UIImageView!
    
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var leftImageView: UIImageView!
    
    
    var locationManager: CLLocationManager!
    var userLocation: CLLocationCoordinate2D!
    
    var photoLocation: CLLocationCoordinate2D!
    
    var timer: Timer?
    var isRunning = false
    var secondsCount = 0
    var time: String = ""
    
    
    let healthStore = HKHealthStore()
    var query: HKStatisticsCollectionQuery?
    
    let calendar: Calendar! = Calendar.current
    var firstDateComponents: DateComponents!
    var stopDateController: Bool!
    
    var totalSteps = 0
    var beforeSteps = 0
    var addSteps = 0
    
    var photoURL = ""
    var placeAdress = ""
    var date = ""
    
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    var pedometer = CMPedometer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //map
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()  //位置情報使用許可ダイアログ
        mapView.showsUserLocation = true
        
        
        //health
        redefineStartDate()
        startPedometerUpdates()
        
        
        //time
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        isRunning = true
        updatetimeUI() //タイマーボタンLabel 適正表示
        
        plusLabel.isHidden = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        date = dateFormatter.string(from: Date())
        
        spotImageView.layer.cornerRadius = spotImageView.frame.size.width / 2
        spotImageView.clipsToBounds = true
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        registerBackgroundTask()
        NotificationCenter.default.addObserver(self, selector: #selector(reinstateBackgroundTask), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    
    
    @IBAction func rightButton() {
        // resume & stop Button
        if isRunning { //今からストップ
            timer?.invalidate()
            
        } else {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            //Health
            redefineStartDate()
            startPedometerUpdates()
        }
        isRunning = !isRunning
        updatetimeUI()
    }
    
    
    @IBAction func leftButton() {
        if leftLabel.text == "CANCEL" { //CANCEL
            AlertHost.alertDoubleDef(view: self, alertTitle: "Tourismをやめますか？", alertMessage: "ここまでのTourismの記録は\n保存されません。", b1Title: "Tourismをやめる", b1Style: .default, b2Title: "キャンセル") { [self] _ in
                timer?.invalidate()
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        } else { //FINISH
            if photoURL == "" {
                AlertHost.alertDef(view: self, title: "写真が未設定", message: "TourismSpotの写真を\n1枚選択してください。")
            } else {
                self.performSegue(withIdentifier: "finish", sender: self)
            }
        }
    }
    
    
    //MARK: MAP
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        if let location = locations.last {
            // 現在地を地図の中央に表示
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
            userLocation = location.coordinate
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    //MARK: TIME
    func updatetimeUI() {
        if isRunning {
            rightLabel.text = "STOP"
            leftLabel.text = "CANCEL"
            rightImageView.image = Asset.simpleGreenColoredShadow.image
            leftImageView.image = Asset.simpleGreenColoredShadow.image
            
        } else {
            rightLabel.text = "RESUME"
            leftLabel.text = "FINISH"
            rightImageView.image = Asset.simpleRedColoredShadow.image
            leftImageView.image = Asset.simpleRedColoredShadow.image
            
        }
        
        let timeSet = OtherHosts.timeCalsulate(secondsCount: secondsCount)
        time = "\(timeSet.minute ?? "**"):\(timeSet.second ?? "**")"
        timeLabel.text = time
        print("UISET完了")
    }
    
    
    @objc func updateTimer() {
        secondsCount += 1
        updatetimeUI()
        updateStepLabel()
        print("かうんと！\(secondsCount)")
    }
    
    
    func redefineStartDate() {
        totalSteps = beforeSteps + addSteps
        beforeSteps = totalSteps
        addSteps = 0
        firstDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: Date())
    }
    
    
    func updateStepLabel() {
        totalSteps = beforeSteps + addSteps
        stepLabel.text = "\(totalSteps)"
    }
    
    func startPedometerUpdates() {
        let startDate = calendar.date(from: firstDateComponents)!
        // 現在の日付を取得する
        pedometer.startUpdates(from: startDate) { data, error in
            guard let pData = data, error == nil else {
                // エラー
                return
            }
            DispatchQueue.main.async {
                self.addSteps = Int(truncating: pData.numberOfSteps)
            }
        }
    }
    
    func stopPedometerUpdates() {
        pedometer.stopUpdates()
    }
    
    
    
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != .invalid)
    }
    
    // バックグラウンドタスクの解除
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    // バックグラウンドタスクの再登録
    @objc func reinstateBackgroundTask() { //#selectorに登録するため"@objc"を使用
        if backgroundTask == .invalid {
            registerBackgroundTask()
        }
    }
    
    
    
    //MARK: PHOTO
    @IBAction func photoButton() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            present(picker, animated: true, completion: nil)
        } else {
            print("Camera is not available.")
            AlertHost.alertDef(view: self, title: "エラー", message: "カメラの使用が許可されていません。\n Turipを正しく利用するため、\n設定画面からカメラの使用を許可してください。")
        }
    }
    
    
    // キャンセルボタン時
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            spotImageView.image = selectedImage
        }
        
        
        Task {
            do {
                let photoURL2 = try await FirebaseClient().saveSpotImage(spotImage: spotImageView.image ?? Asset.leafRed.image)
                self.photoURL = photoURL2
                
            } catch {
                print("Error fetching spot date7/8: \(error)")
            }
        }
        
        
        
        photoLocation = userLocation
        
        
        Task {
            do {
                //現在地の住所
                self.placeAdress = try await OtherHosts.conversionAdress(lat: photoLocation.latitude, lng: photoLocation.longitude) //photoLocationより住所の特定
                self.plusLabel.isHidden = true
                picker.dismiss(animated: true, completion: nil)
                
            } catch {
                print("Error fetching spot date7/8: \(error)")
            }
        }
        
        
    }
    
    
    
    //MARK: SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "finish" {
            let spotVC = segue.destination as! SpotViewController
            spotVC.spotData.time = time
            spotVC.spotData.steps = "\(totalSteps)"
            spotVC.spotData.photoURL = photoURL
            spotVC.spotData.coordinate = ["lat": "\(photoLocation.latitude)", "lng": "\(photoLocation.longitude)"]
            spotVC.spotData.place = placeAdress
            spotVC.leafType = "3"
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
