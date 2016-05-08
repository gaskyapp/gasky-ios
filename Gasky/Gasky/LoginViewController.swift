//
//  LoginViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 1/20/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // Label connections
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var registerLabel: UILabel!
    
    // Text field connections
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // Button connections
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    // Layout connections
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var formTopConstraint: NSLayoutConstraint!
    
    // Placeholder trackers
    var emailPlaceholder: String = ""
    var passwordPlaceholder: String = ""
    
    // View state variables
    var emailFieldValid: Bool = false
    var passwordFieldValid: Bool = false
    var doneButtonState: Bool = false
    var submittingLogin: Bool = false
    
    // Layout constraint changes
    let formTopConstantNormal: CGFloat = 110
    let formTopConstantKeyboard: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set status bar color to light
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Set up attributed strings, bug in IB doesn't allow for definition there
        let forgotPasswordAttributes = [
            NSForegroundColorAttributeName: GaskyFoundation.neutralColor,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ]
        let underlineForgotPassword = NSAttributedString(string: self.forgotPasswordButton.currentTitle!, attributes: forgotPasswordAttributes)
        self.forgotPasswordButton.setAttributedTitle(underlineForgotPassword, forState: .Normal)
        
        let registerString = NSMutableAttributedString(string: self.registerLabel.text!)
        registerString.addAttribute(NSForegroundColorAttributeName, value: GaskyFoundation.neutralColor, range: NSMakeRange(0, 22))
        registerString.addAttribute(NSForegroundColorAttributeName, value: GaskyFoundation.normalColor, range: NSMakeRange(23, 14))
        registerString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSMakeRange(23, 14))
        self.registerLabel.attributedText = registerString
        
        // Hide error label
        self.errorLabel.hidden = true
        
        // Setup text fields and note placeholders
        GaskyFoundation.setFieldColor(self.emailField, state: "neutral")
        GaskyFoundation.setFieldColor(self.passwordField, state: "neutral")
        self.emailPlaceholder = self.emailField.text!
        self.passwordPlaceholder = self.passwordField.text!
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.emailField.addTarget(self, action: "emailFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.passwordField.addTarget(self, action: "passwordFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
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
    
    @IBAction func emailLabelTap(sender: AnyObject) {
        self.emailField.becomeFirstResponder()
    }
    
    @IBAction func passwordLabelTap(sender: AnyObject) {
        self.passwordField.becomeFirstResponder()
    }
    
    @IBAction func doneButtonTap(sender: AnyObject) {
        self.signIn()
    }
    
    @IBAction func closeButtonTap(sender: AnyObject) {
        self.segueToIntro()
    }
    
    @IBAction func registerButtonTap(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedRegister"])
    }
    
    @IBAction func forgotButtonTap(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedForgotPassword"])
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        self.segueToIntro()
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
        self.errorLabel.hidden = true
        GaskyFoundation.setFieldColor(textField, state: "normal")
        
        if (textField.text == self.emailPlaceholder) {
            textField.text = ""
        }
        
        if (textField.text == self.passwordPlaceholder) {
            textField.secureTextEntry = true
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text == "") {
            if (textField == self.emailField) {
                textField.text = self.emailPlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
            
            if (textField == self.passwordField) {
                textField.secureTextEntry = false
                textField.text = self.passwordPlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === self.emailField) {
            self.passwordField.becomeFirstResponder()
        } else if (textField === self.passwordField) {
            self.passwordField.resignFirstResponder()
            self.signIn()
        }
        
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
    
    func passwordFieldDidChange(textField: UITextField) {
        if (textField.text!.characters.count > 7) {
            self.passwordFieldValid = true
        } else {
            self.passwordFieldValid = false
        }
        doneButtonSwitch();
    }
    
    func doneButtonSwitch() {
        if (self.emailFieldValid == true && self.passwordFieldValid == true) {
            self.doneButton.backgroundColor = GaskyFoundation.buttonEnabled
            self.doneButton.setTitleColor(GaskyFoundation.buttonEnabledText, forState: UIControlState.Normal)
            self.doneButtonState = true
        } else {
            self.doneButton.backgroundColor = GaskyFoundation.buttonDisabled
            self.doneButton.setTitleColor(GaskyFoundation.buttonDisabledText, forState: UIControlState.Normal)
            self.doneButtonState = false
        }
    }
    
    func signIn() {
        if (self.submittingLogin == false) {
            if (self.emailField.text == self.emailPlaceholder || self.passwordField.text == self.passwordPlaceholder) {
                if (self.emailField.text == self.emailPlaceholder) {
                    GaskyFoundation.setFieldColor(self.emailField, state: "error")
                }
                
                if (self.passwordField.text == self.passwordPlaceholder) {
                    GaskyFoundation.setFieldColor(self.passwordField, state: "error")
                }
            } else if (self.doneButtonState == false) {
                // Done button is gray, soft validation not yet passed
            } else {
                self.submittingLogin = true
                GaskyFoundation.sharedInstance.login(self.emailField.text!, password: self.passwordField.text!) { (result: Bool) in
                    if (result == true) {
                        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
                    } else {
                        self.errorLabel.hidden = false
                    }
                    
                    self.submittingLogin = false
                }
            }
        }
    }
    
    func segueToIntro() {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedIntro"])
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
