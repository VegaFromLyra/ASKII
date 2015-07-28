//
//  LocationViewController.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 7/18/15.
//
//

import UIKit
import CoreLocation
import GoogleMaps

typealias JSONParameters = [String: AnyObject]

class LocationViewController: UIViewController {
  
    @IBOutlet weak var mapView: GMSMapView!
  
  
    @IBAction func askQuestion(sender: UIButton) {
      
        if (lastTappedLocation == nil || lastTappedLocationName == nil) {
          // TODO - Implement error view
          println("Please enter a location before asking a question")
        } else {
          if let question = delegate?.question {
            let questionModel = Questions(content: question, location: lastTappedLocation!, locationName: lastTappedLocationName!)
            questionModel.save()
          } else {
            println("ERROR! Question is nil")
          }
        }
    }
  
    // TODO: Encapsulate these two into a Location model
    var lastTappedLocation: CLLocationCoordinate2D?
    var lastTappedLocationName: String?
    // TODO: End
  
    var locationManager: CLLocationManager!
    var delegate: NewQuestion?
 
    override func viewDidLoad() {
        super.viewDidLoad()
      

        // Initialize all the location stuff
        if (mapView != nil) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            mapView.delegate = self
        }
    }
  
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    func placeVenueMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees, name: String) {
      var position = CLLocationCoordinate2DMake(latitude, longitude)
      var marker = GMSMarker(position: position)
      marker.snippet = name
      marker.appearAnimation = kGMSMarkerAnimationPop
      marker.map = mapView
      marker.icon = UIImage(named: "Venue_Icon")
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: CLLocationManagerDelegate
extension LocationViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    
    let location = locations.first as! CLLocation
    
    let camera = GMSCameraPosition.cameraWithLatitude(location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 20)
    mapView.camera = camera
    mapView.myLocationEnabled = true
    mapView.settings.myLocationButton = true
    locationManager.stopUpdatingLocation()
  }
}

// MARK: GMSMapViewDelegate
extension LocationViewController: GMSMapViewDelegate {
  
  func placeMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    var position = CLLocationCoordinate2DMake(latitude, longitude)
    var marker = GMSMarker(position: position)
    marker.snippet = "Ask about here!"
    marker.appearAnimation = kGMSMarkerAnimationPop
    marker.map = mapView
  }

  func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
    lastTappedLocation = marker.position
    lastTappedLocationName = marker.snippet
    placeMarker(marker.position.latitude, longitude: marker.position.longitude)
    return false
  }

  func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
    NSLog("You are at at %f,%f", position.target.latitude, position.target.longitude)
    
    var selectedLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
    
    let venueService = VenueService(location: selectedLocation)
    venueService.loadVenues { venues -> Void in
      println("Load venues")
      
      if let venueInfoList = venues {
        for venueInfo in venueInfoList {
          let venueItem = venueInfo["venue"] as! JSONParameters
          
          let venueName = venueItem["name"]! as! String
          let venueLocation = venueItem["location"] as! JSONParameters
          let venueLatitude = venueLocation["lat"] as! CLLocationDegrees
          let venueLongitude = venueLocation["lng"] as! CLLocationDegrees
          
          self.placeVenueMarker(venueLatitude, longitude: venueLongitude, name: venueName)
        }
      }
    }
  }
  
}
