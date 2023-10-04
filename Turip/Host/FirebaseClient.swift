//
//  FirebaseClient.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/10.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import Kingfisher
import CoreLocation

class FirebaseClient {
    
    var uuidFetched: Bool = false
    
    var userUid: String = ""
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    static let shared = FirebaseClient()
    
    enum errorList: Error {
    case getUserUidError
    }
    
    
    //userUid取得 (Auth)
    func getUserUid() async throws {
        
        guard let user = Auth.auth().currentUser else {
            print("ログイン状態不明")
            userUid = ""
            throw errorList.getUserUidError
        }
        
        userUid = user.uid
        print("userUid: \(userUid)")
    }
    
    
    //userData取得 (Firestore)
    func getUserData() async throws -> UserDataSet {
        //uuid取得
//        if userUid == ""  {
            try await getUserUid()
//        }
        
        let snapshot = try await db.collection("User").document(userUid).getDocument()
        
        if let userData = try? snapshot.data(as: UserDataSet.self) {
            return userData
        } else {
            return UserDataSet(
                id: userUid,
                name: "",
                latestOpenedDate: "",
                goalUID: "",
                currentCoordinate: [:],
                spots: []
            )
        }
    }
    
    //GoalData
    func getGoalData() async throws -> SpotDataSet {
        let userData = try await getUserData()
        let goalUID = userData.goalUID ?? ""
        
            do {
                let goalData = try await getSpotData(spotUID: goalUID)
                print("spotData is available.\nuserData: \(goalData)")
                return goalData
            } catch {
                print("Error fetching spot data: \(error)")
                return SpotDataSet()
            }
    }
    
    
    //spotData取得 (Firestore)
    func getSpotData(spotUID: String) async throws -> SpotDataSet {
        if !spotUID.isEmpty {
            do {
                let snapshot = try await db.collection("Spot").document(spotUID).getDocument()
                let spotData = try snapshot.data(as: SpotDataSet.self)
                print("spotData is available.\nuserData: \(spotData)")
                return spotData
            } catch {
                print("Error fetching spot data: \(error)")
                return SpotDataSet()
                //            throw error
            }
        } else {
            print("Invalid spotUID: \(spotUID)")
            return SpotDataSet(name: "- - - - -", place: "- - - - -", steps: "- - -", time: "--:--")
        }
    }
    
    
    
    
    //SpotData日付取得
    func getSpotDate(spotUID: String) async throws -> String {
        let userData = try await getUserData()
        let spotsArray = userData.spots ?? []
        if let matchingSpot = spotsArray.first(where: { $0["UID"] == spotUID }) {
            print("Matching Dictionary: \(matchingSpot)")
            // matchingDictには条件に一致した辞書型が代入されています
            return matchingSpot["date"] ?? "error:1"
        } else {
            print("No matching dictionary found.")
            //データなし
            return "error:2"
        }
    }
    
    
    //getLatestSpotData取得
    func getLatestSpotData(type1: String, type2: String) async throws -> [String:String] {
        let userData = try await getUserData()
        let spotsArray = userData.spots ?? []
        if let matchingSpot = spotsArray.last(where: { $0["type"] == type1 || $0["type"] == type2 }) {
            print("Matching Dictionary: \(matchingSpot)")
            // matchingDictには条件に一致した辞書型が代入されています
            return matchingSpot
        } else {
            print("No matching dictionary found.")
            //データなし
            return ["date":"0000.00.00"]
        }
    }
    
