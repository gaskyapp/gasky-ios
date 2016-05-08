//
//  PromotionViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 3/29/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class PromotionViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var promotionDescription: UILabel!
    @IBOutlet weak var promotionField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var actionButtonOffset: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // 0 = apply promotion, 1 = clear promotion
    var action: Int = 0
    
    var downSwipeGesture: UISwipeGestureRecognizer!
    var promoData: [String:AnyObject?] = [String:AnyObject?]()
    var promotionFieldPlaceholder: String = ""
    var promotionFieldValid: Bool = false
    var submittingInfo: Bool = false
    
    var defaultOffset: CGFloat = 24
    var expandedOffset: CGFloat = 65

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set status bar color to light
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Setup text fields and note placeholders
        self.promotionFieldPlaceholder = self.promotionField.text!
        self.promoData = GaskyFoundation.sharedInstance.getPromoInfo()
        if (self.promoData["code"]! != nil) {
            self.promotionField.text = self.promoData["code"] as? String
            self.promotionField.userInteractionEnabled = false
            GaskyFoundation.setFieldColor(self.promotionField, state: "normal")
            self.action = 1
            self.switchToClearButton()
            self.actionButtonOffset.constant = self.expandedOffset
            self.view.layoutIfNeeded()
        } else {
            self.promotionDescription.hidden = true
            self.promotionDescription.alpha = 0
            disableActionButton()
        }
        
        self.setPromoDescription()
        
        self.promotionField.delegate = self
        self.promotionField.addTarget(self, action: "promotionFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)

        self.downSwipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        self.downSwipeGesture.direction = .Down
        view.addGestureRecognizer(self.downSwipeGesture)
        
        // Add keyboard observers
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeShown:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name:UIKeyboardWillHideNotification, object: nil);
        
        // Setup outside text element tap for keyboard closing
        let tapDismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tapDismissKeyboard)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if (self.promoData["code"]! != nil) {
            GaskyFoundation.sharedInstance.checkPromoValidity({ (valid: Bool) in
                if (valid == false) {
                    let alertController = UIAlertController(title: "Your promo code has expired", message:
                        "", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    self.displayPromoForm()
                }
            })
        }
    }
    
    @IBAction func backButtonTap(sender: AnyObject) {
        self.segueBack()
    }
    
    @IBAction func promoCodeLabelTap(sender: AnyObject) {
        self.promotionField.becomeFirstResponder()
    }
    
    @IBAction func actionButtonTap(sender: AnyObject) {
        if (self.action == 0) {
            self.submitPromo()
        }
        
        if (self.action == 1) {
            self.removePromo()
        }
    }
    
    func keyboardWillBeShown(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.bottomConstraint.constant = keyboardFrame.size.height
        
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        self.bottomConstraint.constant = 0
        
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        GaskyFoundation.setFieldColor(textField, state: "normal")
        
        if (textField.text == self.promotionFieldPlaceholder) {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text == "") {
            if (textField == self.promotionField) {
                textField.text = self.promotionFieldPlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === self.promotionField && self.action == 0) {
            self.submitPromo()
        }
        
        return true
    }
    
    func transitionOffsetDefault() {
        self.actionButtonOffset.constant = self.defaultOffset
        
        UIView.animateWithDuration(0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func transitionOffsetExpanded() {
        self.actionButtonOffset.constant = self.expandedOffset
        
        UIView.animateWithDuration(0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func setPromoDescription() {
        if (self.promoData["dollarAmountOff"]! != nil) {
            self.promotionDescription.text = "Save $" + String(promoData["dollarAmountOff"]!!) + " off your next order"
        }
        
        if (self.promoData["percentOff"]! != nil) {
            self.promotionDescription.text = "Save " + String(promoData["percentOff"]!!) + "% off your next order"
        }
    }
    
    func promotionFieldDidChange(textField: UITextField) {
        if (textField.text!.characters.count > 0) {
            self.promotionFieldValid = true
            self.enableActionButton()
        } else {
            self.promotionFieldValid = false
            self.disableActionButton()
        }
    }
    
    func enableActionButton() {
        if (self.action == 0) {
            self.actionButton.backgroundColor = GaskyFoundation.buttonEnabled
            self.actionButton.setTitleColor(GaskyFoundation.buttonEnabledText, forState: UIControlState.Normal)
        }
    }
    
    func disableActionButton() {
        if (self.action == 0) {
            self.actionButton.backgroundColor = GaskyFoundation.buttonDisabled
            self.actionButton.setTitleColor(GaskyFoundation.buttonDisabledText, forState: UIControlState.Normal)
        }
    }
    
    func switchToClearButton() {
        self.actionButton.setTitle("Clear Promo Code", forState: UIControlState.Normal)
        self.actionButton.layer.borderWidth = 1
        self.actionButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.actionButton.backgroundColor = UIColor.blackColor()
        self.actionButton.setTitleColor(GaskyFoundation.buttonEnabledText, forState: UIControlState.Normal)
    }
    
    func switchToApplyButton() {
        self.actionButton.setTitle("Apply", forState: UIControlState.Normal)
        self.actionButton.layer.borderWidth = 0
        self.actionButton.layer.borderColor = UIColor.blackColor().CGColor
        self.actionButton.backgroundColor = GaskyFoundation.buttonDisabled
        self.actionButton.setTitleColor(GaskyFoundation.buttonDisabledText, forState: UIControlState.Normal)
    }
    
    func displayPromoData() {
        self.promotionField.text = promoData["code"] as? String
        self.setPromoDescription()
        self.promotionField.userInteractionEnabled = false
        GaskyFoundation.setFieldColor(self.promotionField, state: "normal")
        self.action = 1
        self.switchToClearButton()
        self.transitionOffsetExpanded()
        self.promotionDescription.hidden = false
        self.promotionDescription.alpha = 0
        UIView.animateWithDuration(0.4, animations: {
            self.promotionDescription.alpha = 1
        })
    }
    
    func displayPromoForm() {
        self.promotionField.text = self.promotionFieldPlaceholder
        self.promotionField.userInteractionEnabled = true
        GaskyFoundation.setFieldColor(self.promotionField, state: "neutral")
        self.action = 0
        self.switchToApplyButton()
        self.transitionOffsetDefault()
        self.promotionDescription.alpha = 1
        UIView.animateWithDuration(0.4, animations: {
            self.promotionDescription.alpha = 0
        })
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
    
    func submitPromo() {
        view.endEditing(true)
        if (self.submittingInfo == false) {
            if (self.promotionField.text == self.promotionFieldPlaceholder) {
                GaskyFoundation.setFieldColor(self.promotionField, state: "error")
            } else if (self.promotionFieldValid == false) {
                self.promotionField.becomeFirstResponder()
            } else {
                self.submittingInfo = true
                GaskyFoundation.sharedInstance.updatePromo(self.promotionField.text!) { (result: NSInteger) in
                    if (result == 200) {
                        let alertController = UIAlertController(title: "Your promo code has been applied successfully", message:
                            "", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        self.promoData = GaskyFoundation.sharedInstance.getPromoInfo()
                        self.displayPromoData()
                    } else {
                        if (result == 401) {
                            // User is invalid, send back to intro screen
                        }
                        
                        if (result == 400) {
                            // Email address exists in system already
                            let alertController = UIAlertController(title: "Invalid discount code", message:
                                "", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                        
                        if (result == 0) {
                            // Service is currently down
                            let alertController = UIAlertController(title: "Server Unreachable", message:
                                "Check your network connection and try again", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                    self.submittingInfo = false
                }
            }
        }
    }
    
    func removePromo() {
        GaskyFoundation.sharedInstance.removePromo()
        self.displayPromoForm()
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
