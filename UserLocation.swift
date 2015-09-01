//
//  UserLocation.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 9/1/15.
//
//

import Foundation
import Parse
import CoreLocation

class UserLocation {

  let user = PFUser.currentUser()
  var location: CLLocation
  
  init(location: CLLocation) {
    self.location = location
  }
  
  func save(completion: (success: Bool) -> ()) {
    
    let locModel = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    locModel.save { (success) -> () in
      if success {
        var userLocation = PFObject(className: "UserLocation")
        userLocation["user"] = self.user
        userLocation["lastKnownLocation"] = PFObject(withoutDataWithClassName: "Location", objectId: locModel.parseId)
        
        userLocation.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
          completion(success: success)
        }
      } else {
        println("ERROR saving location")
        completion(success: false)
      }
    }
  }
}