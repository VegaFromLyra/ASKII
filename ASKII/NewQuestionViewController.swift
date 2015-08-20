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
  @IBOutlet weak var buttonViewBottomConstraint: NSLayoutConstraint!
  

  var question: String?
  var delegate: LocationProtocol?
  
  @IBAction func onSubmitQuestionDone(sender: AnyObject) {
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    var controller = storyboard.instantiateViewControllerWithIdentifier("QuestionViewController") as! UIViewController
    
    self.presentViewController(controller, animated: true, completion: nil)
  }
  
  @IBAction func onSubmitQuestion(sender: AnyObject) {
    
    if !questionText.text.isEmpty {
      if let location = delegate?.selectedLocation {
        let locationModel = Location(latitude: location.coordinate.latitude,
          longitude: location.coordinate.longitude)
        
        if let name = delegate?.selectedLocationName {
          locationModel.name = name
        }
        
        if let externalId = delegate?.selectedLocationVenueId {
          locationModel.externalId = externalId
        }
        
        let questionModel = Question(content: questionText.text, location: locationModel)
        questionModel.save()
      } else {
        println("ERROR! Location info is nil")
      }
    } else {
      println("ERROR! Question is nil")
    }
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    questionText.delegate = self
    
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: Selector("keyboardWasShown:"),
      name:UIKeyboardDidShowNotification,
      object: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func keyboardWasShown(notification: NSNotification) {
    var info = notification.userInfo!
    var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

    UIView.animateWithDuration(0.1, animations: { () -> Void in
      self.buttonViewBottomConstraint.constant = keyboardFrame.size.height + 20
    })
  }
    
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  // override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  // }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self);
  }

}

// MARK: UITextViewDelegate

extension NewQuestionViewController: UITextViewDelegate {
  
  // TODO: Figure out how to place question mark at the end
  func textViewDidBeginEditing(textView: UITextView) {
    //questionText.selectedTextRange = questionText.textRangeFromPosition(questionText.beginningOfDocument, toPosition: questionText.beginningOfDocument)
    questionText.text = ""
  }
}
