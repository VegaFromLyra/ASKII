//
//  NewQuestionViewController.swift
//  ASKII
//
//  Created by Jiashan Wu on 7/17/15.
//
//

import UIKit

class NewQuestionViewController: UIViewController, NewQuestion {
  
  // MARK: Properties
  
  @IBOutlet weak var questionText: UITextView!
  var question: String?
  var delegate: QuestionLocationProtocol?
  
  @IBAction func onSubmitQuestionDone(sender: AnyObject) {
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    var controller = storyboard.instantiateViewControllerWithIdentifier("QuestionViewController") as! UIViewController
    
    self.presentViewController(controller, animated: true, completion: nil)
  }
  
  @IBAction func onSubmitQuestion(sender: AnyObject) {
    
    if !questionText.text.isEmpty {
      if let location = delegate?.location, name = delegate?.name {
        let locationModel = Location(latitude: location.coordinate.latitude,
          longitude: location.coordinate.longitude,
          name: name)
        let questionModel = Question()
        questionModel.save(questionText.text, questionLocation: locationModel)
      } else {
        println("ERROR! Location info is nil")
      }
    } else {
      println("ERROR! Question is nil")
    }
    
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  // override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  // }
  

}
