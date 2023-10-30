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
        
        UserDefaults.standard.removeObject(forKey: "tripSteps")
        UserDefaults.standard.removeObject(forKey: "calculatedDistance")
        UserDefaults.standard.removeObject(forKey: "goalUID")
        UserDefaults.standard.removeObject(forKey: "newCoordinate")
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        Task {
            do {
                
                let todaySteps = try await OtherHosts.shared.fetchStepsIfAuthorized(startDate: Date())
                self.stepsInt = todaySteps
                self.setGlaf()
                UserDefaults.standard.set(todaySteps, forKey: "todaySteps")
                
                let startDate = try await OtherHosts.shared.getTripStartDate()
                let tripSteps = try await OtherHosts.shared.fetchStepsIfAuthorized(startDate: startDate)
                UserDefaults.standard.set(tripSteps, forKey: "tripSteps")
                
                print("AA今日の歩数：\(todaySteps)歩")
                print("AA今日進む歩数：\(tripSteps)歩")
                
                try await FirebaseClient.shared.saveLatestOpenedDatetoUser()
                
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
        if glafRaito >= 10  {
            if stepsInt < 8000 {
                glafRaito = 9
            } else {
                glafRaito = 10
            }
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
