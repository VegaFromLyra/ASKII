//
//  AppDelegate.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 7/1/15.
//
//

import UIKit
import GoogleMaps

import Bolts // For PFInstallation

import Parse
import ParseCrashReporting

import QuadratTouch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    ParseCrashReporting.enable()
    
    Parse.setApplicationId("dKuZJBCKptqtbJ4Fn3NjP0Ize2WRReIMhhtV0bbn",
      clientKey: "XV9FgyMTOVdio5LzCEaZVbafrrvTalPnlllZTO8y")
    
    PFUser.enableAutomaticUser()
    
    let defaultACL = PFACL();
    PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
    
    GMSServices.provideAPIKey("AIzaSyAJVPgK5pP7NeMHEaStJvL-RQQm49ybADY")
    
    setUpFoursquare()
    
    registerForPushNotifications(application, launchOptions: launchOptions)
    
    AppService.sharedInstance.initialize()
    
    return true
  }
  
  func registerForPushNotifications(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
    // Register for Push Notitications
    if application.applicationState != UIApplicationState.Background {
      // Track an app open here if we launch with a push, unless
      // "content_available" was used to trigger a background push (introduced in iOS 7).
      // In that case, we skip tracking here to avoid double counting the app-open.
      
      let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
      let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
      var pushPayload = false
      if let options = launchOptions {
        pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
      }
      if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
      }
    }
    // NOTE: This will only work for iOS 8
    if application.respondsToSelector("registerUserNotificationSettings:") {
      let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
      let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
      application.registerUserNotificationSettings(settings)
      application.registerForRemoteNotifications()
    }
  }
  
  func setUpFoursquare() {
    let client = Client(clientID: "AND2OI2AELMCOW1P2GCF4S1IEGYYEYXV5KIWKSVX3IY5EEAU",
      clientSecret: "Y5NM3VGKVYQRZ1YBNAIXWBBOMHGCNADD2RPN1PD3D30RL4KA",
      redirectURL: "askii://foursquare")
    var configuration = Configuration(client:client)
    configuration.mode = "foursquare"
    configuration.shouldControllNetworkActivityIndicator = true
    Session.setupSharedSessionWithConfiguration(configuration)
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation:  AnyObject?) -> Bool {
    return Session.sharedSession().handleURL(url)
  }
  
  //--------------------------------------
  // MARK: Push Notifications
  //--------------------------------------
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    let installation = PFInstallation.currentInstallation()
    installation.setDeviceTokenFromData(deviceToken)
    installation.saveInBackground()
    
    PFPush.subscribeToChannelInBackground("") { (succeeded: Bool, error: NSError?) in
      if succeeded {
        println("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
      } else {
        println("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
      }
    }
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    if error.code == 3010 {
      println("Push notifications are not supported in the iOS Simulator.")
    } else {
      println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
    }
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    PFPush.handlePush(userInfo)
    if application.applicationState == UIApplicationState.Inactive {
      PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
    }
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    if application.applicationState == UIApplicationState.Inactive {
      PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
    }
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}

