//
//  LocationService.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 9/1/15.
//
//

import Foundation
import Parse

class LocationService {
  
  class var sharedInstance: LocationService {
    
    struct Singleton {
      
      static let instance = LocationService()
    }
    
    return Singleton.instance
  }
  
  func fetchLocationWithExternalId(externalId: String, completion: (result: Location?) -> ()) {
    let locQuery = PFQuery(className: "Location")
    locQuery.whereKey("externalId", equalTo:externalId)
    
    locQuery.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]?, locError: NSError?) -> Void in
      if locError == nil {
        if let locations = objects as? [PFObject] {
          if locations.count == 0 {
            completion(result: nil)
          } else {
            completion(result: self.convertToLocationModel(locations[0]))
          }
        }
      } else {
        print(locError)
        completion(result: nil)
      }
    }
  }
  
  func findNearestLocationToGivenLoc(coordinate: PFGeoPoint, completion: (result: Location?) -> ()) {
    let locQuery = PFQuery(className: "Location")
    locQuery.whereKey("coordinate", nearGeoPoint:coordinate, withinMiles:0.1)
    
    locQuery.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]?, locError: NSError?) -> Void in
      
      if locError == nil {
        if let locations = objects as? [PFObject] {
          if locations.count == 0 {
            completion(result: nil)
          } else {
            completion(result: self.convertToLocationModel(locations[0]))
          }
        }
      } else {
        print(locError)
        completion(result: nil)
      }
    }
  }
  
  private func convertToLocationModel(locationObject: PFObject) -> Location {
    let coordinate = locationObject["coordinate"] as! PFGeoPoint
    let location = Location(latitude: coordinate.latitude,
      longitude: coordinate.longitude)
    location.parseId = locationObject.objectId
    return location
  }
  
}