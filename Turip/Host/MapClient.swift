//
//  AlertHost.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/12.
//

import UIKit
import MapKit
import CoreLocation

class MapClient {
    
    //2緯度経度間の距離
    static func calculateDistance(startCoordinateDict: [String:String], endCoordinateDict: [String:String]) -> Int {
        
        let startLat = Double(startCoordinateDict["lat"]!)!
        let startLng = Double(startCoordinateDict["lng"]!)!
        let startLocation = CLLocation(latitude: startLat, longitude: startLng)
        
        let endLat = Double(endCoordinateDict["lat"]!)!
        let endLng = Double(endCoordinateDict["lng"]!)!
        let endLocation = CLLocation(latitude: endLat, longitude: endLng)
        
        let distanceInMeters = startLocation.distance(from: endLocation) //2点間の距離
        
        return Int(distanceInMeters)
    }
    
    
    //2緯度経度間を直線上指定距離分進む・進んだ先の緯度経度取得
    static func decideNewLocation(startCoordinateDict: [String:String], endCoordinateDict: [String:String], distance: Double) -> [String:String]  {
        
        let startLat = Double(startCoordinateDict["lat"]!)!
        let startLng = Double(startCoordinateDict["lng"]!)!
        let startLocation = CLLocationCoordinate2D(latitude: startLat, longitude: startLng)
        
        let endLat = Double(endCoordinateDict["lat"]!)!
        let endLng = Double(endCoordinateDict["lng"]!)!
        let endLocation = CLLocationCoordinate2D(latitude: endLat, longitude: endLng)
        
        // スタートからゴールまでの方向角度 計算
        let lat1 = startLocation.latitude.radians
        let lon1 = startLocation.longitude.radians
        let lat2 = endLocation.latitude.radians
        let lon2 = endLocation.longitude.radians
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x)
        
        // スタート座標から直線上に指定の距離進むための新しい座標を計算
        let earthRadius = 6371000.0 // 地球の半径（m）
        let newLat = asin(sin(lat1) * cos(distance / earthRadius) + cos(lat1) * sin(distance / earthRadius) * cos(bearing))
        let newLon = lon1 + atan2(sin(bearing) * sin(distance / earthRadius) * cos(lat1), cos(distance / earthRadius) - sin(lat1) * sin(newLat))
        
        // 新しい座標を度数法に戻す
        let newLatDegrees = newLat.degrees
        let newLonDegrees = newLon.degrees
        
        let newCoordinate = CLLocationCoordinate2D(latitude: newLatDegrees, longitude: newLonDegrees)
        
        let newCoordinateDict = ["lat": "\(newCoordinate.latitude)", "lng": "\(newCoordinate.longitude)"]
        
        return newCoordinateDict
    }
    
    
}


// 度数法からラジアンに変換する拡張
//Doubleの拡張
//let angle: Double = 45.0
//let radian = angle.radians // 45度をラジアンに変換

extension Double {
    var radians: Double {
        return self * .pi / 180
    }
    
    var degrees: Double {
        return self * 180 / .pi
    }
}
