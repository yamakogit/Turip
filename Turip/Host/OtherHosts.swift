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
    
    
    //MARK: Health - 歩数許可リクエスト
    func requestAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw NSError(domain: "HealthKitErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device."])
        }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: [stepType]) { success, error in
                if success {
                    continuation.resume(returning: true)
                } else if let error = error {
                    print("HealthKit authorization failed with error: \(error)")
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    
    //MARK: Health - 歩数の取得
    func fetchStepCountForToday(startDate: Date) async throws -> Int  {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: startDate)
        let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
                if let result = result, let sum = result.sumQuantity() {
                    let steps = sum.doubleValue(for: HKUnit.count())
                    continuation.resume(returning: Int(steps))
                } else if let error = error {
                    continuation.resume(throwing: error)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    
    //MARK: 前回のTripからの歩数取得のため、StartDateの算出
    func getTripStartDate() async throws -> Date {
        let userData = try await FirebaseClient.shared.getUserData()
        let latestOpenedDate = userData.latestOpenedDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let date = dateFormatter.date(from: latestOpenedDate ?? "")
        var startDate: Date!
        if date == nil {
            startDate = Date()
        } else {
            //開始日付の計算
            startDate = Calendar.current.date(byAdding: .day, value: 1, to: date!)!
        }
        
        return startDate
    }
    
    
    //MARK: 許可確認・歩数取得
    func fetchStepsIfAuthorized(startDate: Date) async throws -> Int {
        let request = try await requestAuthorization()
        if request {
            let steps = try? await fetchStepCountForToday(startDate: startDate)
            if steps != nil {
                return steps!
            } else {
                return 0
            }
        } else {
            print("Authorization not granted.")
            return 0
        }
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
