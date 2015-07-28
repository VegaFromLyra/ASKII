//
//  Location.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 7/28/15.
//
//

import UIKit
import CoreLocation

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
  
  // TODO: Move location saving out of Questions
  
}
