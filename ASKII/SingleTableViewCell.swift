//
//  SingleTableViewCell.swift
//  ASKII
//
//  Created by Jiashan Wu on 7/18/15.
//
//

import UIKit

class SingleTableViewCell: UITableViewCell {

    @IBOutlet weak var AnswerLabel: UILabel!
    @IBOutlet weak var AnswerTimeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func answerConfig(comment: Comment) {
        AnswerLabel.text = comment.content
        AnswerTimeLabel.text = UtilityService.sharedInstance.getTimeElapsed(comment.lastUpdatedTime)
    }

}
