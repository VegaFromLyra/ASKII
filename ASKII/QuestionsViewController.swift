//
//  QuestionsViewController.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 7/6/15.
//
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps

extension UIColor {
  convenience init(red: Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")
    
    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
  }
  
  convenience init(netHex:Int) {
    self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
  }
}

class QuestionsViewController: UIViewController, LocationProtocol {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var currentLocationName: UILabel!
  
  var selectedLocation: CLLocation?
  var selectedLocationName: String?
  var selectedLocationVenueId: String?
  
  let questionService:QuestionService = QuestionService()
  var selectedQuestion: Question?
  let gradientLayer = CAGradientLayer()
  var camera: GMSCameraPosition?
  var currentLocation: CLLocation?
  var allQuestions: [Question] = []
  var singleQuestionViewController: SingleQuestionViewController!
  var locationManager: CLLocationManager!
  let transitionManager = TransitionManager()
  
  var newQuestionStoryBoard: UIStoryboard!
  var locationVC: LocationViewController!
  var currentLocationMarker: GMSMarker?
  
  func goToLocationView(enableQuestions: Bool) {
    locationVC.inExploreMode = !enableQuestions
    self.presentViewController(locationVC, animated: true, completion: nil)
  }
  
  @IBAction func onAskAnywherePressed(sender: AnyObject) {
    goToLocationView(true)
  }
  
  @IBAction func onExploreButtonClicked(sender: AnyObject) {
    goToLocationView(false)
  }
  
  // NOTE - This is connected to the SingleQuestion exit handle
  @IBAction func unWindFromSingleQuestionScene(unwindSegue: UIStoryboardSegue) {
    print("Unwinded from Single question scene")
  }
  
  var mapLayer: CALayer {
    return mapView.layer
  }
  
  var headerLayer: CALayer {
    return headerView.layer
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    singleQuestionViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SingleQuestionViewController") as! SingleQuestionViewController
    singleQuestionViewController.locDelegate = self
    
    newQuestionStoryBoard = UIStoryboard(name: "NewQuestion", bundle: nil)
    locationVC = newQuestionStoryBoard.instantiateViewControllerWithIdentifier("LocationViewController") as! LocationViewController
    
    if CLLocationManager.locationServicesEnabled() && mapView != nil {
      //TODO - This loc init code should be in a util method and re-used in LocationViewController
      locationManager = CLLocationManager()
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.distanceFilter = 10 // meters
      locationManager.requestAlwaysAuthorization()
      locationManager.startUpdatingLocation()
      mapView.delegate = self
      mapView.myLocationEnabled = true
      mapView.settings.myLocationButton = true
    }
    setUpLayer()
    
    tableView.backgroundColor = UIColor.clearColor();
    tableView.opaque = false;
    tableView.dataSource = self;
    tableView.delegate = self
    
    // TODO: Figure out why this is needed
    // Auto row height for each cell
    self.tableView.estimatedRowHeight = 300
    self.tableView.rowHeight = UITableViewAutomaticDimension
    
  }
  
  override func viewWillDisappear(animated: Bool) {
    locationManager.stopUpdatingLocation()
  }

  // gradient over map
  func setUpLayer() {
    self.mapLayer.backgroundColor = UIColor.blueColor().CGColor
    
    gradientLayer.frame = self.mapLayer.bounds
    let color1 = UIColor(red: 0x19, green: 0xdb, blue: 0xba, alpha: 0.6).CGColor as CGColorRef
    let color2 = UIColor(red: 0x19, green: 0xdb, blue: 0xba, alpha: 0.0).CGColor as CGColorRef
    gradientLayer.colors = [color1, color2]
    gradientLayer.locations = [0.0, 1.0]
    mapView.layer.addSublayer(gradientLayer)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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

// MARK - CLLocationManagerDelegate methods
extension QuestionsViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations.last
    selectedLocation = currentLocation
    
    UtilityService.sharedInstance.getLocationName(currentLocation!) {
      (name: String) -> () in
      self.currentLocationName!.text = name
      self.selectedLocationName = name
    }
    
    if let currentLocation = currentLocation {
      camera = GMSCameraPosition.cameraWithLatitude(currentLocation.coordinate.latitude,
        longitude: currentLocation.coordinate.longitude,
        zoom: 17)
      mapView.camera = camera
      
      let userLocation = UserLocation(location: currentLocation)
      userLocation.save({ (success) -> () in
        if success {
          print("User location saved successfully")
        } else {
          print("Error saving user location")
        }
      })
      
      let locationModel = Location(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
      questionService.getAllQuestions(locationModel, completion: {
        (allQuestions) -> () in
        self.allQuestions = allQuestions
        self.tableView.reloadData()
      })
    }
  }
}

extension QuestionsViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    selectedQuestion = allQuestions[indexPath.row]
    singleQuestionViewController.transitioningDelegate = self.transitionManager
    singleQuestionViewController.question = selectedQuestion!
    self.showViewController(singleQuestionViewController as UIViewController,
      sender: singleQuestionViewController)
  }
}

extension QuestionsViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allQuestions.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let currentQuestion = allQuestions[indexPath.row]
    
    let cell: TableViewCell = self.tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! TableViewCell
    
    cell.backgroundColor =  UIColor(red: 0xff, green: 0xff, blue: 0xff, alpha: 0.9)
    
    cell.selectionStyle = .None
    
    cell.config(currentQuestion)
    
    return cell
  }
}

extension QuestionsViewController: GMSMapViewDelegate {
  func placeMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    let position = CLLocationCoordinate2DMake(latitude, longitude)
    
    if let currentLocationMarker = currentLocationMarker {
      currentLocationMarker.map = nil
    }
    
    currentLocationMarker = GMSMarker(position: position)
    currentLocationMarker!.appearAnimation = kGMSMarkerAnimationPop
    currentLocationMarker!.map = mapView
  }
  
  func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
    placeMarker(position.target.latitude, longitude: position.target.longitude)
  }
}
