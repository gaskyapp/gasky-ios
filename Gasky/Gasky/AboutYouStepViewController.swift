//
//  AboutYouStepViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 2/18/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class AboutYouStepViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    // Label connections
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    
    // Text field connections
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var mobileField: UITextField!
    
    // Button connections
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    // Layout connections
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var formTopConstraint: NSLayoutConstraint!
    
    // Placeholder trackers
    var namePlaceholder: String = ""
    var mobilePlaceholder: String = ""
    
    // View state variables
    var setupState: Int = 0
    var nameFieldValid: Bool = false
    var mobileFieldValid: Bool = false
    var doneButtonState: Bool = false
    var submittingInfo: Bool = false
    var button: UIButton?
    var openField: String? = nil
    
    // Layout constraint changes
    let formTopConstantNormal: CGFloat = 110
    let formTopConstantKeyboard: CGFloat = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set status bar color to light
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Set up attributed strings, bug in IB doesn't allow for definition there
        let skipAttributes = [
            NSForegroundColorAttributeName: GaskyFoundation.neutralColor,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ]
        let underlineSkip = NSAttributedString(string: self.skipButton.currentTitle!, attributes: skipAttributes)
        self.skipButton.setAttributedTitle(underlineSkip, forState: .Normal)
        
        // Hide error label
        self.errorLabel.hidden = true
        
        self.setupState = GaskyFoundation.sharedInstance.getPersonalInfoViewOverride()
        if (self.setupState == 1) {
            // Reintroduced to registration path
            self.skipButton.hidden = true
            
            var totalSteps = 3
            
            if (GaskyFoundation.sharedInstance.doesHaveVehicleInfo() == true) {
                totalSteps--
            }
            
            if (GaskyFoundation.sharedInstance.doesHavePaymentMethodInfo() == true) {
                totalSteps--
            }
            
            self.stepLabel.text = "Step 1 of " + String(totalSteps)
        }
        
        // Setup text fields and note placeholders
        GaskyFoundation.setFieldColor(self.nameField, state: "neutral")
        GaskyFoundation.setFieldColor(self.mobileField, state: "neutral")
        self.namePlaceholder = self.nameField.text!
        self.mobilePlaceholder = self.mobileField.text!
        self.nameField.delegate = self
        self.mobileField.delegate = self
        self.nameField.addTarget(self, action: "nameFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.mobileField.addTarget(self, action: "mobileFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        // Setup buttons
        self.nextButton.backgroundColor = GaskyFoundation.buttonDisabled
        self.nextButton.setTitleColor(GaskyFoundation.buttonDisabledText, forState: UIControlState.Normal)
        
        // Add swipe gesture
        let swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeGesture.direction = .Down
        view.addGestureRecognizer(swipeGesture)
        
        // Create custom return button for num pad
        self.createReturnButton()
        
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
        self.nameField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func nameLabelTap(sender: AnyObject) {
        self.nameField.becomeFirstResponder()
    }
    
    @IBAction func mobileLabelTap(sender: AnyObject) {
        self.mobileField.becomeFirstResponder()
    }
    
    @IBAction func nextButtonTap(sender: AnyObject) {
        self.submitInfo()
    }
    
    @IBAction func closeButtonTap(sender: AnyObject) {
        if (self.submittingInfo == false) {
            self.segueBack()
        }
    }
    
    @IBAction func skipButtonTap(sender: AnyObject) {
        if (self.submittingInfo == false) {
            self.segueBack()
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        if (self.submittingInfo == false) {
            self.segueBack()
        }
    }
    
    /*func keyboardWillShow(note: NSNotification) -> Void {
        self.button!.hidden = true
        
        if (self.openField == "mobileField") {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.button!.hidden = false
                let keyBoardWindow = UIApplication.sharedApplication().windows.last
                self.button!.frame = CGRectMake(0, (keyBoardWindow?.frame.size.height)!-53, 106, 53)
                keyBoardWindow?.addSubview(self.button!)
                keyBoardWindow?.bringSubviewToFront(self.button!)
                UIView.animateWithDuration(((note.userInfo! as NSDictionary).objectForKey(UIKeyboardAnimationCurveUserInfoKey)?.doubleValue)!, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.view.frame = CGRectOffset(self.view.frame, 0, 0)
                    }, completion: { (complete) -> Void in
                        
                })
            }
        }
    }*/
    
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
        GaskyFoundation.setFieldColor(textField, state: "normal")
        
        if (textField === self.nameField) {
            self.openField = "nameField"
        }
        
        if (textField.text == self.namePlaceholder) {
            textField.text = ""
        }
        
        if (textField === self.mobileField) {
            self.openField = "mobileField"
        }
        
        if (textField.text == self.mobilePlaceholder) {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text == "") {
            if (textField == self.nameField) {
                textField.text = self.namePlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
            
            if (textField == self.mobileField) {
                textField.text = self.mobilePlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === self.nameField) {
            self.mobileField.becomeFirstResponder()
        } else if (textField === self.mobileField) {
            self.mobileField.resignFirstResponder()
            self.submitInfo()
        }
        
        return true
    }
    
    func nameFieldDidChange(textField: UITextField) {
        if (Validation.wordCount(textField.text!) > 1) {
            self.nameFieldValid = true
        } else {
            self.nameFieldValid = false
        }
        nextButtonSwitch();
    }
    
    func mobileFieldDidChange(textField: UITextField) {
        var convertNSString = textField.text!.stringByReplacingOccurrencesOfString(".", withString: "") as NSString
        
        if (convertNSString.length > 3) {
            convertNSString = convertNSString.substringWithRange(NSRange(location: 0, length: 3)) + "." + convertNSString.substringFromIndex(3)
        }
        
        if (convertNSString.length > 7) {
            convertNSString = convertNSString.substringWithRange(NSRange(location: 0, length: 7)) + "." + convertNSString.substringFromIndex(7)
        }
        
        if (convertNSString.length > 12) {
            convertNSString = convertNSString.substringWithRange(NSRange(location: 0, length: 12))
        }
        
        textField.text = convertNSString as String
        
        if (convertNSString.length == 12) {
            self.mobileFieldValid = true
        } else {
            self.mobileFieldValid = false
        }
        
        nextButtonSwitch();
    }
    
    func nextButtonSwitch() {
        if (self.nameFieldValid == true && self.mobileFieldValid == true) {
            self.nextButton.backgroundColor = GaskyFoundation.buttonEnabled
            self.nextButton.setTitleColor(GaskyFoundation.buttonEnabledText, forState: UIControlState.Normal)
            self.doneButtonState = true
        } else {
            self.nextButton.backgroundColor = GaskyFoundation.buttonDisabled
            self.nextButton.setTitleColor(GaskyFoundation.buttonDisabledText, forState: UIControlState.Normal)
            self.doneButtonState = false
        }
    }
    
    func submitInfo() {
        view.endEditing(true)
        
        if (self.submittingInfo == false) {
            errorLabel.hidden = true
            
            if (self.nameField.text == self.namePlaceholder || self.mobileField.text == self.mobilePlaceholder) {
                if (self.mobileField.text == self.mobilePlaceholder) {
                    GaskyFoundation.setFieldColor(self.mobileField, state: "error")
                }
                if (self.nameField.text == self.namePlaceholder) {
                    GaskyFoundation.setFieldColor(self.nameField, state: "error")
                }
            } else if (self.nameFieldValid == false) {
                errorLabel.text = "Enter first & last name"
                errorLabel.hidden = false;
            } else if (self.mobileFieldValid == false) {
                errorLabel.text = "Enter valid U.S. number"
                errorLabel.hidden = false;
            }
            else if (self.doneButtonState == false) {
                // Done button is gray, soft validation not passed yet
            } else {
                self.submittingInfo = true
                GaskyFoundation.sharedInstance.updateInfo(self.nameField.text!, mobile: self.mobileField.text!, email: nil) { (result: NSInteger) in
                    if (result == 200) {
                        self.errorLabel.hidden = true
                        
                        if (GaskyFoundation.sharedInstance.doesHaveVehicleInfo() == false) {
                            NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedInfoStepTwo"])
                        } else if (GaskyFoundation.sharedInstance.doesHavePaymentMethodInfo() == false) {
                            NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedInfoStepThree"])
                        } else {
                            NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
                        }
                    } else {
                        if (result == 401) {
                            // User is invalid, send back to intro screen
                        }
                        
                        if (result == 0) {
                            // Service is currently down
                            self.errorLabel.text = "Service is currently unavailable"
                        }
                        
                        self.errorLabel.hidden = false
                    }
                    self.submittingInfo = false
                }
            }
        }
    }
    
    func createReturnButton() {
        self.button = UIButton(type: UIButtonType.Custom)
        self.button!.setTitle("return", forState: UIControlState.Normal)
        self.button!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.button!.frame = CGRectMake(0, 163, 106, 53)
        self.button!.adjustsImageWhenHighlighted = false
        self.button!.addTarget(self, action: "Done:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func Done(sender: UIButton){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if (self.openField == "mobileField") {
                self.mobileField.resignFirstResponder()
                self.submitInfo()
            }
        }
    }
    
    func segueBack() {
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
