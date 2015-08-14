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
  var searchResults: [(name: String, area: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, venueId: String)] = []
  
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
  
  func search(location: CLLocation, query: String,
    completion: ([(name: String, area: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, venueId: String)]) -> ()) {
      
    if searchResults.count > 0 {
      searchResults.removeAll(keepCapacity: false)
    }
      
    var parameters = [Parameter.query:query, Parameter.intent:"browse", Parameter.radius:"800", Parameter.limit:"10"]
    parameters += location.parameters()
    let searchTask = session.venues.search(parameters) {
      (result) -> Void in
      if let response = result.response {
        var results = response["venues"] as? [JSONParameters]
   
        if let venues = results {
          for venue in venues {
            var location = venue["location"] as! JSONParameters
            let name = venue["name"] as! String
            let venueId = venue["id"] as! String
            let city = location["city"] as! String?
            let state = location["state"] as! String?
            let latitude = location["lat"] as! CLLocationDegrees
            let longitude = location["lng"] as! CLLocationDegrees
            var area:String = ""
            
            if let city = city, state = state {
              if !city.isEmpty && !state.isEmpty {
                area = city + ", " + state
              } else if !city.isEmpty {
                area = city
              } else if !state.isEmpty {
                area = state
              }
            }
            
            self.searchResults.append(name: name, area: String(area), latitude:latitude, longitude: longitude, venueId: venueId)
          }
        }
      
        completion(self.searchResults)
      }
    }
    searchTask.start()
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
