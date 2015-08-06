//
//  SearchLocationViewController.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 8/6/15.
//
//

import UIKit

class SearchLocationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

// MARK: UITextFieldDelegate

extension SearchLocationViewController: UITextFieldDelegate {
  
  // TODO - Should we use 'UserLocation' here or 'SelectedLocation'?
//  func textFieldShouldReturn(textField: UITextField) -> Bool {
//    print(textField.text)
//    venueService.search(userLocation!,
//      query: textField.text, completion: {
//        searchResults -> Void in
//        println(searchResults)
//        self.mapView.clear()
//        if let results = searchResults {
//          for result in results {
//            let itemName = result["name"]! as! String
//            let itemLocation = result["location"] as! JSONParameters
//            let itemLatitude = itemLocation["lat"] as! CLLocationDegrees
//            let itemLongitude = itemLocation["lng"] as! CLLocationDegrees
//            
//            self.placeVenueMarker(itemLatitude, longitude: itemLongitude, name: itemName)
//          }
//        }
//    })
//    return true
//  }
}
