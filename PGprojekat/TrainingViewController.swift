//
//  TrainingViewController.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 12/29/15.
//  Copyright © 2015 Uros Zivaljevic. All rights reserved.
//

import UIKit

class TrainingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func recordButtonPressed(sender: UIButton) {
        
        
    }
    
    @IBAction func trainButtonPressed(sender: UIButton) {
        
        let alert = UIAlertController(title: "Upisite rec koju trenirate", message: "", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            print(textField.text)
        }
        
        alert.addAction(UIAlertAction(title: "Start", style: .Default, handler: {(alertAction) in
                print("OK")
            }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (alertAction) -> Void in
            return
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
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
