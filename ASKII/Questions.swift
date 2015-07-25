//
//  Questions.swift
//  ASKII
//
//
//

import UIKit
import CoreLocation
import Parse

class Questions {
  
  // MARK: Initialization
  
  init(content: String, location: CLLocationCoordinate2D) {
    self.content = content
    self.location = location
  }
  
  // MARK: Properties
  
  var content: String
  var location: CLLocationCoordinate2D
  
  // MARK: Methods
  
  func save() {
    
    var locationModel = PFObject(className:"Location")
    locationModel["latitude"] = location.latitude
    locationModel["longitude"] = location.longitude
    locationModel.saveInBackgroundWithBlock {
      (success: Bool, error: NSError?) -> Void in
      if (success) {
        var locationModelId = locationModel.objectId
        var question = PFObject(className:"Question")
        question["content"] = self.content
        question["vote"] = 0
        question["location"] = PFObject(withoutDataWithClassName: "Location", objectId: locationModel.objectId)
        
        question.saveInBackgroundWithBlock {
          (success: Bool, error: NSError?) -> Void in
          if (success) {
            // TODO: Notify view it can now proceed to next view
          } else {
            println(error?.description)
          }
        }
      } else {
          println(error?.description)
      }
    }
  }
  
}
