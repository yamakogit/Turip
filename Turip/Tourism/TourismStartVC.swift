//
//  TourismViewController.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/06.
//

import UIKit
import MapKit
import CoreLocation

class TourismStartViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locatioManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locatioManager = CLLocationManager()
        locatioManager.delegate = self
        locatioManager.startUpdatingLocation()
        locatioManager.requestWhenInUseAuthorization()  //位置情報使用許可ダイアログ
        
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationClient.shared.deleteTourNotification()
    }
    
    //位置情報が更新されたら呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        if let location = locations.last {
            // 現在地を地図の中央に表示
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    @IBAction func tapStart() {
        self.performSegue(withIdentifier: "selectTime", sender: self)
    }
    
    
    @IBAction func goTutorial() {
        //MARK: 遷移
        let tutorialPageVC = TutorialPageViewController()
        tutorialPageVC.comeFrom = "tour"
        self.present(tutorialPageVC, animated: true, completion: nil)
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
