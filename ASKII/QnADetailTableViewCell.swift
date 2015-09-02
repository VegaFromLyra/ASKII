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
  
  let utilityService = UtilityService.sharedInstance
  
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
        self.utilityService.showAlert("Great!",
          message: "All set!",
          action: goHomeAction,
          controller: self.parentViewController!)
      } else {
        self.utilityService.showAlert("Oh no!",
          message: "Oops something went wrong",
          action: errorAction,
          controller: self.parentViewController!)
      }
    })
  }
  
  func configure(data: Question) {
    question = data
    
    questionLabel.text = data.content
    
    let yesVoteCount: Int = data.yesVotes
    yesVoteCountLabel.text = yesVoteCount.description
    
    let noVoteCount: Int = data.noVotes
    noVoteCountLabel.text = noVoteCount.description
    
    questionSubmittedTime.text = UtilityService.sharedInstance.getTimeElapsed(data.lastUpdatedTime!)
    
    popularAnswer.text = UtilityService.sharedInstance.getPopularVote(yesVoteCount, noVoteCount: noVoteCount)
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
