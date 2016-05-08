//
//  ApplicationContainerViewController.swift
//  Gasky
//
//  The ApplicationContainerViewController serves as the base of operations for Gasky.
//  A global container for displaying the application manages the transitions between
//  Storyboard scenes as well as the fly out application menu.
//
//  Created by Eric Lorentz on 2/4/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class ApplicationContainerViewController: UIViewController {
    var introViewSegue: String = "embedIntro"
    var loginViewSegue: String = "embedLogin"
    var registerViewSegue: String = "embedRegister"
    var accountCreatedViewSegue: String = "embedAccountCreated"
    var forgotPasswordViewSegue: String = "embedForgotPassword"
    var forgotPasswordSuccessViewSegue: String = "embedForgotPasswordSuccess"
    var infoStepOneViewSegue: String = "embedInfoStepOne"
    var infoStepTwoViewSegue: String = "embedInfoStepTwo"
    var infoStepThreeViewSegue: String = "embedInfoStepThree"
    var orderMapViewSegue: String = "embedOrderMap"
    var accountViewSegue: String = "embedAccount"
    var orderThankYouViewSegue: String = "embedOrderThankYou"
    var orderTrackingViewSegue: String = "embedOrderTracker"
    var orderCompletedViewSegue: String = "embedOrderCompleted"
    var promotionViewSegue: String = "embedPromotion"
    var aboutViewSegue: String = "embedAbout"
    var legalViewSegue: String = "embedLegal"
    var termsViewSegue: String = "embedTerms"
    var privacyViewSegue: String = "embedPrivacy"
    var licensesViewSegue: String = "embedLicenses"
    
    var current: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Run initial data retrieval function to fetch user's data in device storage
        GaskyFoundation.sharedInstance.retrieveData()

        // Setup noticiations for triggering scene changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeScene:", name:"segueTo", object: nil)
        
        // Setup notificiations for expired credentials logouts
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logoutAlert:", name:"authInvalid", object: nil)
        
        if (GaskyFoundation.sharedInstance.isLoggedIn() == true) {
            GaskyFoundation.sharedInstance.getOpenOrder()
            GaskyFoundation.sharedInstance.getServiceAreas()
            GaskyFoundation.sharedInstance.getPricing()
            GaskyFoundation.sharedInstance.getCurrentPersonalInfo()
            GaskyFoundation.sharedInstance.getCurrentVehicleInfo()
            GaskyFoundation.sharedInstance.getCurrentPaymentMethodInfo()
            GaskyFoundation.sharedInstance.getCurrentPromoInfo()
        }
        
        if (GaskyFoundation.sharedInstance.isLoggedIn() == true) {
            // Segue to order screen (displays immediately without animations)
            self.performSegueWithIdentifier(orderMapViewSegue, sender: nil)
        } else {
            // Segue to intro screen (displays immediately without animations)
            self.performSegueWithIdentifier(introViewSegue, sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logoutAlert(notification: NSNotification) {
        let alertController = UIAlertController(title: "Signed Out", message:
            "Your current session has ended. Sign in again to continue.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func changeScene(notification: NSNotification) {
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let messageString = userInfo["target"]
        self.swapViewControllers(messageString!)
    }

    // Inter-view segue handler
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == introViewSegue) {
            if (self.childViewControllers.count > 0) {
                self.dismissContainerContentVertically(self.childViewControllers[0], toViewController: segue.destinationViewController)
            } else {
                self.addChildViewController(segue.destinationViewController)
                segue.destinationViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                self.view.addSubview(segue.destinationViewController.view)
                segue.destinationViewController.didMoveToParentViewController(self)
            }
        }
        else if (segue.identifier == self.loginViewSegue && self.current == self.registerViewSegue) {
            self.presentContainerContentHorizontallyRight(self.childViewControllers[0], toViewController: segue.destinationViewController)
        }
        else if (segue.identifier == self.registerViewSegue && self.current == self.loginViewSegue) {
            self.presentContainerContentHorizontallyLeft(self.childViewControllers[0], toViewController: segue.destinationViewController)
        }
        else if (segue.identifier == self.orderTrackingViewSegue) {
            self.dismissContainerContentVertically(self.childViewControllers[0], toViewController: segue.destinationViewController)
        }
        else if (segue.identifier == orderMapViewSegue) {
            if (self.childViewControllers.count > 0) {
                self.dismissContainerContentVertically(self.childViewControllers[0], toViewController: segue.destinationViewController)
            } else {
                self.addChildViewController(segue.destinationViewController)
                segue.destinationViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                self.view.addSubview(segue.destinationViewController.view)
                segue.destinationViewController.didMoveToParentViewController(self)
            }
        }
        else if (segue.identifier == loginViewSegue && (self.current == self.forgotPasswordViewSegue || self.current == self.forgotPasswordSuccessViewSegue)) {
            self.dismissContainerContentVertically(self.childViewControllers[0], toViewController: segue.destinationViewController)
        }
        else if (segue.identifier == aboutViewSegue && self.current == self.legalViewSegue) {
            self.dismissContainerContentVertically(self.childViewControllers[0], toViewController: segue.destinationViewController)
        }
        else if (segue.identifier == legalViewSegue && (self.current == self.termsViewSegue || self.current == self.privacyViewSegue || self.current == self.licensesViewSegue)) {
            self.dismissContainerContentVertically(self.childViewControllers[0], toViewController: segue.destinationViewController)
        }
        /*else if (segue.identifier == self.infoStepTwoViewSegue || segue.identifier == self.infoStepThreeViewSegue) {
            if ((segue.identifier == self.infoStepThreeViewSegue && GaskyFoundation.sharedInstance.getPaymentViewOverride() == 2) || (segue.identifier == self.infoStepTwoViewSegue && GaskyFoundation.sharedInstance.getVehicleViewOverride() == 2) || (segue.identifier == self.infoStepTwoViewSegue && GaskyFoundation.sharedInstance.getVehicleInfoStep() == 1) || (segue.identifier == self.infoStepThreeViewSegue && GaskyFoundation.sharedInstance.getPaymentMethodStep() == 1)) {
                self.presentContainerContentVertically(self.childViewControllers[0], toViewController: segue.destinationViewController)
            } else {
                self.presentContainerContentHorizontally(self.childViewControllers[0], toViewController: segue.destinationViewController)
            }
        }*/
        else {
            self.presentContainerContentVertically(self.childViewControllers[0], toViewController: segue.destinationViewController)
        }
        
        self.current = segue.identifier!
    }
    
    // Animate incoming view from bottom to top (Default segue push style)
    func presentContainerContentVertically(fromViewController: UIViewController, toViewController: UIViewController) {
        toViewController.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)
        fromViewController.willMoveToParentViewController(nil)
        
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.25, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                fromViewController.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)
                toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            }) { (finished) -> Void in
                fromViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
        }
    }
    
    // Animate current view from top to bottom (Default segue unwind style)
    func dismissContainerContentVertically(fromViewController: UIViewController, toViewController: UIViewController) {
        toViewController.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)
        fromViewController.view.layer.zPosition = 1
        toViewController.view.layer.zPosition = 0
        fromViewController.willMoveToParentViewController(nil)
        
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.25, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            fromViewController.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)
            toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            }) { (finished) -> Void in
                fromViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
        }
    }
    
    // Animate incoming view from right to left (Inter-section segue push)
    func presentContainerContentHorizontally(fromViewController: UIViewController, toViewController: UIViewController) {
        toViewController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)
        fromViewController.willMoveToParentViewController(nil)
        
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.25, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            }) { (finished) -> Void in
                fromViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
        }
    }
    
    // Animate incoming view from left to right
    func presentContainerContentHorizontallyRight(fromViewController: UIViewController, toViewController: UIViewController) {
        toViewController.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)
        fromViewController.willMoveToParentViewController(nil)
        
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            fromViewController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)
            toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            }) { (finished) -> Void in
                fromViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
        }
    }
    
    // Animate incoming view from right to left
    func presentContainerContentHorizontallyLeft(fromViewController: UIViewController, toViewController: UIViewController) {
        toViewController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)
        fromViewController.willMoveToParentViewController(nil)
        
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            fromViewController.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)
            toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            }) { (finished) -> Void in
                fromViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
        }
    }
    
    func swapViewControllers(toSegue: String) {
        self.performSegueWithIdentifier(toSegue, sender: nil)
    }
}
