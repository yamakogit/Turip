//
//  LookBackStepVC.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/09.
//

import UIKit

class LookBackStepViewController: UIViewController {

    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var stepGlaph: UIImageView!
    
    var stepsInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Health
        
        UserDefaults.standard.removeObject(forKey: "todaySteps")
        UserDefaults.standard.removeObject(forKey: "calculatedDistance")
        UserDefaults.standard.removeObject(forKey: "goalUID")
        UserDefaults.standard.removeObject(forKey: "newCoordinate")
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        
        OtherHosts.shared.requestAuthorization { stepsInt, error in
            if let error = error {
                print("エラー: \(error)")
                
            } else if let stepsInt = stepsInt {
                print("今日のステップ数: \(stepsInt)")
                self.stepsInt = stepsInt
                self.setGlaf()
                UserDefaults.standard.set(stepsInt, forKey: "todaySteps")
            }
        }
        
        
        
        Task {
            do {
                
                try await FirebaseClient.shared.saveLatestOpenedDatetoUser()
                DispatchQueue.main.async {
                    print("latestOpenedDate保存完了")
                    
                }
                
            } catch {
                print("Error fetching spot data5/6: \(error)")
                DispatchQueue.main.async {
                    
                }
            }
        }
        
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goNext() {
        self.performSegue(withIdentifier: "goNext", sender: self)
    }
    
    
    //MARK: glaf
    func setGlaf() {
        var glafRaito: Int = stepsInt / 80
        glafRaito = (glafRaito + 9) / 10
        if glafRaito > 10 {
            glafRaito = 10
        }
        print("glafRaito: \(glafRaito)")
        stepGlaph.image = UIImage(named: "glaf_\(glafRaito)")
        stepLabel.text = "\(stepsInt)"
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