    //DataVCクラスにて 訪れた場所数をカウント
    func spotsCount() async throws -> spotCountType {
        let userData = try await getUserData()
        let spotsArray = userData.spots ?? []
        let tripCountInt =  spotsArray.filter { $0["type"] == "1" || $0["type"] == "2" }.count
        let tourismCountInt =  spotsArray.filter { $0["type"] == "3"}.count
        let spotCounts = spotCountType(trip: tripCountInt, tourism: tourismCountInt)
        return spotCounts
    }
    
    
    //userDataへspotDataの保存 (Firestore)
    func saveSpotDatatoUser(spotUID: String, date: String, type: String) async throws {
        
        var userData = try await getUserData()
        let oneSpotData = ["UID": spotUID, "date": date, "type": type]
        userData.spots?.append(oneSpotData)
        let docRef = db.collection("User").document(userUid)
        try docRef.setData(from: userData, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    //goalUID・現在地・残歩数の更新保存
    func saveUserDatas(goalUID: String? = nil, currentCoordinateDict: [String:String]? = nil, steps: String? = nil, name: String? = nil, startCoordinateDict: [String:String]? = nil) async throws {
        
        var userData = try await getUserData()
        print(userData)
        
        if let goalUID = goalUID {
            userData.goalUID = goalUID
        }
        
        if let currentCoordinateDict = currentCoordinateDict {
            userData.currentCoordinate = currentCoordinateDict
        }
        
        if let steps = steps {
            userData.remainingSteps = steps
        }
        
        if let name = name {
            userData.name = name
        }
        
        if let startCoordinateDict = startCoordinateDict {
            userData.startCoordinate = startCoordinateDict
        }
        
        let docRef = db.collection("User").document(userUid)
        try docRef.setData(from: userData, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    
    //latestOpenedDateの保存
    func saveLatestOpenedDatetoUser() async throws {
        var userData = try await getUserData()
        print(userData)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let date = dateFormatter.string(from: Date())
        
        userData.latestOpenedDate = date
        let docRef = db.collection("User").document(userUid)
        try docRef.setData(from: userData, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    
    //URLよりStorageから写真の取得
    func getSpotImage(url: String) async throws -> UIImage? {
        let imageURL: URL = URL(string: url)!
        
        return try await withCheckedThrowingContinuation { continuation in
            KingfisherManager.shared.downloader.downloadImage(with: imageURL) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value.image)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    
    //Storageへ写真の保存 & URLのRETURN
    func saveSpotImage(spotImage: UIImage) async throws -> String {
        
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("spotImages")
        let imageName = "\(Date().timeIntervalSince1970).jpg"
        let imageRef = imagesRef.child(imageName)
        
        if let imageData = spotImage.jpegData(compressionQuality: 0.5) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            try await imageRef.putDataAsync(imageData, metadata: metadata)
            let url: URL = try await imageRef.downloadURL()
            let urlStr: String = url.absoluteString
            return urlStr
        } else {
            return "https://firebasestorage.googleapis.com/v0/b/turip-ee2b3.appspot.com/o/spotImages%2FNoneImage.png?alt=media&token=09339f8e-ab1d-4c59-b1a3-02a00840ad4b"
        }
        
    }
    
    
    
    //WhereField 該当UIDのArray取得
    func getMatchingUIDArray(key: String, value: String, completion: @escaping ([String]?, Error?) -> Void) {
        var matchingUIDs: [String] = []
        db.collection("Spot").whereField(key, isEqualTo: value).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("エラー: \(error)")
            } else {
                // 条件に合致するドキュメントが見つかった場合
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        // ドキュメントID（UID）を取得して配列に追加
                        let uid = document.documentID
                        matchingUIDs.append(uid)
                    }
                    // 条件に合致するUIDが配列matchingUIDsに格納されました
                    print("条件に合致するUID: \(matchingUIDs)")
                    completion(matchingUIDs, nil)
                    
                } else {
                    print("条件に合致するドキュメントがありません。")
                    completion(nil, nil)
                }
            }
        }
    }
    
    
    //Spotコレクション全UID - Array取得
    func getAllUIDs(completion: @escaping ([String]?, Error?) -> Void) {
        // ドキュメントのUIDを格納するための配列
        var documentIDs: [String] = []
        db.collection("Spot").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                
                for document in querySnapshot!.documents {
                    let documentID = document.documentID
                    documentIDs.append(documentID)
                }
                
                completion(documentIDs, nil)
            }
        }
    }
    
    
    
    //DataSets
    struct UserDataSet: Codable {
        @DocumentID var id: String?
        var name: String?
        var latestOpenedDate: String?
        var goalUID :String?
        var remainingSteps :String?
        var currentCoordinate :[String:String]?
        var startCoordinate :[String:String]?
        var spots :[[String:String]]?
    }
    
    struct SpotDataSet: Codable {
        @DocumentID var id: String?
        var name: String?
        var place: String?
        var photoURL: String?
        var steps: String?
        var time: String?
        var detail: String?
        var coordinate :[String:String]?
    }
    
    struct spotCountType {
        var trip: Int
        var tourism: Int
    }
    
}




