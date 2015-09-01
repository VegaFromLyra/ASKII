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
    installation["user"] = PFUser.currentUser()
    installation.saveInBackground()
  }
  
}