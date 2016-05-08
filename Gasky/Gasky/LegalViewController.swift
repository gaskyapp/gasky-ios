//
//  LegalViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 3/29/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class LegalViewController: UIViewController, UIGestureRecognizerDelegate {
    
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
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .Down) {
            self.segueBack()
        }
    }
    
    @IBAction func backButtonTap(sender: AnyObject) {
        self.segueBack()
    }
    
    @IBAction func termsButtonTap(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedTerms"])
    }
    
    @IBAction func privacyButtonTap(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedPrivacy"])
    }
    
    @IBAction func licensesButtonTap(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedLicenses"])
    }
    
    func segueBack() {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedAbout"])
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
