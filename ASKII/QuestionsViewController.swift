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

class QuestionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onAskAnywherePressed(sender: AnyObject) {
        var storyboard = UIStoryboard(name: "NewQuestion", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!

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
        
//        self.tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "QuestionCell")
        
        // Auto row height for each cell
        self.tableView.estimatedRowHeight = 300
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

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
