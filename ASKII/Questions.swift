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
  
  init(content: String, location: Location) {
    self.content = content
    self.location = location
  }
  
  // MARK: Properties
  
  var content: String
  var location: Location
  
  // MARK: Methods
  
  func save() {
    
    location.save { (savedLocation) -> () in
      var locationModelId = savedLocation.objectId
      
      var question = PFObject(className:"Question")
      question["content"] = self.content
      question["vote"] = 0
      question["location"] = PFObject(withoutDataWithClassName: "Location", objectId: savedLocation.objectId)
      
      question.saveInBackgroundWithBlock {
        (success: Bool, error: NSError?) -> Void in
        if (success) {
          // TODO: Notify view this was a success
        } else {
          // TODO: Notify view this was an error
          println(error?.description)
        }
      }
    }
  }
}
