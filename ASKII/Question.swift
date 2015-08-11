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
      name: questionLocation.name)
    
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
    
    // locQuery.whereKey("latitude", equalTo:String(format: "%.3f", location.latitude))
    // locQuery.whereKey("longitude", equalTo:String(format: "%.3f", location.longitude))
    locQuery.whereKey("name", equalTo:location.name)
    
    
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
                if let objects = objects as? [PFObject] {
                  for object in objects {
                    var locationModel = Location(latitude: (location["latitude"] as! NSString).doubleValue,
                      longitude: (location["longitude"] as! NSString).doubleValue,
                      name: location["name"] as! String)
                    var question: Question =  Question()
                    question.content = object["content"] as? String
                    question.location = locationModel
                    question.yesVotes = object["yesVoteCount"] as? Int
                    question.noVotes = object["noVoteCount"] as? Int
                    
                    results.append(question)
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
