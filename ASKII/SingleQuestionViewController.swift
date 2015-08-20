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
  @IBOutlet weak var commentCountLabel: UILabel!
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var headerView: UIView!
  
  var locDelegate: LocationProtocol?
  var question: Question?
  let utilityService = UtilityService.sharedInstance
  var comments: [Comment] = []
  
  @IBAction func onPostCommentClicked(sender: AnyObject) {
    if commentTextField.text.isEmpty {
      // TODO: Show alert
      println("Missing comment")
    } else {
      question!.postComment(commentTextField.text, completion: {
        (success) -> () in
        if success {
          println("Comment posted successfully")
          self.updateComments()
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
        self.refreshQuestionData()
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
        self.refreshQuestionData()
      } else {
        println("Error adding no vote")
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // TODO: Figure out why this is needed
    AnswersTableView.estimatedRowHeight = 100
    AnswersTableView.rowHeight = UITableViewAutomaticDimension
    commentTextField.delegate = self
    
    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear(animated: Bool) {
    if let locDelegate = locDelegate {
      if let locName = locDelegate.selectedLocationName {
        currentLocationName.text = locName
      }
    }
    
    questionLabel.text = question!.content
    questionSubmittedTimeLabel.text = utilityService.getTimeElapsed(question!.lastUpdatedTime!)
    
    popularVoteLabel.text = utilityService.getPopularVote(question!.yesVotes!, noVoteCount: question!.noVotes!)
    
    updateBackgroundColor()
    
    updateComments()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var selectedComment = comments[indexPath.row]
    
    let cell: SingleTableViewCell = self.AnswersTableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SingleTableViewCell
    cell.answerConfig(selectedComment)
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
  }
  
  func updateBackgroundColor() {
    var backgroundColor = utilityService.getPopularVoteColor(question!.yesVotes!, noVoteCount: question!.noVotes!)
    backgroundView.backgroundColor = backgroundColor
    headerView.backgroundColor = backgroundColor
  }
  
  func refreshQuestionData() {
    question?.refresh({
      (success) -> () in
      if success {
        self.updateBackgroundColor()
      }
    })
  }
  
  func updateComments() {
    question!.getComments({
      (comments) -> () in
      self.comments = comments
      self.commentCountLabel.text = String(comments.count)
      self.AnswersTableView.reloadData()
    })
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

extension SingleQuestionViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(textField: UITextField) {
    commentTextField.text = ""
  }
}
