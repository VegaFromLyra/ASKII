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
  
  let locationService = LocationService.sharedInstance
  
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
  
  private func saveQuestionWithLocExternalId(content: String, location: Location) {
    
    locationService.fetchLocationWithExternalId(location.externalId!, completion: { (result) -> () in
      if let result = result {
        self.saveQuestion(content, yesVoteCount: 0, noVoteCount: 0, locationModel: result)
      } else {
        location.save({ (success) -> () in
          if success {
            self.saveQuestion(content, yesVoteCount: 0, noVoteCount: 0, locationModel: location)
          } else {
            print("Could not save location")
          }
        })
      }
    })
  }
  
  private func saveQuestionWithLoc(content: String, location: Location) {
    
    locationService.findNearestLocationToGivenLoc(location.coordinate, completion: { (result) -> () in
      if let result = result {
        self.saveQuestion(content, yesVoteCount: 0, noVoteCount: 0, locationModel: result)
      } else {
        location.save({ (success) -> () in
          if success {
            self.saveQuestion(content, yesVoteCount: 0, noVoteCount: 0, locationModel: location)
          } else {
            print("Could not save location")
          }
        })
      }
    })
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
    let query = PFQuery(className:"Question")
    query.getObjectInBackgroundWithId(id!) {
      (question: PFObject?, error: NSError?) -> Void in
      if error != nil {
        print(error)
      } else if let question = question {
        question["yesVoteCount"] = 0
        question["noVoteCount"] = 0
        
        question.saveInBackgroundWithBlock {
          (success: Bool, error: NSError?) -> Void in
          if (success) {
            completion(success: true)
          } else {
            print(error?.description)
            completion(success: false)
          }
        }
      }
    }
  }
  
  func postComment(comment: String, completion: (success: Bool) -> ()) {
    let query = PFQuery(className:"Question")
    query.getObjectInBackgroundWithId(id!) {
      (question: PFObject?, error: NSError?) -> Void in
      if error != nil {
        print(error)
      } else {
        let commentQuery = PFObject(className: "Comment")
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
    let query = PFQuery(className:"Question")
    query.getObjectInBackgroundWithId(id!) {
      (question: PFObject?, error: NSError?) -> Void in
      if error != nil {
        print(error)
      } else if let question = question {
        question["yesVoteCount"] = question["yesVoteCount"] as! Int + 1
        
        question.saveInBackgroundWithBlock {
          (success: Bool, error: NSError?) -> Void in
          if (success) {
            completion(success: true)
          } else {
            print(error?.description)
            completion(success: false)
          }
        }
      }
    }
  }
  
  func addNoVote(completion: (success: Bool) -> ()) {
    let query = PFQuery(className:"Question")
    query.getObjectInBackgroundWithId(id!) {
      (question: PFObject?, error: NSError?) -> Void in
      if error != nil {
        print(error)
      } else if let question = question {
        question["noVoteCount"] = question["noVoteCount"] as! Int + 1
        
        question.saveInBackgroundWithBlock {
          (success: Bool, error: NSError?) -> Void in
          if (success) {
            completion(success: true)
          } else {
            print(error?.description)
            completion(success: false)
          }
        }
      }
    }
  }
  
  func saveQuestion(content: String, yesVoteCount: Int, noVoteCount: Int, locationModel: Location) {
    let question = PFObject(className:"Question")
    question["content"] = content
    question["yesVoteCount"] = yesVoteCount
    question["noVoteCount"] = noVoteCount
    question["location"] = PFObject(withoutDataWithClassName: "Location", objectId: locationModel.parseId)
    
    question.saveInBackgroundWithBlock {
      (success: Bool, error: NSError?) -> Void in
      if (success) {
        // TODO: Notify view this was a success
        self.id = question.objectId!
      } else {
        // TODO: Notify view this was an error
        print(error?.description)
      }
    }
  }
  
  func getComments(completion: (comments: [Comment]) -> ()) {
    let commentQuery = PFQuery(className: "Comment")
    let questionPointer = PFObject(withoutDataWithClassName: "Question", objectId: self.id)
    commentQuery.whereKey("question", equalTo: questionPointer)
 
    commentQuery.findObjectsInBackgroundWithBlock {
      (comments: [AnyObject]?, error: NSError?) -> Void in
      
      if error == nil {
        if let commentObjects = comments as? [PFObject] {
          var results: [Comment] = []
          for commentObject in commentObjects {
            let comment = Comment(content: commentObject["content"] as! String, lastUpdatedTime: commentObject.updatedAt!)
            results.append(comment)
          }
          completion(comments: results)
        } else {
          completion(comments: [])
        }
      } else {
        print(error)
        completion(comments: [])
      }
    }
  }
  
  func refresh(completion: (success: Bool) -> ()) {
    let query = PFQuery(className:"Question")
    query.getObjectInBackgroundWithId(id!) {
      (result: PFObject?, error: NSError?) -> Void in
      if error != nil {
        print(error)
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
