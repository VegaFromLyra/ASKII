//
//  LocationProtocol.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 8/6/15.
//
//

import UIKit
import CoreLocation


protocol QuestionLocationProtocol {
  var location: CLLocation? { get set }
  var name: String? { get set }
  var venueId: String? { get set }
}