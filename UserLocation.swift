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
  let locationService = LocationService.sharedInstance
  
  var location: CLLocation
  
  
  init(location: CLLocation) {
    self.location = location
  }
  
  func save(completion: (success: Bool) -> ()) {
    
    let locModel = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    
    locModel.save { (success) -> () in
      if success {
        
        let query = PFQuery(className: "UserLocation")
        query.whereKey("user", equalTo: self.user!)
        
        query.findObjectsInBackgroundWithBlock({ (results: [AnyObject]?, error: NSError?) -> Void in
          if error == nil {
            if let results = results {
              if results.count == 0 {
                let userLocation = PFObject(className: "UserLocation")
                userLocation["user"] = self.user
                userLocation["lastKnownLocation"] = PFObject(withoutDataWithClassName: "Location", objectId: locModel.parseId)
                
                userLocation.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                  completion(success: success)
                }
              } else {
                let currentUserLocation = results[0] as! PFObject
                currentUserLocation["lastKnownLocation"] = PFObject(withoutDataWithClassName: "Location", objectId: locModel.parseId)
                
                currentUserLocation.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                  completion(success: success)
                })
              }
            }
          } else {
            completion(success: false)
          }
        })
      } else {
        print("ERROR saving location")
        completion(success: false)
      }
    }
  }
}