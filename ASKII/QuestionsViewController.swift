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
    let gradientLayer = CAGradientLayer()
    
    @IBAction func onAskAnywherePressed(sender: AnyObject) {
        var storyboard = UIStoryboard(name: "NewQuestion", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    
    var mapLayer: CALayer {
        return mapView.layer
    }
    
    var headerLayer: CALayer {
        return headerView.layer
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (CLLocationManager.locationServicesEnabled())
        {
          locationManager = CLLocationManager()
          locationManager.delegate = self
          locationManager.desiredAccuracy = kCLLocationAccuracyBest
          locationManager.requestAlwaysAuthorization()
          locationManager.startUpdatingLocation()
        }
        setUpLayer()
//        self.tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "QuestionCell")
        
        // Auto row height for each cell
        self.tableView.estimatedRowHeight = 300
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setUpLayer() {
        mapLayer.backgroundColor = UIColor.blueColor().CGColor
        //mapLayer.borderWidth = 10.0
        //mapLayer.borderColor = UIColor.redColor().CGColor
        
        //headerLayer.borderWidth = 10.0
        //headerLayer.borderColor = UIColor.redColor().CGColor
        gradientLayer.frame = mapLayer.bounds
        // 3
        let color1 = UIColor(netHex:0x19dbba).CGColor as CGColorRef
        let color2 = UIColor(red: 0x19, green: 0xdb, blue: 0xba, alpha: 0.0).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2]
        
        // 4
        gradientLayer.locations = [0.0, 0.7]
        
        // 5
        mapView.layer.addSublayer(gradientLayer)
        
    }
    
//    let gradientLayer = CAGradientLayer()
//    gradientLayer.frame = headerLayer.bounds
//    gradientLayer.colors = [cgColorForRed(209.0, green: 0.0, blue: 0.0),
//    cgColorForRed(255.0, green: 102.0, blue: 34.0),
//    cgColorForRed(255.0, green: 218.0, blue: 33.0),
//    cgColorForRed(51.0, green: 221.0, blue: 0.0),
//    cgColorForRed(17.0, green: 51.0, blue: 204.0),
//    cgColorForRed(34.0, green: 0.0, blue: 102.0),
//    cgColorForRed(51.0, green: 0.0, blue: 68.0)]
//    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//    gradientLayer.endPoint = CGPoint(x: 0, y: 1)
//    mapView.layer.addSublayer(gradientLayer)
//    
//    func cgColorForRed(red: CGFloat, green: CGFloat, blue: CGFloat) -> AnyObject {
//        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0).CGColor as AnyObject
//    }

    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TableViewCell = self.tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! TableViewCell
        
        cell.config()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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
    let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    self.mapView.setRegion(region, animated: true)
  }
}
