//
//  LookBackStepVC.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/09.
//

import UIKit

class LookBackSpotViewController: UIViewController {
    
    @IBOutlet weak var spotImage: UIImageView!
    @IBOutlet weak var leafImage: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var spotNameTF: UITextField!
    @IBOutlet weak var spotPlaceTF: UITextField!
    @IBOutlet weak var spotDetailTV: UITextView!
    
    @IBOutlet weak var spotBackImage: UIImageView!
    
    var spotUID = ""
    var leafType = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        spotBackImage.layer.cornerRadius = 5
        spotBackImage.clipsToBounds = true
        
        spotImage.layer.cornerRadius = spotImage.frame.size.width / 2
        spotImage.clipsToBounds = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let date = dateFormatter.string(from: Date())
        
        spotNameTF.isEnabled = false
        spotPlaceTF.isEnabled = false
        spotDetailTV.isEditable = false
        
        if leafType == 2 {
            leafImage.image = Asset.leafYellow.image
        } else {
            leafImage.image = Asset.leafLightGreen.image
        }
        
        Task {
            do {
                
                let spotData = try await FirebaseClient.shared.getSpotData(spotUID: spotUID)
                
                self.dateLabel.text = date
                self.spotNameTF.text = spotData.name
                self.spotPlaceTF.text = spotData.place
                self.spotDetailTV.text = spotData.detail
                
                //Imageの取得・表示
                FirebaseClient().getSpotImage(url: spotData.photoURL ?? "https://firebasestorage.googleapis.com/v0/b/turip-ee2b3.appspot.com/o/spotImages%2FNoneImage.png?alt=media&token=09339f8e-ab1d-4c59-b1a3-02a00840ad4b") { [weak self] image in
                    if let image = image {
                        DispatchQueue.main.async {
                            self?.spotImage.image = image
                        }
                    }
                }
                
                
            } catch {
                print("Error fetching spot data5/6: \(error)")
            }
            
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goNext2" {
            let GoalNewTripVC = segue.destination as! GoalNewTripViewController
            GoalNewTripVC.goalUID = UserDefaults.standard.string(forKey: "goalUID") ?? ""
            GoalNewTripVC.titleLabelText = "TODAY's\nTrip"
            GoalNewTripVC.subtitleLabelText = "GOAL"
            GoalNewTripVC.naviTitle = "LOOK-BACK"
        }
    }
    
    
    @IBAction func goNext() {
        self.performSegue(withIdentifier: "goNext2", sender: self)
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
