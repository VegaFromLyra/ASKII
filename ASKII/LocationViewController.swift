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
  @IBOutlet weak var qnaDetailsTableView: UITableView!
  @IBOutlet weak var numberOfQuestions: UILabel!
  
  @IBAction func goBack(sender: AnyObject) {
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    var controller = storyboard.instantiateViewControllerWithIdentifier("QuestionViewController") as! UIViewController
    self.presentViewController(controller, animated: true, completion: nil)
  }
  
  
  // TODO: Should I instantiate here or in init?
  let venueService = VenueService()
  var selectedMarker: GMSMarker?
  var selectedVenueMarker: GMSMarker?
  
  // MARK: LocationProtocol
  var selectedLocation: CLLocation?
  var selectedLocationName: String?
  var selectedLocationVenueId: String?
  
  
  var camera: GMSCameraPosition?
  var hasCurrentLocationBeenFetched: Bool = false
  var locationManager: CLLocationManager!
  var delegate: NewQuestion?
  var locationDelegate: LocationProtocol?
  var inSearchMode: Bool = false
  let questionService:QuestionService = QuestionService()
  var allQuestions:[Question] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    qnaDetailsTableView.delegate = self
    qnaDetailsTableView.dataSource = self
    
    
    // Initialize all the location stuff
    if mapView != nil {
      locationManager = CLLocationManager()
      locationManager.delegate = self
      locationManager.requestWhenInUseAuthorization()
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      mapView.delegate = self
      
      // So that the current location is visible and can
      // be interacted with
      mapView.bringSubviewToFront(searchButton)
      mapView.bringSubviewToFront(numberOfQuestions)
      self.numberOfQuestions.hidden = true
      
      if let recognizers = mapView.gestureRecognizers {
        for recognizer in recognizers {
          mapView.removeGestureRecognizer(recognizer as! UIGestureRecognizer)
        }
      }
      
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if let locDelegate = locationDelegate {
      if let loc = locDelegate.selectedLocation, locName = locDelegate.selectedLocationName, locId = locDelegate.selectedLocationVenueId {
        inSearchMode = true
        
        setLocationInfo(loc.coordinate.latitude, longitude: loc.coordinate.longitude, locName: locName, locVenueId: locId)
        
        fetchQuestionsForLocation(Location(latitude: selectedLocation!.coordinate.latitude,
            longitude: selectedLocation!.coordinate.longitude,
            name: selectedLocationName!,
            externalId: selectedLocationVenueId!))
        
        camera = GMSCameraPosition.cameraWithLatitude(selectedLocation!.coordinate.latitude,
          longitude: selectedLocation!.coordinate.longitude,
          zoom: 17)
        mapView.animateToCameraPosition(camera)
        
        placeVenueMarker(selectedLocation!.coordinate.latitude,
          longitude: selectedLocation!.coordinate.longitude,
          name: selectedLocationName!,
          venueId: selectedLocationVenueId!)
      }
    } else {
      locationManager.startUpdatingLocation()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // TODO: Move fetchQuestions to utility and separate out the view logic
  func fetchQuestionsForLocation(location: Location) {
    questionService.getAllQuestions(location, completion: {
      allQuestions -> () in
      if allQuestions.count > 0 {
        self.allQuestions = allQuestions
        self.qnaDetailsTableView.reloadData()
        self.numberOfQuestions.text = String(self.allQuestions.count) + " ASKIIS"
      } else {
        self.allQuestions.removeAll(keepCapacity: false)
        self.qnaDetailsTableView.reloadData()
      }
    })
  }
    
  func placeVenueMarker(latitude: CLLocationDegrees,
    longitude: CLLocationDegrees,
    name: String,
    venueId: String) {
      
    var position = CLLocationCoordinate2DMake(latitude, longitude)
      
    var marker = GMSMarker(position: position)
    marker.title = name
    marker.appearAnimation = kGMSMarkerAnimationPop
    marker.map = mapView
    marker.icon = UIImage(named: "Venue_Icon")
      
    var userDataMap = [String: String]()
    userDataMap["venueId"] = venueId
    marker.userData = userDataMap
      
    mapView.selectedMarker = marker
      
    selectedVenueMarker = marker
  }
  
  func setLocationInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees, locName: String?, locVenueId: String?) {
    selectedLocation = CLLocation(latitude: latitude, longitude: longitude)
    if let locName = locName {
      selectedLocationName = locName
    } else {
      selectedLocationName?.removeAll(keepCapacity: false)
    }
    
    if let locVenueId = locVenueId {
      selectedLocationVenueId = locVenueId
    } else {
      selectedLocationVenueId?.removeAll(keepCapacity: false)
    }
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if segue.destinationViewController is SearchLocationViewController {
      var searchLocationViewController = segue.destinationViewController as! SearchLocationViewController
      searchLocationViewController.delegate = self
    } else if segue.destinationViewController is NewQuestionViewController {
      var newQuestionViewController = segue.destinationViewController as! NewQuestionViewController
      newQuestionViewController.delegate = self
    }
  }
}

// MARK: CLLocationManagerDelegate
extension LocationViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    
    hasCurrentLocationBeenFetched = true
    var currentLocation = locations.first as? CLLocation
    
    camera = GMSCameraPosition.cameraWithLatitude(currentLocation!.coordinate.latitude,
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
    setLocationInfo(latitude, longitude: longitude, locName: nil, locVenueId: nil)
    
    if selectedMarker != nil {
      selectedMarker!.map = nil
    }
    
    if selectedVenueMarker != nil {
      selectedVenueMarker!.map = nil
    }
    
    var position = CLLocationCoordinate2DMake(latitude, longitude)
    var marker = GMSMarker(position: position)
    marker.snippet = "Ask about here!"
    marker.appearAnimation = kGMSMarkerAnimationPop
    marker.map = mapView
    selectedMarker = marker

    fetchQuestionsForLocation(Location(latitude: latitude, longitude: longitude))
  }
  
  func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
    if inSearchMode {
      inSearchMode = false
      hasCurrentLocationBeenFetched = true
    } else if hasCurrentLocationBeenFetched {
      placeMarker(position.target.latitude, longitude: position.target.longitude)
    }
  }
}


// MARK: UITableViewDelegate

extension LocationViewController: UITableViewDelegate, LocationProtocol {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

  }
}


// MARK: UITableViewDataSource
extension LocationViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let currentQuestion = allQuestions[indexPath.row]
    
    let cell = qnaDetailsTableView.dequeueReusableCellWithIdentifier("qnaDetail") as! QnADetailTableViewCell
    
    cell.parentViewController = self
    cell.configure(currentQuestion)
    
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.allQuestions.count
  }
  
}

