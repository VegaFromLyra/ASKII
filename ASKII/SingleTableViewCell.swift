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
    @IBOutlet weak var AnswerVoteNumLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func answerConfig() {
        AnswerLabel.text = "This is a sample answer."
        AnswerTimeLabel.text = "5 mins ago"
        AnswerVoteNumLabel.text = "6"
    }

}
