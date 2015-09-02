//
//  AppService.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 9/1/15.
//
//

import Parse

class AppService {
  
  class var sharedInstance: AppService {
    
    struct Singleton {
      
      static let instance = AppService()
    }
    
    return Singleton.instance
  }
  
  func initialize() {
    let installation = PFInstallation.currentInstallation()
    
    let channels = installation.channels as? [String]
    
    var isChannelSet = false
    
    if let channels = channels {
      for channel in channels {
        if channel == "Questions" {
          isChannelSet = true
          break
        }
      }
    }
  
    if !isChannelSet {
      installation["user"] = PFUser.currentUser()
      installation.addUniqueObject("Questions", forKey: "channels")
      installation.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
        if success {
          println("Updated installation")
        } else {
          println("Could not update installation")
        }
      }
    }
   
    println(PFInstallation.currentInstallation().channels)
  }
  
}