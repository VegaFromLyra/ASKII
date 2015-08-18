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

class QuestionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var headerView: UIView!
  
  @IBOutlet weak var mapView: GMSMapView!
  
  
  
  var camera: GMSCameraPosition?
  
  let gradientLayer = CAGradientLayer()
  
  @IBAction func onAskAnywherePressed(sender: AnyObject) {
    var storyboard = UIStoryboard(name: "NewQuestion", bundle: nil)
    var controller = storyboard.instantiateViewControllerWithIdentifier("LocationViewController") as! UIViewController
    
    self.presentViewController(controller, animated: true, completion: nil)
  }
  
  @IBAction func unwindToViewController (sender: UIStoryboardSegue){
    
  }
  
  var locationManager: CLLocationManager!
  
  var mapLayer: CALayer {
    return mapView.layer
  }
  
  var headerLayer: CALayer {
    return headerView.layer
  }
  
  let transitionManager = TransitionManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if CLLocationManager.locationServicesEnabled() && mapView != nil {
      locationManager = CLLocationManager()
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.requestAlwaysAuthorization()
      locationManager.startUpdatingLocation()
      mapView.delegate = self
    }
    setUpLayer()
    
    self.tableView.backgroundColor = UIColor.clearColor();
    self.tableView.opaque = false;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Auto row height for each cell
    self.tableView.estimatedRowHeight = 300
    self.tableView.rowHeight = UITableViewAutomaticDimension
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
  
  func layoutSubviews() {
    super.viewDidLayoutSubviews()
    self.tableView.contentInset = UIEdgeInsetsMake(self.mapView.frame.size.height-40, 0, 0, 0);
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if (scrollView.contentOffset.y < self.mapView.frame.size.height * -1 ) {
      scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x, self.mapView.frame.size.height * -1), animated: true)
    }
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 6
  }
  
  func tableView(tableView: UITableView,
    heightForHeaderInSection section: Int) -> CGFloat {
      return 1
  }
  
  func tableView(tableView: UITableView,
    viewForHeaderInSection section: Int) -> UIView? {
      //UIView *headerView = [[UIView alloc] init];
      let headerView = UIView()
      headerView.backgroundColor = UIColor(red: 0xff, green: 0xff, blue: 0xff, alpha: 0.0)
      
      return headerView;
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell: TableViewCell = self.tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! TableViewCell
    
    cell.backgroundColor =  UIColor(red: 0xff, green: 0xff, blue: 0xff, alpha: 0.9)
    
    cell.selectionStyle = .None
    
    cell.config()
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    // this gets a reference to the screen that we're about to transition to
    let toViewController = segue.destinationViewController as! SingleQuestionViewController
    
    // instead of using the default transition animation, we'll ask
    // the segue to use our custom TransitionManager object to manage the transition animation
    toViewController.transitioningDelegate = self.transitionManager
    
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
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    let location = locations.last as! CLLocation
    camera = GMSCameraPosition.cameraWithLatitude(location.coordinate.latitude,
      longitude: location.coordinate.longitude,
      zoom: 17)
    mapView.camera = camera
    mapView.myLocationEnabled = true
    mapView.settings.myLocationButton = true
    locationManager.stopUpdatingLocation()
  }
}

extension QuestionsViewController: GMSMapViewDelegate {
  func placeMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    var position = CLLocationCoordinate2DMake(latitude, longitude)
    var marker = GMSMarker(position: position)
    marker.appearAnimation = kGMSMarkerAnimationPop
    marker.map = mapView
  }
  
  func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
    placeMarker(position.target.latitude, longitude: position.target.longitude)
  }
}
