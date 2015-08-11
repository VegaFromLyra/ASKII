//
//  Location.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 7/28/15.
//
//

import UIKit
import CoreLocation
import Parse


class Location {
  
  // MARK: Initialization
  
  init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, name: String) {
    self.latitude = latitude
    self.longitude = longitude
    self.name = name
  }
  
  
  // MARK: Properties
  
  var latitude: CLLocationDegrees
  var longitude: CLLocationDegrees
  var name: String
  
  // MARK: Methods
  
  func save(completion: (savedLocation: PFObject) -> ()) {
    
    var locationModel = PFObject(className:"Location")
    locationModel["latitude"] = String(format: "%.3f", latitude)
    locationModel["longitude"] = String(format: "%.3f", longitude)
    locationModel["name"] = name
    
    locationModel.saveInBackgroundWithBlock {
      (success: Bool, error: NSError?) -> Void in
      if (success) {
        completion(savedLocation: locationModel)
      } else {
        println(error?.description)
      }
    }
  }

}
