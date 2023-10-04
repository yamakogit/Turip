//
//  DataViewController.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/06.
//

import UIKit
import HealthKit

class DataViewController: UIViewController {
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var stepGlaph: UIImageView!
    
    @IBOutlet weak var tripImage: UIImageView!
    @IBOutlet weak var tripDateLabel: UILabel!
    @IBOutlet weak var tripSpotNameTF: UITextField!
    @IBOutlet weak var tripSpotPlaceTF: UITextField!
    @IBOutlet weak var tripSpotDetailTV: UITextView!
    
    @IBOutlet weak var tourImage: UIImageView!
    @IBOutlet weak var tourDateLabel: UILabel!
    @IBOutlet weak var tourSpotNameTF: UITextField!
    @IBOutlet weak var tourSpotPlaceTF: UITextField!
    @IBOutlet weak var tourSpotDetailTV: UITextView!
    
    @IBOutlet weak var tripPlaceNumbers: UILabel!
    @IBOutlet weak var tourPlaceNumbers: UILabel!
    
    @IBOutlet weak var tripLeaf: UIImageView!
    
    @IBOutlet var borderinglabels: [UILabel]!
    
    @IBOutlet weak var tripBackImage: UIImageView!
    @IBOutlet weak var tourBackImage: UIImageView!
    
    
    var stepsInt = 0
    var photo: UIImage!
    var tripPhoto: UIImage!
    var tourPhoto: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tripBackImage.layer.cornerRadius = 5
        tripBackImage.clipsToBounds = true
        
        tourBackImage.layer.cornerRadius = 5
        tourBackImage.clipsToBounds = true
        
        tripImage.layer.cornerRadius = tripImage.frame.size.width / 2
        tripImage.clipsToBounds = true
        
        tourImage.layer.cornerRadius = tourImage.frame.size.width / 2
        tourImage.clipsToBounds = true
        
        tripSpotNameTF.isEnabled = false
        tripSpotPlaceTF.isEnabled = false
        tripSpotDetailTV.isEditable = false
        
        tourSpotNameTF.isEnabled = false
        tourSpotPlaceTF.isEnabled = false
        tourSpotDetailTV.isEditable = false
        
        self.stepLabel.text = "0"
        
        stepGlaph.image = Asset.glaf0.image
        
        //MARK: Health
        OtherHosts.shared.requestAuthorization { stepsInt, error in
            if let error = error {
                print("SSSエラー: \(error)")
                
            } else if let stepsInt = stepsInt {
                print("SSS今日のステップ数: \(stepsInt)")
                self.stepsInt = stepsInt
                self.setGlaf()
                self.stepLabel.text = "\(stepsInt)"
            }
        }
        
        let uiArray = [tourSpotNameTF,tourSpotPlaceTF,tourSpotDetailTV,
                       tripSpotNameTF,tripSpotPlaceTF,tripSpotDetailTV,
                       tripPlaceNumbers,tourPlaceNumbers]
        
        Task {
            do {
                
                let latestTourismSpot = try await FirebaseClient.shared.getLatestSpotData(type1: "3", type2: "3")
                let latestTripSpot = try await FirebaseClient.shared.getLatestSpotData(type1: "1", type2: "2")
                let spotsCount = try await FirebaseClient.shared.spotsCount()
                
                if latestTripSpot["type"] == "2" {
                    tripLeaf.image = Asset.leafYellow.image
                } else {
                    tripLeaf.image = Asset.leafLightGreen.image
                }
                
                do {
                    let latestTourismSpotData = try await FirebaseClient.shared.getSpotData(spotUID: latestTourismSpot["UID"] ?? "") //MARK: UID, date, type
                    let latestTripSpotData = try await FirebaseClient.shared.getSpotData(spotUID: latestTripSpot["UID"] ?? "")
                    
                    self.tourDateLabel.text = latestTourismSpot["date"]
                    self.tourSpotNameTF.text = latestTourismSpotData.name
                    self.tourSpotPlaceTF.text = latestTourismSpotData.place
                    self.tourSpotDetailTV.text = latestTourismSpotData.detail
                    
                    self.tripDateLabel.text = latestTripSpot["date"]
                    self.tripSpotNameTF.text = latestTripSpotData.name
                    self.tripSpotPlaceTF.text = latestTripSpotData.place
                    self.tripSpotDetailTV.text = latestTripSpotData.detail
                    
                    self.tripPlaceNumbers.text = "\(spotsCount.trip)"
                    self.tourPlaceNumbers.text = "\(spotsCount.tourism)"
                    
                    //Imageの取得・表示
                    FirebaseClient().getSpotImage(url: latestTripSpotData.photoURL ?? "https://firebasestorage.googleapis.com/v0/b/turip-ee2b3.appspot.com/o/spotImages%2FNoneImage.png?alt=media&token=09339f8e-ab1d-4c59-b1a3-02a00840ad4b") { [weak self] image in
                        if let image = image {
                            DispatchQueue.main.async {
                                self?.tripImage.image = image
                                self?.tripPhoto = image
                            }
                        }
                    }
                    
                    FirebaseClient().getSpotImage(url: latestTourismSpotData.photoURL ?? "https://firebasestorage.googleapis.com/v0/b/turip-ee2b3.appspot.com/o/spotImages%2FNoneImage.png?alt=media&token=09339f8e-ab1d-4c59-b1a3-02a00840ad4b") { [weak self] image in
                        if let image = image {
                            DispatchQueue.main.async {
                                self?.tourImage.image = image
                                self?.tourPhoto = image
                            }
                        }
                    }
                    
                } catch {
                    print("Error fetching spot data5/6: \(error)")
                    for ui in uiArray {
                        if let ui2 = ui as? UITextField {
                            ui2.text = "error:5"
                        } else if let ui3 = ui as? UITextView {
                            ui3.text = "error:5"
                        }
                    }
                    self.tourDateLabel.text = latestTourismSpot["date"]
                    self.tripDateLabel.text = latestTripSpot["date"]
                }
            } catch {
                print("Error fetching spot date7/8: \(error)")
                for ui in uiArray {
                    if let ui2 = ui as? UITextField {
                        ui2.text = "error:6"
                    } else if let ui3 = ui as? UITextView {
                        ui3.text = "error:6"
                    }
                }
                self.tourDateLabel.text = "error:6"
                self.tripDateLabel.text = "error:6"
            }
        }
        
        
    }
    
    
    //MARK: glaf
    func setGlaf() {
        var glafRaito: Int = stepsInt / 80
        glafRaito = (glafRaito + 9) / 10
        print("GLAFRAITO:\(glafRaito)")
        if glafRaito >= 10  {
            if stepsInt < 8000 {
                glafRaito = 9
            } else {
                glafRaito = 10
            }
        }
        print("glafRaito: \(glafRaito)")
        stepGlaph.image = UIImage(named: "glaf_\(glafRaito)")
    }
    
    
    @IBAction func showTripPhoto(_ sender: UIButton) {
        photo = tripPhoto
        performSegue(withIdentifier: "showPhoto", sender: self)
    }
    
    
    @IBAction func showTourPhoto(_ sender: UIButton) {
        photo = tourPhoto
        performSegue(withIdentifier: "showPhoto", sender: self)
    }
    
    
    //MARK: SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto" {
            let photoVC = segue.destination as! PhotoViewController
            photoVC.photo = photo
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
