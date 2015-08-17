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
  
  init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    self.latitude = latitude
    self.longitude = longitude
  }
  
  init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, name: String?, externalId: String?) {
    self.latitude = latitude
    self.longitude = longitude
    self.name = name
    self.externalId = externalId
  }
  
  // MARK: Properties
  
  var latitude: CLLocationDegrees
  var longitude: CLLocationDegrees
  var name: String?
  var externalId: String?
  
  // MARK: Methods
  
  func save(completion: (savedLocation: PFObject) -> ()) {
    
    var locationModel = PFObject(className:"Location")
    locationModel["latitude"] = latitude
    locationModel["longitude"] = longitude
    
    if let name = name {
      locationModel["name"] = name
    }
    
    if let externalId = externalId {
      locationModel["externalId"] = externalId
    }
  
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
