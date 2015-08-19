//
//  SingleQuestionViewController.swift
//  ASKII
//
//  Created by Jiashan Wu on 7/18/15.
//
//

import UIKit

class SingleQuestionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var AnswersTableView: UITableView!
  @IBOutlet weak var currentLocationName: UILabel!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var questionSubmittedTimeLabel: UILabel!
  @IBOutlet weak var commentTextField: UITextField!
  @IBOutlet weak var popularVoteLabel: UILabel!
  
  let utilityService = UtilityService.sharedInstance
  
  @IBAction func onPostCommentClicked(sender: AnyObject) {
    if commentTextField.text.isEmpty {
      // TODO: Show alert
      println("Missing comment")
    } else {
      question!.postComment(commentTextField.text, completion: {
        (success) -> () in
        if success {
          println("Comment posted successfully")
        } else {
          println("Error in posting comment")
        }
      })
    }
  }
  
  @IBAction func onYesButtonClicked(sender: AnyObject) {
    question!.addYesVote {
      (success) -> () in
      if success {
        println("Added yes vote")
      } else {
        println("Error adding yes vote")
      }
    }
  }
  
  @IBAction func onNoButtonClicked(sender: AnyObject) {
    question!.addNoVote {
      (success) -> () in
      if success {
        println("Added no vote")
      } else {
        println("Error adding no vote")
      }
    }
  }
  
  var locDelegate: LocationProtocol?
  var question: Question?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // TODO: Figure out why this is needed
    self.AnswersTableView.estimatedRowHeight = 100
    self.AnswersTableView.rowHeight = UITableViewAutomaticDimension
    
    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear(animated: Bool) {
    if let locDelegate = locDelegate {
      if let locName = locDelegate.selectedLocationName {
        currentLocationName.text = locName
      }
    }
    
    if let question = question {
      questionLabel.text = question.content
      questionSubmittedTimeLabel.text = utilityService.getTimeElapsed(question.lastUpdatedTime!)
      popularVoteLabel.text = utilityService.getPopularVote(question.yesVotes!, noVoteCount: question.noVotes!)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 6
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell: SingleTableViewCell = self.AnswersTableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SingleTableViewCell
    
    cell.answerConfig()
    
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
