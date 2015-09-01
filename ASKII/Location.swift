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
    self.coordinate = PFGeoPoint(latitude: latitude, longitude: longitude)
  }
  
  init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, name: String?, externalId: String?) {
    self.coordinate = PFGeoPoint(latitude: latitude, longitude: longitude)
    self.name = name
    self.externalId = externalId
  }
  
  // MARK: Properties
  
  var coordinate: PFGeoPoint
  var name: String?
  var externalId: String?
  var parseId: String?
  
  // MARK: Methods
  
  func save(completion: (success: Bool) -> ()) {
    
    var locationModel = PFObject(className:"Location")
    
    locationModel["coordinate"] = coordinate
    
    if let name = name {
      locationModel["name"] = name
    }
    
    if let externalId = externalId {
      locationModel["externalId"] = externalId
    }
  
    locationModel.saveInBackgroundWithBlock {
      (success: Bool, error: NSError?) -> Void in
      if (success) {
        self.parseId = locationModel.objectId
        completion(success: true)
      } else {
        println(error?.description)
        completion(success: false)
      }
    }
  }
}
