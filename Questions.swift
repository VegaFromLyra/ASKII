//
//  Questions.swift
//  ASKII
//
//
//

import UIKit
import CoreLocation

class Question {
  
  // MARK: Initialization
  
  init(content: String, location: CLLocationCoordinate2D) {
    self.content = content
    self.location = location
  }
  
  // MARK: Properties
  
  var content: String
  var location: CLLocationCoordinate2D
  
  // MARK: Methods
  
  func ask() {
    // TODO: Submit this to Parse
    println("Question: \(self.content) about latitude \(self.location.latitude), longitude\(self.location.longitude)")
  }
  
}
