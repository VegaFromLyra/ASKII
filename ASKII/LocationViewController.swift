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

// TODO: Define it a common place
typealias JSONParameters = [String: AnyObject]

class LocationViewController: UIViewController, LocationProtocol {
  
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchButton: UIButton!
  
    @IBAction func askQuestion(sender: UIButton) {
      if selectedMarker != nil {
        if let question = delegate?.question {
          let questionModel = Questions(content: question, location: locationModel!)
          questionModel.save()
        } else {
          println("ERROR! Question is nil")
        }
      } else {
        println("TODO: Show error view that a location must be selected ")
      }

    }
  
    // TODO: Should I instantiate here or in init?
    let venueService = VenueService()
    var locationModel: Location?
    var selectedMarker: GMSMarker?
    var currentLocation: CLLocation?
  
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
          
            // So that the current location is visible and can
            // be interacted with
            mapView.bringSubviewToFront(searchButton)
          
            if let recognizers = mapView.gestureRecognizers {
              for recognizer in recognizers {
                mapView.removeGestureRecognizer(recognizer as! UIGestureRecognizer)
              }
            }
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
      marker.title = name
      marker.appearAnimation = kGMSMarkerAnimationPop
      marker.map = mapView
      marker.icon = UIImage(named: "Venue_Icon")
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
      if segue.destinationViewController is SearchLocationViewController {
          var searchLocationViewController = segue.destinationViewController as! SearchLocationViewController
          searchLocationViewController.delegate = self
      }
    }

}

// MARK: CLLocationManagerDelegate
extension LocationViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    
    currentLocation = locations.first as? CLLocation
  
    let camera = GMSCameraPosition.cameraWithLatitude(currentLocation!.coordinate.latitude,
      longitude: currentLocation!.coordinate.longitude,
      zoom: 17)
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
    
    if selectedMarker != nil {
      selectedMarker!.map = nil
    }
  
    var marker = GMSMarker(position: position)
    marker.title = "Ask about here!"
    marker.appearAnimation = kGMSMarkerAnimationPop
    marker.map = mapView
    selectedMarker = marker
  }

  func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
    locationModel = Location(latitude: marker.position.latitude, longitude: marker.position.longitude, name: marker.title)
    placeMarker(marker.position.latitude, longitude: marker.position.longitude)
    return false
  }

  func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
    NSLog("You are at at %f,%f", position.target.latitude, position.target.longitude)
    
    var selectedLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)

    venueService.loadVenues(selectedLocation, completion: {
      venues -> Void in
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
    })
  }
}
