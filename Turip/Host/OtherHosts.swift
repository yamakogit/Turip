//
//  OtherHostsViewController.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/10.
//

import UIKit
import CoreLocation
import HealthKit

class OtherHosts {
    
    static let shared = OtherHosts()
    
    let healthStore = HKHealthStore()
    var stepsInt = 0
    
    //activityIndicatorView
    static func activityIndicatorView(view:UIView) -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.center = view.center
        activityIndicatorView.style = UIActivityIndicatorView.Style.large
        activityIndicatorView.color = .darkGray
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
        return activityIndicatorView
    }
    
    
    // 逆ジオコーディング
    static func conversionAdress(lat: CLLocationDegrees, lng: CLLocationDegrees) async throws -> String {
        let geocoder = CLGeocoder()
        let photoCLLocation = CLLocation(latitude: lat, longitude: lng)
        
        do {
            
            let placemarks = try await geocoder.reverseGeocodeLocation(photoCLLocation, preferredLocale: Locale(identifier: "ja_JP"))
            
            if let placemark = placemarks.first {
                if let prefecture = placemark.administrativeArea, let locality = placemark.locality {
//                    let address = "\(prefecture)\(locality)" //市区町村
                    let address = "\(prefecture)" //都道府県
                    
                    return address
                }
            }
        } catch {
            print("逆ジオコーディングエラー: \(error.localizedDescription)")
        }
        
        return ""
    }
    
    
    //MARK: Health Main
    func requestAuthorization(completion: @escaping (Int?, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        healthStore.requestAuthorization(toShare: nil, read: [stepType]) { [weak self] success, error in
            if success {
                self?.fetchStepCountForToday(completion: completion)
            } else {
                if let error = error {
                    print("HealthKit authorization failed with error: \(error)")
                    completion(nil, error)
                }
            }
        }
    }
    
    
    //MARK: Health Sub
    func fetchStepCountForToday(completion: @escaping (Int?, Error?) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.startOfDay(for: now)
        let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
            if let result = result, let sum = result.sumQuantity() {
                let steps = sum.doubleValue(for: HKUnit.count())
                DispatchQueue.main.async {
                    self.stepsInt = Int(steps)
                    completion(self.stepsInt, nil) //成功した場合、stepsIntとエラーはnilで返す
                }
            } else {
                completion(nil, error)
            }
        }
        
        healthStore.execute(query)
    }
    
    
    //coordinate変換
    func conversionCoordinate(_ dict: [String:String]) -> CLLocationCoordinate2D {
        let currentCoordinateLat = dict["lat"]
        let currentCoordinateLng = dict["lng"]
        let currentCoordinate2D = CLLocationCoordinate2D(latitude: Double(currentCoordinateLat!)!, longitude: Double(currentCoordinateLng!)!)
        return currentCoordinate2D
    }
    
    
    //タイム計算
    static func timeCalsulate(secondsCount: Int) -> TimeSetString {
        var timeSetInt: TimeSetInt = TimeSetInt()
        var timeSetString: TimeSetString = TimeSetString()
        
        if secondsCount == 0 {
            timeSetInt.minute = 0
            timeSetInt.second = 0
            
        } else if secondsCount < 60 {
            timeSetInt.minute = 0
            timeSetInt.second = secondsCount % 60
            
        } else {
            timeSetInt.minute = secondsCount / 60
            timeSetInt.second = secondsCount % 60
        }
        
        if timeSetInt.minute! < 10 {
            timeSetString.minute = "0\(timeSetInt.minute!)"
        } else {
            timeSetString.minute = "\(timeSetInt.minute!)"
        }
        
        if timeSetInt.second! < 10 {
            timeSetString.second = "0\(timeSetInt.second!)"
        } else {
            timeSetString.second = "\(timeSetInt.second!)"
        }
        
        return timeSetString
    }
    
    struct TimeSetInt {
        var minute: Int?
        var second: Int?
    }
    
    struct TimeSetString {
        var minute: String?
        var second: String?
    }

}
