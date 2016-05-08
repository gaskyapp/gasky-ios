//
//  AccountCreatedViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 2/12/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class AccountCreatedViewController: UIViewController {
    
    // Button connections
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set status bar color to default
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        // Format button
        self.continueButton.titleLabel!.lineBreakMode = .ByWordWrapping
        self.continueButton.titleLabel!.textAlignment = .Center

        // Set up attributed strings, bug in IB doesn't allow for definition there
        let skipAttributes = [
            NSForegroundColorAttributeName: GaskyFoundation.neutralColor,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ]
        let underlineSkip = NSAttributedString(string: self.skipButton.currentTitle!, attributes: skipAttributes)
        self.skipButton.setAttributedTitle(underlineSkip, forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func moreButtonTap(sender: AnyObject) {
        // Go to Step 1/3 - About You
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedInfoStepOne"])
    }
    
    @IBAction func skipTap(sender: AnyObject) {
        // Go to main map screen
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
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
