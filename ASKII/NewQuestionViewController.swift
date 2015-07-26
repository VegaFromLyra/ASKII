//
//  NewQuestionViewController.swift
//  ASKII
//
//  Created by Jiashan Wu on 7/17/15.
//
//

import UIKit

class NewQuestionViewController: UIViewController, NewQuestion {
  
    // MARK: Properties
  
    @IBOutlet weak var questionText: UITextView!
    var question: String?

    @IBAction func onAskButtonPressed(sender: UIButton) {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("QuestionViewController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
      
        question = questionText.text
        var locationViewController =  segue.destinationViewController as! LocationViewController
        locationViewController.delegate = self
    }
    

}
