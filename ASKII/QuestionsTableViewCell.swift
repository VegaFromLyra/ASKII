//
//  QuestionsTableViewCell.swift
//  ASKII
//
//  Created by Jiashan Wu on 7/17/15.
//
//

import UIKit

// Create class for delegate to send IBAction to PoffeesTableViewController
//protocol QuestionsTableViewCellDelegate : class {
//    func QuestionsTableViewCellDidTouchArrow(cell: PoffeeTableViewCell, sender: AnyObject)
//}

class QuestionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var numOfAnswersLabel: UILabel!
    @IBOutlet weak var voteNumberLabel: UILabel!
    
    @IBAction func onUpvoteButtonPressed(sender: UIButton) {
        // up++
    }
    @IBAction func onDownvoteButtonPressed(sender: UIButton) {
        //down++
    }
    
    //weak var delegate: UITableViewDelegate? // New delegate
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        self.questionLabel.text = "This is a sample question"
        self.timeLabel.text = "5 mins ago"
        self.numOfAnswersLabel.text = "1 answer"
        self.voteNumberLabel.text = "6"
    }

}
