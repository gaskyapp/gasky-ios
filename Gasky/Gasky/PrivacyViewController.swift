//
//  PrivacyViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 3/29/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController, UIGestureRecognizerDelegate, UITextViewDelegate {
    
    var lineVisible: Bool = false
    var downSwipeGesture: UISwipeGestureRecognizer!
    @IBOutlet weak var whiteLine: UIView!
    @IBOutlet weak var textContainer: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set status bar color to light
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        self.whiteLine.alpha = 0
        self.textContainer.scrollEnabled = false
        self.textContainer.delegate = self

        self.downSwipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        self.downSwipeGesture.direction = .Down
        view.addGestureRecognizer(self.downSwipeGesture)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.textContainer.scrollEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTap(sender: AnyObject) {
        self.segueBack()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y > 25 && self.lineVisible == false) {
            self.lineVisible = true
            self.fadeLineIn()
        }
        
        if (scrollView.contentOffset.y <= 25 && self.lineVisible == true) {
            self.lineVisible = false
            self.fadeLineOut()
        }
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .Down) {
            self.segueBack()
        }
    }
    
    func fadeLineOut() {
        UIView.animateWithDuration(0.3, animations: {
            self.whiteLine.alpha = 0
        })
    }
    
    func fadeLineIn() {
        UIView.animateWithDuration(0.3, animations: {
            self.whiteLine.alpha = 1
        })
    }
    
    func segueBack() {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedLegal"])
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
