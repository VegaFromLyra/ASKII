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
  
  func saveQuestionWithLocExternalId(content: String, location: Location) {
    var locQuery = PFQuery(className: "Location")
    locQuery.whereKey("externalId", equalTo:location.externalId!)
    
    locQuery.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]?, locError: NSError?) -> Void in
      if locError == nil {
        if let objects = objects as? [PFObject] {
          if objects.count == 0 {
            
            var locationModel = Location(latitude: location.coordinate.latitude,
              longitude: location.coordinate.longitude,
              name: location.name!,
              externalId: location.externalId!)
            
            locationModel.save {
              (savedLocation) -> () in
              self.saveQuestion(content, yesVoteCount: 0, noVoteCount: 0, parseLocation: savedLocation)
            }
          } else {
            self.saveQuestion(content, yesVoteCount: 0, noVoteCount: 0, parseLocation: objects[0])
          }
        }
      } else {
        println(locError)
      }
    }
  }
  
  func saveQuestionWithLoc(content: String, location: Location) {
    var locQuery = PFQuery(className: "Location")
    locQuery.whereKey("coordinate", nearGeoPoint:location.coordinate, withinMiles:0.1)
    
    locQuery.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]?, locError: NSError?) -> Void in
      
      if locError == nil {
        if let locations = objects as? [PFObject] {
          if locations.count == 0 {
            var locationModel = Location(latitude: location.coordinate.latitude,
              longitude: location.coordinate.longitude)
            locationModel.save {
              (savedLocation) -> () in
              self.saveQuestion(content, yesVoteCount: 0, noVoteCount: 0, parseLocation: savedLocation)
            }
          } else {
            self.saveQuestion(content, yesVoteCount: 0, noVoteCount: 0, parseLocation: locations[0])
          }
        }
      } else {
        println(locError)
      }
      
    }
  }
  
  func save(questionContent: String, questionLocation: Location) {
    if let locExternalId = questionLocation.externalId {
      if !locExternalId.isEmpty {
        saveQuestionWithLocExternalId(questionContent, location: questionLocation)
      } else {
        saveQuestionWithLoc(questionContent, location: questionLocation)
      }
    } else {
      saveQuestionWithLoc(questionContent, location: questionLocation)
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
  
  func postComment(comment: String, completion: (success: Bool) -> ()) {
    var query = PFQuery(className:"Question")
    query.getObjectInBackgroundWithId(parseId!) {
      (question: PFObject?, error: NSError?) -> Void in
      if error != nil {
        println(error)
      } else if let question = question {
        var commentQuery = PFObject(className: "Comment")
        commentQuery["content"] = comment
        commentQuery["question"] = PFObject(withoutDataWithClassName: "Question", objectId: self.parseId)
        
        commentQuery.saveInBackgroundWithBlock {
          (success: Bool, error: NSError?) -> Void in
          completion(success: success)
        }
      }
    }
  }
  
  func addYesVote(completion: (success: Bool) -> ()) {
    var query = PFQuery(className:"Question")
    query.getObjectInBackgroundWithId(parseId!) {
      (question: PFObject?, error: NSError?) -> Void in
      if error != nil {
        println(error)
      } else if let question = question {
        question["yesVoteCount"] = question["yesVoteCount"] as! Int + 1
        
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
  
  func addNoVote(completion: (success: Bool) -> ()) {
    var query = PFQuery(className:"Question")
    query.getObjectInBackgroundWithId(parseId!) {
      (question: PFObject?, error: NSError?) -> Void in
      if error != nil {
        println(error)
      } else if let question = question {
        question["noVoteCount"] = question["noVoteCount"] as! Int + 1
        
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
  
  func getLocationModel(locationPFObject: PFObject) -> Location {
    let coordinate = locationPFObject["coordinate"] as! PFGeoPoint
    
    let locationModel = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
    
    if let locName = locationPFObject["name"] as? String {
      locationModel.name = locName
    }
    
    if let locExternalId = locationPFObject["exrernalId"] as? String {
      locationModel.externalId = locExternalId
    }
    
    return locationModel
  }
  
  func getAllQuestionsByExternalId(externalId: String, completion: (questions: [Question]) -> ()) {
    var locQuery = PFQuery(className: "Location")
    
    locQuery.whereKey("externalId", equalTo:externalId)
    
    locQuery.findObjectsInBackgroundWithBlock {
      (locations: [AnyObject]?, locError: NSError?) -> Void in
      
      if locError == nil {
        if let locations = locations as? [PFObject] {
          
          if locations.count == 0 {
            completion(questions: [])
          } else {
            let location = locations[0];
            let coordinate = location["coordinate"] as! PFGeoPoint
            let locationPointer = PFObject(withoutDataWithClassName: "Location", objectId: location.objectId!)
            
            var questionQuery = PFQuery(className:"Question")
            questionQuery.whereKey("location", equalTo:locationPointer)
            questionQuery.orderByDescending("updatedAt")
            
            questionQuery.findObjectsInBackgroundWithBlock {
              (questions: [AnyObject]?, qnError: NSError?) -> Void in
              
              if qnError == nil {
                var results: [Question] = []
                if let questions = questions as? [PFObject] {
                  
                  let locModel = self.getLocationModel(location)
                  
                  for question in questions {
                    var result: Question =  Question()
                    result.content = question["content"] as? String
                    result.location = locModel
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
        println("ERROR: Could not fetch location with external Id \(externalId) " + locError!.localizedDescription)
        completion(questions: [])
      }
    }
  }
  
  func getAllQuestionsByGeoFencing(coordinate: PFGeoPoint, completion: (questions: [Question]) -> ()) {
    var alreadySeenQuestions = Set<String>()
    
    var locQuery = PFQuery(className: "Location")
    locQuery.whereKey("coordinate", nearGeoPoint:coordinate, withinMiles: 0.2)
    locQuery.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]?, qnError: NSError?) -> Void in
      
      var results: [Question] = []
      
      if let locations = objects {
        if locations.count == 0 {
          completion(questions: [])
        } else {
          for locResult in locations {
            let coordinate = locResult["coordinate"] as! PFGeoPoint
            let locationPointer = PFObject(withoutDataWithClassName: "Location", objectId: locResult.objectId!)
            let questionQuery = PFQuery(className:"Question")
            questionQuery.whereKey("location", equalTo:locationPointer)
            questionQuery.orderByDescending("updatedAt")
            
            questionQuery.findObjectsInBackgroundWithBlock {
              (objects: [AnyObject]?, qnError: NSError?) -> Void in
              
              if qnError == nil {
                if let questions = objects as? [PFObject] {
                  
                  let locationModel = self.getLocationModel(locResult as! PFObject)
                  
                  for question in questions {
                    
                    if !alreadySeenQuestions.contains(question.objectId!) {
                      var result: Question =  Question()
                      result.content = question["content"] as? String
                      result.location = locationModel
                      result.yesVotes = question["yesVoteCount"] as? Int
                      result.noVotes = question["noVoteCount"] as? Int
                      result.lastUpdatedTime = question.updatedAt
                      result.parseId = question.objectId
                      
                      results.append(result)
                      
                      alreadySeenQuestions.insert(question.objectId!)
                    }
                  }
                  
                  completion(questions: results)
                }
              } else {
                println("ERROR: Could not fetch questions for coordinate\(coordinate) " + qnError!.localizedDescription)
                completion(questions: [])
              }
            }
          }
        }
      } else {
        completion(questions: [])
      }
    }
  }
  
  // TODO - This should be in a service and not in the model
  func getAllQuestions(location: Location, completion: (questions: [Question]) -> ()) {
    if let externalId = location.externalId {
      getAllQuestionsByExternalId(externalId, completion: {
        (results) -> Void in
        completion(questions: results)
      })
    } else {
      getAllQuestionsByGeoFencing(location.coordinate, completion: {
        (results) -> Void in
        completion(questions: results)
      })
    }
  }
}
