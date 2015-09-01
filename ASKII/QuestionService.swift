//
//  QuestionService.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 8/20/15.
//
//

import Foundation
import Parse
import CoreLocation

// TODO - Should be a singleton
class QuestionService {
  
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
                    var result: Question =  Question(content: question["content"] as! String,
                      location: locModel,
                      yesVotes: question["yesVoteCount"] as! Int,
                      noVotes: question["noVoteCount"] as! Int,
                      id: question.objectId!,
                      lastUpdatedTime: question.updatedAt!)
                    
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
                      
                      var result: Question =  Question(content: question["content"] as! String,
                        location: locationModel,
                        yesVotes: question["yesVoteCount"] as! Int,
                        noVotes: question["noVoteCount"] as! Int,
                        id: question.objectId!,
                        lastUpdatedTime: question.updatedAt!)
                      
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