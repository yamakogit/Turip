//
//  TourismViewController.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/06.
//

import UIKit
import MapKit

class TourismDetailViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var spotNameTF: UILabel!
    @IBOutlet weak var spotPlaceTF: UILabel!
    @IBOutlet weak var spotImage: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var tourSpotDetailTV: UITextView!
    
    var spotData: FirebaseClient.SpotDataSet = FirebaseClient.SpotDataSet()
    
    var date: String?
    var assignedDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Imageの取得・表示
        FirebaseClient().getSpotImage(url: spotData.photoURL ?? "https://firebasestorage.googleapis.com/v0/b/turip-ee2b3.appspot.com/o/spotImages%2FNoneImage.png?alt=media&token=09339f8e-ab1d-4c59-b1a3-02a00840ad4b") { [weak self] image in
            if let image = image {
                DispatchQueue.main.async {
                    self?.spotImage.image = image
                }
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let nowDate = dateFormatter.string(from: Date())
        assignedDate = date ?? nowDate
        
        dateLabel.text = assignedDate
        
        spotNameTF.text = spotData.name ?? ""
        spotPlaceTF.text = spotData.place ?? ""
        tourSpotDetailTV.text = spotData.detail ?? ""
        timeLabel.text = spotData.time ?? ""
        stepLabel.text = spotData.steps ?? ""
        
        spotImage.layer.cornerRadius = spotImage.frame.size.width / 2
        spotImage.clipsToBounds = true //ImageView円設定
        
        tourSpotDetailTV.isEditable = false
        
        
        //MARK: MAP
        mapView.isUserInteractionEnabled = false  //操作禁止
        
        //String -> Double
        if let latitude = Double((spotData.coordinate?["lat"])!), let longitude = Double((spotData.coordinate?["lng"])!) {
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
            mapView.setRegion(region, animated: true)
            // ここでcoordinate (CLLocationCoordinate2D型) を使用
        } else {
            print("緯度または経度の変換に失敗")
        }
        
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    
    @IBAction func closeView() {
        self.navigationController?.popToRootViewController(animated: true)
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
