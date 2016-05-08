//
//  OrderReceivedViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 3/6/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class OrderReceivedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set status bar color to default
        UIApplication.sharedApplication().statusBarStyle = .Default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func okButtonTap(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderTracker"])
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
