//
//  SearchLocationViewController.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 8/6/15.
//
//

import UIKit
import CoreLocation

class SearchLocationViewController: UIViewController {
  
  let venueService = VenueService()
  var delegate: QuestionLocationProtocol?
  @IBOutlet weak var searchTextField: UITextField!
  @IBOutlet weak var searchResultsTableView: UITableView!
  var locations: [(name: String, area: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, venueId: String)] = []
  
  var location: CLLocation?
  var name: String?
  var venueId: String?
  var locationVC: LocationViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // TODO: Do I need this?
    searchResultsTableView.delegate = self
    searchResultsTableView.dataSource = self
    searchResultsTableView.scrollEnabled = true
    searchResultsTableView.hidden = true
    searchTextField.delegate = self
    locationVC = self.storyboard!.instantiateViewControllerWithIdentifier("LocationViewController") as! LocationViewController
    locationVC.locationDelegate = self
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

// MARK: UITableViewDelegate

extension SearchLocationViewController: UITableViewDelegate, QuestionLocationProtocol {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    var selectedLocation = locations[indexPath.row]
    location = CLLocation(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude)
    name = selectedLocation.name
    self.showViewController(locationVC as UIViewController, sender: locationVC)
  }
}


// MARK: UITableViewDataSource
extension SearchLocationViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = searchResultsTableView.dequeueReusableCellWithIdentifier("SearchResult") as! UITableViewCell
    
    cell.textLabel!.text = locations[indexPath.row].name
    cell.detailTextLabel!.text = locations[indexPath.row].area
    // TODO: Change the image
    
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.locations.count;
  }
  
}

// MARK: UITextFieldDelegate

extension SearchLocationViewController: UITextFieldDelegate {
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if locations.count > 0 {
      locations.removeAll(keepCapacity: false)
      searchResultsTableView.reloadData()
    }
    
    if let location = delegate?.location {
      
      var txtAfterUpdate:NSString = self.searchTextField.text as NSString
      txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
      
      var searchQuery = txtAfterUpdate as! String
      
      if !(searchQuery.isEmpty) {
        
        println(searchQuery)
        venueService.search(location, query: searchQuery, completion: {
          searchResults -> Void in
          self.locations = searchResults
          self.searchResultsTableView.hidden = false
          self.searchResultsTableView.reloadData()
        })
      }
    }
    
    return true
  }
}
