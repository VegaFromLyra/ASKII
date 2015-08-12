//
//  Questions.swift
//  ASKII
//
//
//

import UIKit
import CoreLocation
import Parse

class Question {
  
  // MARK: Properties
  
  var content: String?
  var location: Location?
  var yesVotes: Int?
  var noVotes: Int?
  
  // MARK: Methods
  
  func save(questionContent: String, questionLocation: Location) {
    var locationModel = Location(latitude: questionLocation.latitude,
      longitude: questionLocation.longitude,
      name: questionLocation.name,
      externalId: questionLocation.externalId)
    
    locationModel.save {
      (savedLocation) -> () in
      
      var question = PFObject(className:"Question")
      question["content"] = questionContent
      question["yesVoteCount"] = 0
      question["noVoteCount"] = 0
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
  
  func getAllQuestions(location: Location, completion: (questions: [Question]) -> ()) {
    var locQuery = PFQuery(className: "Location")
    
    locQuery.whereKey("externalId", equalTo:location.externalId)
    
    locQuery.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]?, locError: NSError?) -> Void in
      
      if locError == nil {
        if let objects = objects as? [PFObject] {
          
          if objects.count == 0 {
            completion(questions: [])
          } else {
            
            var location = objects[0];
            
            var locationPointer = PFObject(withoutDataWithClassName: "Location", objectId: location.objectId!)
            
            var questionQuery = PFQuery(className:"Question")
            questionQuery.whereKey("location", equalTo:locationPointer)
            
            questionQuery.findObjectsInBackgroundWithBlock {
              (objects: [AnyObject]?, qnError: NSError?) -> Void in
              
              if qnError == nil {
                var results: [Question] = []
                if let questions = objects as? [PFObject] {
                  for question in questions {
                    var locationModel = Location(latitude: location["latitude"] as! CLLocationDegrees,
                      longitude: location["longitude"] as! CLLocationDegrees,
                      name: location["name"] as! String,
                      externalId: location["externalId"] as! String)
                    var result: Question =  Question()
                    result.content = question["content"] as? String
                    result.location = locationModel
                    result.yesVotes = question["yesVoteCount"] as? Int
                    result.noVotes = question["noVoteCount"] as? Int
                    
                    results.append(result)
                  }
                }
                
                completion(questions: results)
              } else {
                println("ERROR: Could not fetch questions for \(location) " + qnError!.localizedDescription)
                completion(questions: [])
              }
            }
          }
        }
      } else {
        println("ERROR: Could not fetch \(location) " + locError!.localizedDescription)
        completion(questions: [])
      }
    }
  }
}
