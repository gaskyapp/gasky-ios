//
//  RegisterViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 1/20/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    //Label connections
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginlabel: UILabel!
    
    // Text field connections
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // Button connections
    @IBOutlet weak var doneButton: UIButton!
    
    // Text view connections
    @IBOutlet weak var termText: UITextView!
    @IBOutlet weak var policyView: UITextView!
    @IBOutlet weak var termsView: UITextView!
    
    // Subview connections
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var legalContentView: UIView!
    
    // Image view connections
    @IBOutlet weak var closeButton: UIImageView!
    
    // Layout connections
    @IBOutlet weak var closeButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var formTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var legalContentConstraint: NSLayoutConstraint!
    
    // Placeholder trackers
    var emailPlaceholder: String = ""
    var passwordPlaceholder: String = ""
    
    // View state variables
    var emailFieldValid: Bool = false
    var passwordFieldValid: Bool = false
    var doneButtonState: Bool = false
    var submittingLogin: Bool = false
    var lockContentScroll: Bool = false
    // Current close action tracker. 0 = scene, 1 = terms, 2 = privacy
    var closeAction: Int = 0
    
    // Layout constraint changes
    let formTopConstantNormal: CGFloat = 110
    let formTopConstantKeyboard: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set status bar color to light
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Set up attributed strings, bug in IB doesn't allow for definition there
        let loginString = NSMutableAttributedString(string: self.loginlabel.text!)
        loginString.addAttribute(NSForegroundColorAttributeName, value: GaskyFoundation.neutralColor, range: NSMakeRange(0, 16))
        loginString.addAttribute(NSForegroundColorAttributeName, value: GaskyFoundation.normalColor, range: NSMakeRange(17, 7))
        loginString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSMakeRange(17, 7))
        self.loginlabel.attributedText = loginString
        
        // Setup legal text subview
        self.legalTextSetup()
        
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
        
        // Add scrollview delegates
        self.contentScrollView.delegate = self
        
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
        self.registerUser()
    }
    
    @IBAction func closeButtonTap(sender: AnyObject) {
        if (self.closeAction == 1) {
            self.adjustBackButtonForRegistration()
            self.animateOutLegalTerms(self.termsView)
            self.contentScrollView.showsVerticalScrollIndicator = true
            self.lockContentScroll = false
        } else if (self.closeAction == 2) {
            self.adjustBackButtonForRegistration()
            self.animateOutLegalTerms(self.policyView)
            self.contentScrollView.showsVerticalScrollIndicator = true
            self.lockContentScroll = false
        } else {
            self.segueToIntro()
        }
        
        self.closeAction = 0
    }
    
    @IBAction func loginLinkTap(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedLogin"])
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (self.lockContentScroll == true) {
            scrollView.contentOffset.y = 0
        }
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
            self.registerUser()
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
    
    func legalTextSetup() {
        self.legalContentView.hidden = true
        self.legalContentConstraint.constant = self.view.frame.height
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        
        let textString = NSMutableAttributedString(
            string: "By creating an account with GASKY, I accept the Terms and Privacy Policy.",
            attributes: [
                NSParagraphStyleAttributeName: paragraphStyle,
                NSBaselineOffsetAttributeName: NSNumber(float: 0),
                NSForegroundColorAttributeName: GaskyFoundation.neutralColor,
                NSFontAttributeName: UIFont(name: "Trebuchet MS", size: 14.0)!
            ]
        )
        
        let termsRange = NSRange(location: 48, length: 5)
        let policyRange = NSRange(location: 58, length: 14)
        
        let termsAttribute = ["linkTapped": "terms"]
        let policyAttribute = ["linkTapped": "policy"]
        
        textString.beginEditing()
        textString.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: termsRange)
        textString.addAttributes(termsAttribute, range: termsRange)
        textString.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: policyRange)
        textString.addAttributes(policyAttribute, range: policyRange)
        textString.endEditing()
        
        self.termText.attributedText = textString
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("legalTextTap:"))
        tap.delegate = self
        self.termText.addGestureRecognizer(tap)
    }
    
    func legalTextTap(sender: UITapGestureRecognizer) {
        let tappedView = sender.view as! UITextView
        let layoutManager = tappedView.layoutManager
        
        var location = sender.locationInView(tappedView)
        location.x -= tappedView.textContainerInset.left
        location.y -= tappedView.textContainerInset.top
        
        let characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: tappedView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if (characterIndex < tappedView.textStorage.length) {
            let attributeName = "linkTapped"
            let attributeValue = tappedView.attributedText.attribute(attributeName, atIndex: characterIndex, effectiveRange: nil) as? String
            if let value = attributeValue {
                if (value == "terms") {
                    self.openLegalTerms("terms", textView: self.termsView)
                }
                if (value == "policy") {
                    self.openLegalTerms("policy", textView: self.policyView)
                }
            }
        }
    }
    
    func openLegalTerms(legalText: NSString, textView: UITextView) {
        if (legalText == "terms") {
            self.closeAction = 1
        }
        
        if (legalText == "policy") {
            self.closeAction = 2
        }
        
        view.endEditing(true)
        self.contentScrollView.showsVerticalScrollIndicator = false
        self.lockContentScroll = true
        
        if (self.contentScrollView.contentOffset.y != 0) {
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.contentScrollView.contentOffset.y = 0
            }) { (_) -> Void in
                self.adjustBackButtonForTerms()
                self.animateInLegalTerms(textView)
            }
        } else {
            self.adjustBackButtonForTerms()
            self.animateInLegalTerms(textView)
        }
    }
    
    func adjustBackButtonForTerms() {
        self.closeButtonConstraint.constant = 25
        
        UIView.animateWithDuration(0.05, delay: 0.25, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (_) -> Void in
            // Nothing after
        }
    }
    
    func adjustBackButtonForRegistration() {
        self.closeButtonConstraint.constant = 30
        
        UIView.animateWithDuration(0.08, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (_) -> Void in
                // Nothing after
        }
    }
    
    func animateInLegalTerms(textView: UITextView) {
        self.legalContentView.hidden = false
        textView.hidden = false
        
        self.legalContentConstraint.constant = self.closeButton.frame.height + 5 + self.closeButtonConstraint.constant
        textView.contentOffset.y = 0
        
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (_) -> Void in
            // Nothing after
        }
    }
    
    func animateOutLegalTerms(textView: UITextView) {
        self.legalContentConstraint.constant = self.view.frame.height
        
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (_) -> Void in
            textView.hidden = true
            self.legalContentView.hidden = true
        }
    }
    
    func registerUser() {
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
                GaskyFoundation.sharedInstance.create(self.emailField.text!, password: self.passwordField.text!) { (result: NSInteger) in
                    if (result == 200) {
                        self.errorLabel.hidden = true
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedAccountCreated"])
                    } else {
                        if (result == 400) {
                            // Invalid email or password
                            self.errorLabel.text = "Invalid email address"
                        }
                        
                        if (result == 409) {
                            // Account with email already exists
                            self.errorLabel.text = "Account exists for this address"
                        }
                        
                        if (result == 0) {
                            // Service is currently down
                            self.errorLabel.text = "Service is currently unavailable"
                        }
                        
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
