//
//  Utility.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 8/19/15.
//
//

import Foundation
import CoreLocation
import GoogleMaps


class UtilityService {
  
  
  class var sharedInstance: UtilityService {

    struct Singleton {
      
      static let instance = UtilityService()
    }

    return Singleton.instance
  }
  
  func getLocationName(loc: CLLocation, completion:(name: String) -> ()) {
    let geoCoder = GMSGeocoder()
    geoCoder.reverseGeocodeCoordinate(loc.coordinate) { response, error in
      if let address = response.firstResult() {
        let lines = address.lines as! [String]
        completion(name: lines.joinWithSeparator(", "))
      }
    }
  }
  
  func getTimeElapsed(submittedTime: NSDate) -> String {
    let elapsedTimeInterval = NSDate().timeIntervalSinceDate(submittedTime)
    let durationInSeconds = Int(elapsedTimeInterval)
    var output = ""
    if durationInSeconds <= 60 {
      output = String(durationInSeconds) + " s:"
    } else if durationInSeconds <= 3600 {
      output = String(durationInSeconds / 60) + " m:"
    } else if durationInSeconds <= 86400 {
      output = String(durationInSeconds / 3600) + " h:"
    } else if durationInSeconds <= 604800 {
      output = String(durationInSeconds / 86400) + " d:"
    } else {
      output = String(durationInSeconds / 604800) + " w:"
    }
    
    return output
  }
  
  func getPopularVote(yesVoteCount: Int, noVoteCount: Int) -> String {
    var output = ""
    if yesVoteCount > noVoteCount {
      output = "yes"
    } else if noVoteCount > yesVoteCount {
      output = "no"
    }
    
    return output
  }
  
  func getPopularVoteBackgroundColor(yesVoteCount: Int, noVoteCount: Int) -> UIColor {
    var output = UIColor.whiteColor()
    
    if yesVoteCount > noVoteCount {
      output = UIColor.cyanColor()
    } else if noVoteCount > yesVoteCount {
      output = UIColor.redColor()
    }
    
    return output
  }

  func getPopularVoteTextColor(yesVoteCount: Int, noVoteCount: Int) -> UIColor {
    var output = UIColor.whiteColor()
    
    if yesVoteCount > noVoteCount {
      output = UIColor.blueColor()
    } else if noVoteCount > yesVoteCount {
      output = UIColor.redColor()
    }
    
    return output
  }
  
  func showAlert(title: String, message: String, action: UIAlertAction, controller: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(action)
    controller.presentViewController(alert, animated: true, completion: nil)
  }
  
  func getCurrentViewController(rootViewController: UIViewController?) -> UIViewController? {
    if let rootController = rootViewController {
      
      var currentController: UIViewController! = rootController
      
      // Each ViewController keeps track of the view it has presented, so we
      // can move from the head to the tail, which will always be the current view
      while (currentController.presentedViewController != nil) {
        currentController = currentController.presentedViewController
      }
      
      return currentController
      
    } else {
      return nil
    }
  }
}