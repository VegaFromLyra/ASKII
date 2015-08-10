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
    
//    @IBAction func onNewQuestionPressed(sender: AnyObject) {
//        var storyboard = UIStoryboard(name: "NewQuestion", bundle: nil)
//        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
//        
//        self.presentViewController(controller, animated: true, completion: nil)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.AnswersTableView.estimatedRowHeight = 100
        self.AnswersTableView.rowHeight = UITableViewAutomaticDimension

        // Do any additional setup after loading the view.
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
