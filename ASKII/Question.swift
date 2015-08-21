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
  
  var content: String
  var location: Location
  var yesVotes: Int = 0
  var noVotes: Int = 0
  var lastUpdatedTime: NSDate?
  var id: String?
  
  // MARK: Methods
  
  init(content: String, location: Location, yesVotes: Int, noVotes: Int, id: String, lastUpdatedTime: NSDate) {
    self.content = content
    self.location = location
    self.yesVotes = yesVotes
    self.noVotes = noVotes
    self.id = id
    self.lastUpdatedTime = lastUpdatedTime
  }
  
  init(content: String, location: Location) {
    self.content = content
    self.location = location
  }
  
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
  
  func save() {
    if let locExternalId = location.externalId {
      if !locExternalId.isEmpty {
        saveQuestionWithLocExternalId(content, location: location)
      } else {
        saveQuestionWithLoc(content, location: location)
      }
    } else {
      saveQuestionWithLoc(content, location: location)
    }
  }
  
  func clearVoteCount(completion: (success: Bool) -> ()) {
    var query = PFQuery(className:"Question")
    query.getObjectInBackgroundWithId(id!) {
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
    query.getObjectInBackgroundWithId(id!) {
      (question: PFObject?, error: NSError?) -> Void in
      if error != nil {
        println(error)
      } else if let question = question {
        var commentQuery = PFObject(className: "Comment")
        commentQuery["content"] = comment
        commentQuery["question"] = PFObject(withoutDataWithClassName: "Question", objectId: self.id)
        
        commentQuery.saveInBackgroundWithBlock {
          (success: Bool, error: NSError?) -> Void in
          completion(success: success)
        }
      }
    }
  }
  
  func addYesVote(completion: (success: Bool) -> ()) {
    var query = PFQuery(className:"Question")
    query.getObjectInBackgroundWithId(id!) {
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
    query.getObjectInBackgroundWithId(id!) {
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
        self.id = question.objectId!
      } else {
        // TODO: Notify view this was an error
        println(error?.description)
      }
    }
  }
  
  func getComments(completion: (comments: [Comment]) -> ()) {
    var commentQuery = PFQuery(className: "Comment")
    var questionPointer = PFObject(withoutDataWithClassName: "Question", objectId: self.id)
    commentQuery.whereKey("question", equalTo: questionPointer)
 
    commentQuery.findObjectsInBackgroundWithBlock {
      (comments: [AnyObject]?, error: NSError?) -> Void in
      
      if error == nil {
        if let commentObjects = comments as? [PFObject] {
          var results: [Comment] = []
          for commentObject in commentObjects {
            var comment = Comment(content: commentObject["content"] as! String, lastUpdatedTime: commentObject.updatedAt!)
            results.append(comment)
          }
          completion(comments: results)
        } else {
          completion(comments: [])
        }
      } else {
        println(error)
        completion(comments: [])
      }
    }
  }
  
  func refresh(completion: (success: Bool) -> ()) {
    var query = PFQuery(className:"Question")
    query.getObjectInBackgroundWithId(id!) {
      (result: PFObject?, error: NSError?) -> Void in
      if error != nil {
        println(error)
        completion(success: false)
      } else if let result = result {
        self.content = result["content"] as! String
        self.yesVotes = result["yesVoteCount"] as! Int
        self.noVotes = result["noVoteCount"] as! Int
        // TODO: Do we need to fetch location?
        completion(success: true)
      }
    }
  }
}
