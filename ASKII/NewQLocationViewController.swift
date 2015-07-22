//
//  NewQLocationViewController.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 7/18/15.
//
//

import UIKit
import CoreLocation
import GoogleMaps

class NewQLocationViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
  
    var locationManager: CLLocationManager!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize all the location stuff
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
    }
  
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
      
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
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
extension NewQLocationViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    
    let location = locations.first as! CLLocation
    let camera = GMSCameraPosition.cameraWithLatitude(location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15)
    
    mapView.camera = camera
    mapView.myLocationEnabled = true
    mapView.settings.myLocationButton = true
    locationManager.stopUpdatingLocation()
    
  }
  
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
  }
}

// MARK: GMSMapViewDelegate
extension NewQLocationViewController: GMSMapViewDelegate {
  
  func placeMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    var position = CLLocationCoordinate2DMake(latitude, longitude)
    var marker = GMSMarker(position: position)
    marker.snippet = "Ask about here!"
    marker.appearAnimation = kGMSMarkerAnimationPop
    marker.map = mapView
  }
  
  func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
    NSLog("You tapped at %f,%f", coordinate.latitude, coordinate.longitude)
    placeMarker(coordinate.latitude, longitude: coordinate.longitude)
  }
}
