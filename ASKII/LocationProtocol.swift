//
//  LocationProtocol.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 8/6/15.
//
//

import UIKit
import CoreLocation


protocol LocationProtocol {
  var currentLocation: CLLocation? { get set }
  var name: String? { get set }
}