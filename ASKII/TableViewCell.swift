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
    //@IBOutlet weak var timeLabel: UILabel!
    //@IBOutlet weak var numOfAnswersLabel: UILabel!
    @IBOutlet weak var numOfAnswersLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBAction func yesPressed(sender: UIButton) {
    }
    @IBAction func noPressed(sender: UIButton) {
    }
    //@IBOutlet weak var voteNumLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config() {
       titleLabel.text = "This is sample question"
        timeLabel.text = "5 mins"
        numOfAnswersLabel.text = "10"
        //voteNumLabel.text = "6"
       
    }
}
