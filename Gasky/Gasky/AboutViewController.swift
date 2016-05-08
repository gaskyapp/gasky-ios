//
//  AboutViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 3/29/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var downSwipeGesture: UISwipeGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set status bar color to light
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        self.downSwipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        self.downSwipeGesture.direction = .Down
        view.addGestureRecognizer(self.downSwipeGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTap(sender: AnyObject) {
        self.segueBack()
    }
    
    @IBAction func rateButtonTap(sender: AnyObject) {
        if let requestUrl = NSURL(string: "http://www.apple.com/itunes/") {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }
    
    @IBAction func likeButtonTap(sender: AnyObject) {
        if let requestUrl = NSURL(string: "https://www.facebook.com/gaskyapp") {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }
    
    @IBAction func legalButtonTap(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedLegal"])
    }
    
    @IBAction func visitButtonTap(sender: AnyObject) {
        if let requestUrl = NSURL(string: "http://www.gasky.co") {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .Down) {
            self.segueBack()
        }
    }
    
    func segueBack() {
        let orderStatus = GaskyFoundation.sharedInstance.returnOrderStatus()
        
        if (orderStatus["id"]! != nil) {
            NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderTracker"])
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
        }
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
