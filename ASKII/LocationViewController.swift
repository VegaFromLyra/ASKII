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

class LocationViewController: UIViewController {
  
    @IBOutlet weak var mapView: GMSMapView!
  
    @IBAction func askQuestion(sender: UIButton) {
      
        if (lastTappedLocation == nil) {
          // TODO - Implement error view
          println("Please enter a location before asking a question")
        } else {
          if let question = delegate?.question {
            let questionModel = Questions(content: question, location: lastTappedLocation!)
            questionModel.save()
          } else {
            println("ERROR! Question is nil")
          }
        }
    }
  
    var lastTappedLocation: CLLocationCoordinate2D?
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
    let camera = GMSCameraPosition.cameraWithLatitude(location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15)
    
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
  
  func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
    lastTappedLocation = coordinate
    placeMarker(coordinate.latitude, longitude: coordinate.longitude)
  }
}
