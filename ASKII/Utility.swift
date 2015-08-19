//
//  Utility.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 8/19/15.
//
//

import Foundation
import CoreLocation
import GoogleMaps


class UtilityService {
  
  
  class var sharedInstance: UtilityService {

    struct Singleton {
      
      static let instance = UtilityService()
    }

    return Singleton.instance
  }
  
  func getLocationName(loc: CLLocation, completion:(name: String) -> ()) {
    let geoCoder = GMSGeocoder()
    geoCoder.reverseGeocodeCoordinate(loc.coordinate) { response, error in
      if let address = response.firstResult() {
        let lines = address.lines as! [String]
        completion(name: join(", ", lines))
      }
    }
  }
}