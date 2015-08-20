//
//  Comment.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 8/20/15.
//
//

import Foundation


class Comment {
  
  let content:String
  var lastUpdatedTime: NSDate
  
  init(content: String, lastUpdatedTime: NSDate) {
    self.content = content
    self.lastUpdatedTime = lastUpdatedTime
  }
}
