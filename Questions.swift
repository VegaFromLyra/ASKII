//
//  Questions.swift
//  ASKII
//
//
//

import UIKit

class Question {
  
  // MARK: Initialization
  
  init?(content: String) {
    self.content = content
    
    if content.isEmpty {
      return nil
    }
  }
  
  // MARK: Properties
  
  var content: String
  
}
