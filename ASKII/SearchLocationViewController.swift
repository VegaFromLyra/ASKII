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
    var delegate: LocationProtocol?
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchResultsTableView: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // TODO: Do I need this?
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.scrollEnabled = true
        searchResultsTableView.hidden = true
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

extension SearchLocationViewController: UITableViewDelegate {
  
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
}
// MARK: UITableViewDataSource

extension SearchLocationViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = searchResultsTableView.dequeueReusableCellWithIdentifier("SearchResult") as! UITableViewCell
    
    // cell.textLabel!.text = venues[indexPath.row].name
    // detailTextLabel!.text = venues[indexPath.row].Location
    
    
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0;
  }
  
}

// MARK: UITextFieldDelegate

extension SearchLocationViewController: UITextFieldDelegate {
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    if let location = delegate?.currentLocation {

      venueService.search(location,
        query: searchTextField.text, completion: {
          searchResults -> Void in
          println(searchResults)

      })
 
    }
    
    return true
  }
}
