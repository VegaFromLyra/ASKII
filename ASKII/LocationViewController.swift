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

class LocationViewController: UIViewController, QuestionLocationProtocol {
  
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
  var location: CLLocation?
  var name: String?
  var venueId: String?
  var camera: GMSCameraPosition?
  
  var locationManager: CLLocationManager!
  var delegate: NewQuestion?
  var locationDelegate: QuestionLocationProtocol?
  var inSearchMode: Bool = false
  let questionModel:Question = Question()
  var allQuestions:[Question] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    qnaDetailsTableView.delegate = self
    qnaDetailsTableView.dataSource = self
    
    
    // Initialize all the location stuff
    if (mapView != nil) {
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
      if let loc = locDelegate.location, locName = locDelegate.name, locId = locDelegate.venueId {
        inSearchMode = true
        location = loc
        name = locName
        venueId = locId
        
        fetchQuestionsForLocation(Location(latitude: location!.coordinate.latitude,
            longitude: location!.coordinate.longitude,
            name: name!,
            externalId: venueId!))
        
        camera = GMSCameraPosition.cameraWithLatitude(location!.coordinate.latitude,
          longitude: location!.coordinate.longitude,
          zoom: 17)
        mapView.animateToCameraPosition(camera)
        
        placeVenueMarker(location!.coordinate.latitude,
          longitude: location!.coordinate.longitude,
          name: name!,
          venueId: venueId!)
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
    questionModel.getAllQuestions(location, completion: {
      allQuestions -> () in
        self.allQuestions = allQuestions
        self.qnaDetailsTableView.reloadData()
        if (self.allQuestions.count > 0) {
          self.numberOfQuestions.hidden = false
          self.numberOfQuestions.text = String(self.allQuestions.count) + " ASKIIS"
        } else {
          self.numberOfQuestions.hidden = true
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
    
    location = locations.first as? CLLocation
    name = ""
    
    camera = GMSCameraPosition.cameraWithLatitude(location!.coordinate.latitude,
      longitude: location!.coordinate.longitude,
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
    location = CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)
    name = marker.title
    var userDataMap = marker.userData as! [String:String]
    venueId = userDataMap["venueId"]
    
    fetchQuestionsForLocation(Location(latitude: location!.coordinate.latitude,
      longitude: location!.coordinate.longitude,
      name: name!,
      externalId: userDataMap["venueId"]!))
    
    placeMarker(marker.position.latitude, longitude: marker.position.longitude)
    return false
  }
  
  func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
    
    if !inSearchMode {
      NSLog("You are at at %f,%f", position.target.latitude, position.target.longitude)
      
      var selectedLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
      
      venueService.loadVenues(selectedLocation, completion: {
        venues -> Void in
        if let venueInfoList = venues {
          for venueInfo in venueInfoList {
            let venueItem = venueInfo["venue"] as! JSONParameters
            
            let currentVenueId = venueItem["id"] as? String
            let venueName = venueItem["name"]! as! String
            let venueLocation = venueItem["location"] as! JSONParameters
            let venueLatitude = venueLocation["lat"] as! CLLocationDegrees
            let venueLongitude = venueLocation["lng"] as! CLLocationDegrees
            
            self.placeVenueMarker(venueLatitude,
              longitude: venueLongitude,
              name: venueName,
              venueId:currentVenueId!)
          }
        }
      })
    }
  }
}


// MARK: UITableViewDelegate

extension LocationViewController: UITableViewDelegate, QuestionLocationProtocol {
  
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

