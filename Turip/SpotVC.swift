//
//  SpotVC.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/08.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift


class SpotViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var spotImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var spotNameTF: UITextField!
    @IBOutlet weak var spotPlaceTF: UITextField!
    @IBOutlet weak var spotDetailTV: UITextView!
    
    @IBOutlet weak var spotDetailNoneLabel: UILabel!
    @IBOutlet weak var spotBackImage: UIImageView!
    @IBOutlet weak var leafImage: UIImageView!
    
    @IBOutlet weak var okButtonD: UIButton!
    @IBOutlet weak var okLabelD: UILabel!
    @IBOutlet weak var okImageD: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var spotData: FirebaseClient.SpotDataSet = FirebaseClient.SpotDataSet()
    var date: String?
    var assignedDate: String = ""
    var leafType: String = "1"
    
    
    let db = Firestore.firestore()
    //    var date: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spotNameTF.delegate = self
        spotPlaceTF.delegate = self
        
        spotNameTF.tag = 0
        spotPlaceTF.tag = 1
        
        spotNameTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        spotPlaceTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        spotDetailTV.delegate = self
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let nowDate = dateFormatter.string(from: Date())
        assignedDate = date ?? nowDate
        
        //Imageの取得・表示
        FirebaseClient().getSpotImage(url: spotData.photoURL ?? "https://firebasestorage.googleapis.com/v0/b/turip-ee2b3.appspot.com/o/spotImages%2FNoneImage.png?alt=media&token=09339f8e-ab1d-4c59-b1a3-02a00840ad4b") { [weak self] image in
            if let image = image {
                DispatchQueue.main.async {
                    self?.spotImage.image = image
                }
            }
        }
        
        dateLabel.text = assignedDate
        spotNameTF.text = spotData.name ?? ""
        spotPlaceTF.text = spotData.place ?? ""
        spotDetailTV.text = spotData.detail ?? ""
        
        spotImage.layer.cornerRadius = spotImage.frame.size.width / 2
        spotImage.clipsToBounds = true //ImageView円設定
        
        spotBackImage.layer.cornerRadius = 5
        spotBackImage.clipsToBounds = true
        
        setLabelUI()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        if leafType == "3" { //赤
            uiSetting(isEnabled: true)
            leafImage.image = Asset.leafRed.image
            
        } else if leafType == "2" { //黄
            uiSetting(isEnabled: false)
            leafImage.image = Asset.leafYellow.image
            
        } else { //緑
            uiSetting(isEnabled: false)
            leafImage.image = Asset.leafLightGreen.image
        }
        
    }
    
    //TF
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == 0 {
            spotData.name = textField.text!
            
        } else if textField.tag == 1 {
            spotData.place = textField.text!
        }
    }
    
    //TV
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            setLabelUI()
            spotData.detail = text
        }
    }
    
    //透かし文字
    func setLabelUI() {
        if spotDetailTV.text.count == 0 {
            spotDetailNoneLabel.isHidden = false
        } else {
            spotDetailNoneLabel.isHidden = true
        }
    }
    
    @IBAction func okButton() {
        //入力項目の確認...
        var confirmBool = true
        let confirmDict = ["Spot名":spotData.name, "地点の住所":spotData.place, "写真":spotData.photoURL, "Spotの詳細": spotData.detail]
        for (key, value) in confirmDict {
            if value == "" || value == nil {
                confirmBool = false
                AlertHost.alertDef(view: self ,title: "\(key)が\n正しく入力されていません", message: "\(key)を\nもう一度入れ直してください。")
                print("error: \(key) is not found.")
            }
        }
        
        if confirmBool {
            //Firebaseへの保存
            do {
                let docRef = try db.collection("Spot").addDocument(from: spotData)
                print("Success to Add SpotData to Firebase.")
                let uid = docRef.documentID
                spotData.id = uid
                Task {
                    do {
                        try await FirebaseClient.shared.saveSpotDatatoUser(spotUID: uid, date: assignedDate, type: "3")
                        performSegue(withIdentifier: "showTourismDetail", sender: self)
                        
                    }
                    catch {
                        print("EROOROR")
                        print(error.localizedDescription)
                        AlertHost.alertDef(view: self, title: "エラー(code:2)", message: "しばらく経ってから\nやり直してください")
                    }
                }
            } catch let error {
                print("Error1: \(error)\nSpotコレクションへのAddDocumentエラー")
                AlertHost.alertDef(view: self, title: "エラー(code:1)", message: "しばらく経ってから\nやり直してください")
            }
        }
        
    }
    
    
    
    //UI hide設定
    func uiSetting(isEnabled: Bool) {
        
        spotNameTF.isEnabled = isEnabled
        spotPlaceTF.isEnabled = isEnabled
        spotDetailTV.isEditable = isEnabled
        okButtonD.isHidden = !isEnabled
        okLabelD.isHidden = !isEnabled
        okImageD.isHidden = !isEnabled
        
        if isEnabled == true {
            titleLabel.text = "Record Spot!"
        } else {
            titleLabel.text = "Spot Detail"
        }
        
    }
    
    
    
    
    @IBAction func backButton() {
        if leafType == "3" {
            //赤の時
            self.navigationController?.popViewController(animated: true) //(Naviから来る)
        } else {
            //緑・黄の時
            self.dismiss(animated: true, completion: nil) //(モーダルから来る)
        }
    }
    
    
    //MARK: SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTourismDetail" {
            let TourismDetailVC = segue.destination as! TourismDetailViewController
            TourismDetailVC.spotData = spotData
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
