//
//  QnADetailTableViewCell.swift
//  ASKII
//
//  Created by Asha Balasubramaniam on 8/11/15.
//
//

import UIKit

class QnADetailTableViewCell: UITableViewCell {
  
  @IBOutlet weak var yesVoteCountLabel: UILabel!
  @IBOutlet weak var noVoteCountLabel: UILabel!
  @IBOutlet weak var wrapperLabel: UILabel!
  
  @IBOutlet weak var questionLabel: UILabel!
  
  
  @IBAction func askAgain(sender: AnyObject) {
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
