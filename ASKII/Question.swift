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
  var lastUpdatedTime: NSDate?
  var parseId: String?
  
  // MARK: Methods
  
  func save(questionContent: String, questionLocation: Location) {
    var locQuery = PFQuery(className: "Location")
    
    if let locExternalId = questionLocation.externalId {
      locQuery.whereKey("externalId", equalTo:locExternalId)
      
      locQuery.findObjectsInBackgroundWithBlock {
        (objects: [AnyObject]?, locError: NSError?) -> Void in
        if locError == nil {
          if let objects = objects as? [PFObject] {
            if objects.count == 0 {
              var locationModel = Location(latitude: questionLocation.latitude,
                longitude: questionLocation.longitude,
                name: questionLocation.name,
                externalId: questionLocation.externalId)
              
              locationModel.save {
                (savedLocation) -> () in
                self.saveQuestion(questionContent, yesVoteCount: 0, noVoteCount: 0, parseLocation: savedLocation)
              }
            } else {
              self.saveQuestion(questionContent, yesVoteCount: 0, noVoteCount: 0, parseLocation: objects[0])
            }
          }
        } else {
          println(locError)
        }
      }
    } else {
      var locationModel = Location(latitude: questionLocation.latitude,
        longitude: questionLocation.longitude)
      
      locationModel.save {
        (savedLocation) -> () in
        self.saveQuestion(questionContent, yesVoteCount: 0, noVoteCount: 0, parseLocation: savedLocation)
      }
    }
  }
  
  func clearVoteCount(completion: (success: Bool) -> ()) {
    
    var query = PFQuery(className:"Question")
    query.getObjectInBackgroundWithId(parseId!) {
      (question: PFObject?, error: NSError?) -> Void in
      if error != nil {
        println(error)
      } else if let question = question {
        question["yesVoteCount"] = 0
        question["noVoteCount"] = 0

        question.saveInBackgroundWithBlock {
          (success: Bool, error: NSError?) -> Void in
          if (success) {
            completion(success: true)
          } else {
            println(error?.description)
            completion(success: false)
          }
        }
      }
    }
  }
  
  func saveQuestion(content: String, yesVoteCount: Int, noVoteCount: Int, parseLocation: PFObject) {
    var question = PFObject(className:"Question")
    question["content"] = content
    question["yesVoteCount"] = yesVoteCount
    question["noVoteCount"] = noVoteCount
    question["location"] = PFObject(withoutDataWithClassName: "Location", objectId: parseLocation.objectId)
    
    question.saveInBackgroundWithBlock {
      (success: Bool, error: NSError?) -> Void in
      if (success) {
        // TODO: Notify view this was a success
        self.parseId = question.objectId
      } else {
        // TODO: Notify view this was an error
        println(error?.description)
      }
    }
  }
  
  func getAllQuestions(location: Location, completion: (questions: [Question]) -> ()) {
    var locQuery = PFQuery(className: "Location")
    
    if let externalId = location.externalId {
      
      locQuery.whereKey("externalId", equalTo:externalId)
      
      locQuery.findObjectsInBackgroundWithBlock {
        (objects: [AnyObject]?, locError: NSError?) -> Void in
        
        if locError == nil {
          if let objects = objects as? [PFObject] {
            
            if objects.count == 0 {
              completion(questions: [])
            } else {
              
              var location = objects[0];
              
              let locationModel = Location(latitude: location["latitude"] as! CLLocationDegrees,
                longitude: location["longitude"] as! CLLocationDegrees)
              
              if let locName = location["name"] as? String {
                locationModel.name = locName
              }
              
              if let locExternalId = location["exrernalId"] as? String {
                locationModel.externalId = locExternalId
              }
              
              var locationPointer = PFObject(withoutDataWithClassName: "Location", objectId: location.objectId!)
              
              var questionQuery = PFQuery(className:"Question")
              questionQuery.whereKey("location", equalTo:locationPointer)
              questionQuery.orderByDescending("updatedAt")
              
              questionQuery.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, qnError: NSError?) -> Void in
                
                if qnError == nil {
                  var results: [Question] = []
                  if let questions = objects as? [PFObject] {
                    for question in questions {
                      var result: Question =  Question()
                      result.content = question["content"] as? String
                      result.location = locationModel
                      result.yesVotes = question["yesVoteCount"] as? Int
                      result.noVotes = question["noVoteCount"] as? Int
                      result.lastUpdatedTime = question.updatedAt
                      result.parseId = question.objectId
                      
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
    } else {
      // TODO: Fetch questions for all locations within a radius of the given location
      completion(questions: [])
    }
  }
}
