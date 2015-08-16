//
//  QnADetailTableViewCell.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 8/11/15.
//
//

import UIKit

class QnADetailTableViewCell: UITableViewCell {
  
  var question: Question?
  
  // TODO: Is this better to do via init?
  var parentViewController: UIViewController?
  
  @IBOutlet weak var yesVoteCountLabel: UILabel!
  @IBOutlet weak var noVoteCountLabel: UILabel!
  @IBOutlet weak var wrapperLabel: UILabel!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var questionSubmittedTime: UILabel!
  @IBOutlet weak var popularAnswer: UILabel!
  
  @IBAction func askAgain(sender: AnyObject) {
    question?.clearVoteCount({
      (success) -> () in
      
      let goHomeAction: UIAlertAction = UIAlertAction(title: "Next", style:  UIAlertActionStyle.Default) { action -> Void in
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("QuestionViewController") as! UIViewController
        self.parentViewController?.presentViewController(controller, animated: true, completion: nil)
      }
      
      let errorAction: UIAlertAction = UIAlertAction(title: "Oops!", style: UIAlertActionStyle.Cancel) { action -> Void in
      }
      
      if success {
        self.showAlert("Great!", message: "All set!", action: goHomeAction)
      } else {
        self.showAlert("Oh no!", message: "Oops something went wrong", action: errorAction)
      }
    })
  }

  func showAlert(title: String, message: String, action: UIAlertAction) {
    var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(action)
    parentViewController?.presentViewController(alert, animated: true, completion: nil)
  }
  
  // TODO - Move to utility service
  func getTimeElapsed(submittedTime: NSDate) -> String {
    let elapsedTimeInterval = NSDate().timeIntervalSinceDate(submittedTime)
    let durationInSeconds = Int(elapsedTimeInterval)
    var output = ""
    if durationInSeconds <= 60 {
      output = String(durationInSeconds) + " s:"
    } else if durationInSeconds <= 3600 {
      output = String(durationInSeconds / 60) + " m:"
    } else if durationInSeconds <= 86400 {
      output = String(durationInSeconds / 3600) + " h:"
    } else if durationInSeconds <= 604800 {
      output = String(durationInSeconds / 86400) + " d:"
    } else {
      output = String(durationInSeconds / 604800) + " w:"
    }
    
    return output
  }
  
  func getPopulateVote(yesVoteCount: Int, noVoteCount: Int) -> String {
    var output = ""
    if yesVoteCount > noVoteCount {
      output = "yes"
    } else if noVoteCount > yesVoteCount {
      output = "no"
    }
    
    return output
  }
  
  func configure(data: Question) {
    question = data
    
    questionLabel.text = data.content
    
    let yesVoteCount: Int = data.yesVotes!
    yesVoteCountLabel.text = yesVoteCount.description
    
    let noVoteCount: Int = data.noVotes!
    noVoteCountLabel.text = noVoteCount.description
    
    questionSubmittedTime.text = getTimeElapsed(data.lastUpdatedTime!)
    
    popularAnswer.text = getPopulateVote(yesVoteCount, noVoteCount: noVoteCount)
  }
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    wrapperLabel.layer.borderWidth = 1
    wrapperLabel.layer.borderColor = UIColor.grayColor().CGColor
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }

}
