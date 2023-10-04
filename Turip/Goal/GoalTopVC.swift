//
//  LookBackStepVC.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/09.
//

import UIKit

class GoalTopViewController: UIViewController {
    
    
    @IBOutlet weak var spotImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var spotNameTF: UITextField!
    @IBOutlet weak var spotPlaceTF: UITextField!
    @IBOutlet weak var spotDetailTV: UITextView!
    
    @IBOutlet weak var spotBackImage: UIImageView!
    
    var date = ""
    var goalUID = ""
    var goalPlace = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        spotImage.layer.cornerRadius = spotImage.frame.size.width / 2
        spotImage.clipsToBounds = true
        
        spotBackImage.layer.cornerRadius = 5
        spotBackImage.clipsToBounds = true
        
        // Do any additional setup after loading the view.
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        date = dateFormatter.string(from: Date())
        
        spotNameTF.isEnabled = false
        spotPlaceTF.isEnabled = false
        spotDetailTV.isEditable = false
        
        Task {
            do {
                
                let goalData = try await FirebaseClient.shared.getGoalData()
                
                self.goalUID = goalData.id ?? ""
                self.goalPlace = goalData.place ?? ""
                self.dateLabel.text = self.date
                self.spotNameTF.text = goalData.name
                self.spotPlaceTF.text = goalData.place
                self.spotDetailTV.text = goalData.detail
                
                try await FirebaseClient.shared.saveUserDatas(currentCoordinateDict: goalData.coordinate!) //現在地の更新
                
                let spotImage = try await FirebaseClient().getSpotImage(url: goalData.photoURL ?? "https://firebasestorage.googleapis.com/v0/b/turip-ee2b3.appspot.com/o/spotImages%2FNoneImage.png?alt=media&token=09339f8e-ab1d-4c59-b1a3-02a00840ad4b")
                self.spotImage.image = spotImage
                
                //Imageの取得・表示
//                FirebaseClient().getSpotImage(url: goalData.photoURL ?? "https://firebasestorage.googleapis.com/v0/b/turip-ee2b3.appspot.com/o/spotImages%2FNoneImage.png?alt=media&token=09339f8e-ab1d-4c59-b1a3-02a00840ad4b") { [weak self] image in
//                    if let image = image {
//                        DispatchQueue.main.async {
//                            self?.spotImage.image = image
//                        }
//                    }
//                }
                
                
                
                
            } catch {
                print("Error fetching spot data5/6: \(error)")
            }
            
        }
        
    }
    
    
    @IBAction func goNext() {
        
        var steps = 0
        var type = 1
        
        OtherHosts.shared.requestAuthorization { stepsInt, error in
            if let error = error {
                print("エラー: \(error)")
            } else if let stepsInt = stepsInt {
                print("今日のステップ数: \(stepsInt)")
                steps = (stepsInt)
                if steps >= 8000 {
                    type = 2
                }
            }
        }
        
        Task {
            do {
                try await FirebaseClient.shared.saveSpotDatatoUser(spotUID: goalUID, date: date, type: "\(type)")
                
                performSegue(withIdentifier: "goNext", sender: self)
                
            }
            catch {
                print("EROOROR")
                print(error.localizedDescription)
                AlertHost.alertDef(view: self, title: "エラー(code:2)", message: "しばらく経ってから\nやり直してください")
            }
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
