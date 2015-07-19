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

extension NewQLocationViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    
    let location = locations.first as! CLLocation
    let camera = GMSCameraPosition.cameraWithLatitude(location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15)
//    mainMapView.camera = camera
//    mainMapView.myLocationEnabled = true
//    mainMapView.settings.myLocationButton = true
    locationManager.stopUpdatingLocation()
    println("Latitude: \(location.coordinate.latitude). Longitude: \(location.coordinate.longitude).")
  }
  
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
  }
}
