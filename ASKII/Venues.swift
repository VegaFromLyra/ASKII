//
//  Venues.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 7/28/15.
//
//

import Foundation
import UIKit
import CoreLocation
import MapKit

import QuadratTouch

class VenueService {
  
  var session: Session!
  var venueItems : [[String: AnyObject]]?
  
  init() {
    session = Session.sharedSession()
  }
  
  func loadVenues(location: CLLocation, completion: ([[String: AnyObject]]?) -> ()) {
    var parameters = location.parameters()
    let task = session.venues.explore(parameters) {
      (result) -> Void in
      if result.response != nil {
        if let groups = result.response!["groups"] as? [[String: AnyObject]] {
          var venues = [[String: AnyObject]]()
          for group in groups {
            if let items = group["items"] as? [[String: AnyObject]] {
              venues += items
            }
          }
          
          completion(venues)
          
        }
      } else if result.error != nil && !result.isCancelled() {
          println(result.error!)
      }
    }
    task.start()
  }
  
}

extension CLLocation {
  func parameters() -> Parameters {
    let ll      = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
    let llAcc   = "\(self.horizontalAccuracy)"
    let alt     = "\(self.altitude)"
    let altAcc  = "\(self.verticalAccuracy)"
    let parameters = [
      Parameter.ll:ll,
      Parameter.llAcc:llAcc,
      Parameter.alt:alt,
      Parameter.altAcc:altAcc
    ]
    return parameters
  }
}
