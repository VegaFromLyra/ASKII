//
//  TableViewCell.swift
//  ASKII
//
//  Created by Jiashan Wu on 7/18/15.
//
//

import UIKit

class TableViewCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var numOfAnswersLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var popularAnswer: UILabel!
  
  @IBOutlet weak var yesVoteButton: UIButton!
  @IBOutlet weak var noVoteButton: UIButton!
  
  
  
  var yesVoteCount:Int  = 0
  var noVoteCount:Int = 0
  var question: Question?
  
  
  @IBAction func yesPressed(sender: UIButton) {
    question?.addYesVote({
      (success) -> () in
      if success {
        println("Vote added successfully")
        self.yesVoteCount++
        self.updateVoteCount()
      } else {
        println("Error in adding vote")
      }
    })
  }
  
  @IBAction func noPressed(sender: UIButton) {
    question?.addNoVote({
      (success) -> () in
      if success {
        println("Vote added successfully")
        self.noVoteCount++
        self.updateVoteCount()
      } else {
        println("Error in adding vote")
      }
    })
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func updateVoteCount() {
    yesVoteButton.setTitle(String(yesVoteCount), forState: UIControlState.Normal)
    noVoteButton.setTitle(String(noVoteCount), forState: UIControlState.Normal)
  }
  
  func config(data: Question) {
    question = data
    
    if let yesVotes = question?.yesVotes, noVotes = question?.noVotes {
      yesVoteCount = yesVotes
      noVoteCount = noVotes
    }

    updateVoteCount()

    titleLabel.text = question?.content
    timeLabel.text = "5 mins"
    numOfAnswersLabel.text = "10"
  }
}
