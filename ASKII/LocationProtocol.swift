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
  var selectedLocation: CLLocation? { get set }
  var selectedLocationName: String? { get set }
  var selectedLocationVenueId: String? { get set }
}