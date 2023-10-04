//
//  DataViewController.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/06.
//

import UIKit
import HealthKit

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    var photo: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        photoImageView.layer.cornerRadius = 10
        photoImageView.clipsToBounds = true
        
        photoImageView.image = photo
    }
    
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
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
