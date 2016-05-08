//
//  ForgotPasswordViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 2/12/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    // Label connections
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    // Text field connections
    @IBOutlet weak var emailField: UITextField!
    
    // Button connections
    @IBOutlet weak var doneButton: UIButton!
    
    // Layout connections
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var formTopConstraint: NSLayoutConstraint!
    
    // Placeholder trackers
    var emailPlaceholder: String = ""
    
    // View state variables
    var emailFieldValid: Bool = false
    var doneButtonState: Bool = false
    var submittingRequest: Bool = false
    
    // Layout constraint changes
    let formTopConstantNormal: CGFloat = 110
    let formTopConstantKeyboard: CGFloat = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set status bar color to light
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        // Hide error label
        self.errorLabel.hidden = true
        
        // Setup text fields and note placeholders
        GaskyFoundation.setFieldColor(self.emailField, state: "neutral")
        self.emailPlaceholder = self.emailField.text!
        self.emailField.delegate = self
        self.emailField.addTarget(self, action: "emailFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        // Setup buttons
        self.doneButton.backgroundColor = GaskyFoundation.buttonDisabled
        self.doneButton.setTitleColor(GaskyFoundation.buttonDisabledText, forState: UIControlState.Normal)
        
        // Add swipe gesture
        let swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeGesture.direction = .Down
        view.addGestureRecognizer(swipeGesture)
        
        // Add keyboard observers
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
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func emailButtonTap(sender: AnyObject) {
        self.emailField.becomeFirstResponder()
    }
    
    @IBAction func doneButtonTap(sender: AnyObject) {
        self.forgotPassword()
    }
    
    @IBAction func closeButtonTap(sender: AnyObject) {
        self.segueBack()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        self.segueBack()
    }
    
    func keyboardWillBeShown(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.formTopConstraint.constant = self.formTopConstantKeyboard
        self.bottomConstraint.constant = keyboardFrame.size.height
        
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        self.formTopConstraint.constant = self.formTopConstantNormal
        self.bottomConstraint.constant = 0
        
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        GaskyFoundation.setFieldColor(self.emailField, state: "normal")
        
        if (textField.text == self.emailPlaceholder) {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text == "") {
            if (textField == self.emailField) {
                textField.text = self.emailPlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.emailField.resignFirstResponder()
        self.forgotPassword()
        
        return true
    }
    
    func emailFieldDidChange(textField: UITextField) {
        if (Validation.validateEmail(textField.text!) == true) {
            self.emailFieldValid = true
        } else {
            self.emailFieldValid = false
        }
        doneButtonSwitch();
    }
    
    func doneButtonSwitch() {
        if (self.emailFieldValid == true) {
            self.doneButton.backgroundColor = GaskyFoundation.buttonEnabled
            self.doneButton.setTitleColor(GaskyFoundation.buttonEnabledText, forState: UIControlState.Normal)
            self.doneButtonState = true
        } else {
            self.doneButton.backgroundColor = GaskyFoundation.buttonDisabled
            self.doneButton.setTitleColor(GaskyFoundation.buttonDisabledText, forState: UIControlState.Normal)
            self.doneButtonState = false
        }
    }
    
    func forgotPassword() {
        if (self.submittingRequest == false) {
            if (self.emailField.text == self.emailPlaceholder) {
                GaskyFoundation.setFieldColor(self.emailField, state: "error")
            } else if (self.doneButtonState == false) {
                // Done button is gray, soft validation not yet passed
            } else {
                self.submittingRequest = true
                GaskyFoundation.sharedInstance.forgotPassword(self.emailField.text!) { (result: Bool) in
                    // Fire off to server and roll to confirmation page. No error returns (ex: Account does not exist) as emails which aren't in the system are dropped and not emailed.
                    NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedForgotPasswordSuccess"])
                }
            }
        }
    }
    
    func segueBack() {
        if (GaskyFoundation.sharedInstance.isLoggedIn() == true) {
            NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedLogin"])
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
