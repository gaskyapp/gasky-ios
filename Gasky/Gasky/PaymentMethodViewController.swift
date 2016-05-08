//
//  PaymentMethodViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 2/26/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class PaymentMethodViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    // Primary view connections
    @IBOutlet weak var addPaymentView: UIView!
    @IBOutlet weak var viewPaymentsView: UIView!
    @IBOutlet weak var addPaymentConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewPaymentsConstraint: NSLayoutConstraint!
    
    // Label connections
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    
    // Text field connections
    @IBOutlet weak var cardField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var cvvField: UITextField!
    @IBOutlet weak var zipField: UITextField!
    
    // Button connections
    @IBOutlet weak var cardButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var addPaymentButton: UIButton!
    
    // Payment list references
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var refCardImage: UIImageView!
    @IBOutlet weak var refCardLabel: UILabel!
    @IBOutlet weak var refDefaultLabel: UILabel!
    
    // Layout connections
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var formTopConstraint: NSLayoutConstraint!
    
    // Placeholder trackers
    var cardPlaceholder: String = ""
    var datePlaceholder: String = ""
    var cvvPlaceholder: String = ""
    var zipPlaceholder: String = ""
    
    // View state variables
    var setupState: Int = 0
    var cardFieldValid: Bool = false
    var dateFieldValid: Bool = false
    var cvvFieldValid: Bool = false
    var zipFieldValid: Bool = false
    var doneButtonState: Bool = false
    var submittingInfo: Bool = false
    var forceCardFieldClear: Bool = false
    var button: UIButton?
    var openField: String? = nil
    var cardType: String = ""
    var cardNumbers: String = ""
    var paymentImages: [UIImageView] = []
    var paymentLabels: [UILabel] = []
    var defaultLabels: [UILabel] = []
    var paymentButtons: [UIButton] = []
    var paymentSeparators: [UIView] = []
    var paymentIds: [Int] = []
    
    // Layout constraint changes
    let formTopConstantNormal: CGFloat = 110
    let formTopConstantKeyboard: CGFloat = 50
    
    // Braintree variables
    var braintreeClient: BTAPIClient?
    var clientToken: String? = nil
    
    // Back button tracking
    // 0 = back out, 1 = back to payment list
    var backState: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set status bar color to light
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Hide date, cvv and zip fields
        self.cardLabel.hidden = true
        self.dateField.hidden = true
        self.cvvField.hidden = true
        self.zipField.hidden = true
        
        // Set up attributed strings, bug in IB doesn't allow for definition there
        let skipAttributes = [
            NSForegroundColorAttributeName: GaskyFoundation.neutralColor,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ]
        let underlineSkip = NSAttributedString(string: self.skipButton.currentTitle!, attributes: skipAttributes)
        self.skipButton.setAttributedTitle(underlineSkip, forState: .Normal)
        
        // Fetch a fresh Braintree client token
        self.newClientToken()
        
        // Hide error label
        self.errorLabel.hidden = true
        
        // Setup text fields, overall visual override and note placeholders
        let assignedStep: Int = GaskyFoundation.sharedInstance.getPaymentMethodStep()
        self.stepLabel.text = "Step " + String(assignedStep) + " of " + String(assignedStep)
        self.cardPlaceholder = self.cardField.text!
        self.datePlaceholder = self.dateField.text!
        self.cvvPlaceholder = self.cvvField.text!
        self.zipPlaceholder = self.zipField.text!
        self.setupState = GaskyFoundation.sharedInstance.getPaymentViewOverride()
        if (self.setupState == 1) {
            // Reintroduced to registration path
            GaskyFoundation.setFieldColor(self.cardField, state: "neutral")
            GaskyFoundation.setFieldColor(self.dateField, state: "neutral")
            GaskyFoundation.setFieldColor(self.cvvField, state: "neutral")
            GaskyFoundation.setFieldColor(self.zipField, state: "neutral")
            self.skipButton.hidden = true
            self.viewPaymentsView.hidden = true
        } else if (self.setupState == 2) {
            // Single point edit
            self.mainLabel.text = "ADD PAYMENT "
            self.stepLabel.text = ""
            //self.nextButton.setTitle("Update", forState: UIControlState.Normal)
            self.skipButton.hidden = true
            
            let hasInfo = GaskyFoundation.sharedInstance.doesHavePaymentMethodInfo()
            if (hasInfo == true) {
                self.displayPaymentData()
            } else {
                self.viewPaymentsView.hidden = true
            }

            GaskyFoundation.setFieldColor(self.dateField, state: "neutral")
            GaskyFoundation.setFieldColor(self.cvvField, state: "neutral")
            GaskyFoundation.setFieldColor(self.zipField, state: "neutral")
        } else {
            // Initial registraion path
            GaskyFoundation.setFieldColor(self.cardField, state: "neutral")
            GaskyFoundation.setFieldColor(self.dateField, state: "neutral")
            GaskyFoundation.setFieldColor(self.cvvField, state: "neutral")
            GaskyFoundation.setFieldColor(self.zipField, state: "neutral")
            self.viewPaymentsView.hidden = true
        }
        self.cardField.delegate = self
        self.dateField.delegate = self
        self.cvvField.delegate = self
        self.zipField.delegate = self
        self.cardField.addTarget(self, action: "cardFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.dateField.addTarget(self, action: "dateFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.cvvField.addTarget(self, action: "cvvFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.zipField.addTarget(self, action: "zipFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)

        // Setup buttons
        self.nextButton.backgroundColor = GaskyFoundation.buttonDisabled
        self.nextButton.setTitleColor(GaskyFoundation.buttonDisabledText, forState: UIControlState.Normal)
        
        // Create custom return button for num pad
        self.createReturnButton()
        
        // Add swipe gesture
        let swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeGesture.direction = .Down
        view.addGestureRecognizer(swipeGesture)
        
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
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func paymentMethodTap(sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let ok = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
            GaskyFoundation.sharedInstance.deletePaymentMethod(self.paymentIds[sender.tag], completion: { (status: Int) -> Void in
                if (status == 200) {
                    self.cleanDisplayPaymentData()
                    self.displayPaymentData()
                    if (self.paymentIds.count == 0) {
                        self.transitionToAddForm()
                    }
                } else {
                    self.displayErrorMessage("Payment not deleted")
                }
            })
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            // Silence
        })
        let delete = UIAlertAction(title: "Set as Default", style: .Default) { (action) -> Void in
            GaskyFoundation.sharedInstance.defaultPaymentMethod(self.paymentIds[sender.tag], completion: { (status: Int) -> Void in
                if (status == 200) {
                    // Silence
                } else {
                    self.displayErrorMessage("Default payment not changed")
                }
            })
            self.setDefaultPaymentMethod(sender.tag)
        }
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.addAction(delete)
        
        presentViewController(alertController, animated: true, completion: nil)
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
    
    @IBAction func cardButtonTap(sender: AnyObject) {
        self.cardDigitsSwitch()
    }
    
    @IBAction func addPaymentButton(sender: AnyObject) {
        self.transitionToAddForm()
    }
    
    func displayErrorMessage(title: String) {
        //++ error popup
    }
    
    func displayPaymentData() {
        let paymentInfo = GaskyFoundation.sharedInstance.getPaymentMethodInfo()
        var referencesHidden: Bool = false
        var index: Int = 0
        
        for paymentData in paymentInfo {
            if (referencesHidden == false) {
                referencesHidden = true
                self.refCardImage.hidden = true
                self.refCardLabel.hidden = true
                self.refDefaultLabel.hidden = true
            }
            
            if let defaultMethod = paymentData["default"].boolValue as? Bool, let digits = paymentData["digits"] as? String,
                let expired = paymentData["expired"].boolValue as? Bool, let idString = paymentData["id"] as? String,
                let type = paymentData["type"] as? String {
                    if let id = Int(idString) {
                        // Add card identifier
                        let cardLabel = UILabel()
                        cardLabel.translatesAutoresizingMaskIntoConstraints = false
                        cardLabel.text = type + " ..." + String(digits)
                        cardLabel.font = self.refCardLabel.font
                        cardLabel.textColor = self.refCardLabel.textColor
                        cardLabel.userInteractionEnabled = false
                        self.contentView.addSubview(cardLabel)
                        if (paymentLabels.count > 0) {
                            // Add separating line
                            let separator = UIView(frame: CGRect(x: 0, y: 0, width: 580, height: 1))
                            separator.translatesAutoresizingMaskIntoConstraints = false
                            separator.backgroundColor = UIColor.lightGrayColor()
                            separator.alpha = 0.25
                            separator.userInteractionEnabled = false
                            self.contentView.addSubview(separator)
                            separator.heightAnchor.constraintEqualToConstant(1).active = true
                            separator.leadingAnchor.constraintEqualToAnchor(self.contentView.leadingAnchor, constant: 10).active = true
                            separator.trailingAnchor.constraintEqualToAnchor(self.contentView.trailingAnchor, constant: -10).active = true
                            separator.topAnchor.constraintEqualToAnchor(self.paymentLabels[paymentLabels.count - 1].bottomAnchor, constant: 12).active = true
                            cardLabel.topAnchor.constraintEqualToAnchor(separator.bottomAnchor, constant: 12).active = true
                            self.paymentSeparators.append(separator)
                        } else {
                            cardLabel.topAnchor.constraintEqualToAnchor(self.paymentLabel.bottomAnchor, constant: 40).active = true
                        }
                        
                        // Add card icon
                        let cardImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
                        cardImage.translatesAutoresizingMaskIntoConstraints = false
                        cardImage.image = self.refCardImage.image
                        cardImage.contentMode = UIViewContentMode.ScaleAspectFill
                        cardImage.userInteractionEnabled = false
                        self.contentView.addSubview(cardImage)
                        cardImage.heightAnchor.constraintEqualToConstant(12).active = true
                        cardImage.widthAnchor.constraintEqualToConstant(12).active = true
                        cardImage.leadingAnchor.constraintEqualToAnchor(self.contentView.leadingAnchor, constant: 18).active = true
                        cardImage.centerYAnchor.constraintEqualToAnchor(cardLabel.centerYAnchor, constant: 0).active = true
                        
                        // Position card identifier relative to card icon
                        cardLabel.leadingAnchor.constraintEqualToAnchor(cardImage.trailingAnchor, constant: 15).active = true
                        
                        // Add default label
                        let defaultLabel = UILabel()
                        defaultLabel.translatesAutoresizingMaskIntoConstraints = false
                        defaultLabel.text = "Default"
                        defaultLabel.font = self.refDefaultLabel.font
                        defaultLabel.textColor = self.refDefaultLabel.textColor
                        self.contentView.addSubview(defaultLabel)
                        if (defaultMethod == false) {
                            defaultLabel.hidden = true
                        }
                        defaultLabel.trailingAnchor.constraintEqualToAnchor(self.contentView.trailingAnchor, constant: -18).active = true
                        defaultLabel.centerYAnchor.constraintEqualToAnchor(cardLabel.centerYAnchor, constant: 0).active = true
                        
                        // Add button
                        let cardButton = UIButton()
                        cardButton.translatesAutoresizingMaskIntoConstraints = false
                        self.contentView.addSubview(cardButton)
                        cardButton.leadingAnchor.constraintEqualToAnchor(cardImage.leadingAnchor, constant: 0).active = true
                        cardButton.trailingAnchor.constraintEqualToAnchor(defaultLabel.trailingAnchor, constant: 0).active = true
                        cardButton.centerYAnchor.constraintEqualToAnchor(defaultLabel.centerYAnchor, constant: 0).active = true
                        cardButton.heightAnchor.constraintEqualToConstant(30).active = true
                        cardButton.tag = index
                        cardButton.addTarget(self, action: "paymentMethodTap:", forControlEvents: UIControlEvents.TouchUpInside)
                        
                        // Append data to arrays
                        self.paymentLabels.append(cardLabel)
                        self.defaultLabels.append(defaultLabel)
                        self.paymentImages.append(cardImage)
                        self.paymentButtons.append(cardButton)
                        self.paymentIds.append(id)
                        index++
                    }
            }
        }
        
        if (paymentLabels.count > 0) {
            self.addPaymentButton.topAnchor.constraintEqualToAnchor(self.paymentLabels[paymentLabels.count - 1].bottomAnchor, constant: 40).active = true
        }
        
        self.view.layoutIfNeeded()
    }
    
    func cleanDisplayPaymentData() {
        for separator in self.paymentSeparators {
            separator.removeFromSuperview()
        }
        self.paymentSeparators = []
        
        for label in self.paymentLabels {
            label.removeFromSuperview()
        }
        self.paymentLabels = []
        
        for label in self.defaultLabels {
            label.removeFromSuperview()
        }
        self.defaultLabels = []
        
        for image in self.paymentImages {
            image.removeFromSuperview()
        }
        self.paymentImages = []
        
        for button in self.paymentButtons {
            button.removeFromSuperview()
        }
        self.paymentButtons = []
        
        self.paymentIds = []
    }
    
    func setDefaultPaymentMethod(index: Int) {
        var i = 0
        
        for label in self.defaultLabels {
            if (i == index) {
                label.hidden = false
            } else {
                label.hidden = true
            }
            i++
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
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.button!.hidden = false
            let keyBoardWindow = UIApplication.sharedApplication().windows.last
            self.button!.frame = CGRectMake(0, (keyBoardWindow?.frame.size.height)!-53, 106, 53)
            keyBoardWindow?.addSubview(self.button!)
            keyBoardWindow?.bringSubviewToFront(self.button!)
            UIView.animateWithDuration(((note.userInfo! as NSDictionary).objectForKey(UIKeyboardAnimationCurveUserInfoKey)?.doubleValue)!, delay: 0,options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.view.frame = CGRectOffset(self.view.frame, 0, 0)
                    }, completion: { (complete) -> Void in
                        
            })
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
        
        if (textField === self.cardField) {
            if (self.forceCardFieldClear == true) {
                self.cardField.text = ""
                self.forceCardFieldClear = false
            }
            
            self.openField = "cardField"
        }
        
        if (textField.text == self.cardPlaceholder) {
            textField.text = ""
        }
        
        if (textField === self.dateField) {
            self.openField = "dateField"
        }
        
        if (textField.text == self.datePlaceholder) {
            textField.text = ""
        }
        
        if (textField === self.cvvField) {
            self.openField = "cvvField"
        }
        
        if (textField.text == self.cvvPlaceholder) {
            textField.text = ""
        }
        
        if (textField === self.zipField) {
            self.openField = "zipField"
        }
        
        if (textField.text == self.zipPlaceholder) {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text == "") {
            if (textField == self.cardField) {
                textField.text = self.cardPlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
            
            if (textField == self.dateField) {
                textField.secureTextEntry = false
                textField.text = self.datePlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
            
            if (textField == self.cvvField) {
                textField.secureTextEntry = false
                textField.text = self.cvvPlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
            
            if (textField == self.zipField) {
                textField.secureTextEntry = false
                textField.text = self.zipPlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
        }
    }
    
    func cardFieldDidChange(textField: UITextField) {
        if (textField.text!.characters.count > 2) {
            var CCLength = 16
            let doubleRange = textField.text!.startIndex.advancedBy(2)
            let doubleValidator = Int(textField.text!.substringToIndex(doubleRange))
            let singleRange = textField.text!.startIndex.advancedBy(1)
            let singleValidator = Int(textField.text!.substringToIndex(singleRange))
            
            if (doubleValidator == 34 || doubleValidator == 37) {
                // AMEX
                self.cardType = "AMEX"
                CCLength = 15
            } else if (doubleValidator == 35) {
                // JCB
                self.cardType = "JCB"
            } else if (singleValidator == 6) {
                // Discover
                self.cardType = "Discover"
            } else if (singleValidator == 5) {
                // MasterCard
                self.cardType = "MasterCard"
            } else if (singleValidator == 4) {
                // Visa
                self.cardType = "Visa"
            } else {
                // Unrecognized or unsupported card
                self.cardType = ""
                self.cardFieldValid = false
            }
            
            var numberAsNSString = textField.text!.stringByReplacingOccurrencesOfString(" ", withString: "") as NSString
            self.cardNumbers = numberAsNSString as String
            
            if (CCLength == 15) {
                self.cardFieldValid = false
                
                if (numberAsNSString.length > 4) {
                    numberAsNSString = numberAsNSString.substringWithRange(NSRange(location: 0, length: 4)) + " " + numberAsNSString.substringFromIndex(4)
                }
                
                if (numberAsNSString.length > 11) {
                    numberAsNSString = numberAsNSString.substringWithRange(NSRange(location: 0, length: 11)) + " " + numberAsNSString.substringFromIndex(11)
                }
                
                if (numberAsNSString.length > 17) {
                    numberAsNSString = numberAsNSString.substringWithRange(NSRange(location: 0, length: 17))
                }
                
                if (numberAsNSString.length == 17) {
                    self.cardFieldValid = true
                }
            } else {
                self.cardFieldValid = false
                
                if (numberAsNSString.length > 4) {
                    numberAsNSString = numberAsNSString.substringWithRange(NSRange(location: 0, length: 4)) + " " + numberAsNSString.substringFromIndex(4)
                }
                
                if (numberAsNSString.length > 9) {
                    numberAsNSString = numberAsNSString.substringWithRange(NSRange(location: 0, length: 9)) + " " + numberAsNSString.substringFromIndex(9)
                }
                
                if (numberAsNSString.length > 14) {
                    numberAsNSString = numberAsNSString.substringWithRange(NSRange(location: 0, length: 14)) + " " + numberAsNSString.substringFromIndex(14)
                }
                
                if (numberAsNSString.length > 19) {
                    numberAsNSString = numberAsNSString.substringWithRange(NSRange(location: 0, length: 19))
                }
                
                if (numberAsNSString.length == 19 && self.cardType != "") {
                    self.cardFieldValid = true
                }
            }
            
            textField.text = numberAsNSString as String
        } else {
            self.cardFieldValid = false
        }
        
        if (self.cardFieldValid == true) {
            view.endEditing(true)
            cardDetailsSwitch()
        }
        
        nextButtonSwitch()
    }
    
    func dateFieldDidChange(textField: UITextField) {
        var convertNSString = textField.text!.stringByReplacingOccurrencesOfString("/", withString: "") as NSString
        
        if (convertNSString.length > 2) {
            convertNSString = convertNSString.substringWithRange(NSRange(location: 0, length: 2)) + "/" + convertNSString.substringFromIndex(2)
        }
        
        if (convertNSString.length > 5) {
            convertNSString = convertNSString.substringWithRange(NSRange(location: 0, length: 5))
        }
        
        textField.text = convertNSString as String
        
        if (convertNSString.length == 5) {
            self.dateFieldValid = true
        } else {
            self.dateFieldValid = false
        }
        nextButtonSwitch()
    }
    
    func cvvFieldDidChange(textField: UITextField) {
        let convertNSString = textField.text! as NSString
        
        if (textField.text!.characters.count > 4) {
            textField.text = convertNSString.substringWithRange(NSRange(location: 0, length: 4)) as String
        }
        
        if (textField.text!.characters.count >= 3) {
            self.cvvFieldValid = true
        } else {
            self.cvvFieldValid = false
        }
        nextButtonSwitch()
    }
    
    func zipFieldDidChange(textField: UITextField) {
        let convertNSString = textField.text! as NSString
        
        if (textField.text!.characters.count > 5) {
            textField.text = convertNSString.substringWithRange(NSRange(location: 0, length: 5)) as String
        }
        
        if (textField.text!.characters.count == 5) {
            self.zipFieldValid = true
        } else {
            self.zipFieldValid = false
        }
        nextButtonSwitch()
    }
    
    func cardDetailsSwitch() {
        let last4 = self.cardNumbers.endIndex.advancedBy(-4)
        let lastDigits = self.cardNumbers.substringFromIndex(last4)
        
        self.cardLabel.text = self.cardType + " " + lastDigits
        
        UIView.animateWithDuration(0.2, animations: {
            self.cardField.alpha = 0
        }, completion: {
            (value: Bool) in
            self.cardField.hidden = true
            self.cardLabel.hidden = false
            self.dateField.hidden = false
            self.cvvField.hidden = false
            self.zipField.hidden = false
            self.cardLabel.alpha = 0
            self.dateField.alpha = 0
            self.cvvField.alpha = 0
            self.zipField.alpha = 0
            
            UIView.animateWithDuration(0.2, animations: {
                self.cardLabel.alpha = 1
                self.dateField.alpha = 1
                self.cvvField.alpha = 1
                self.zipField.alpha = 1
            })
        })
    }
    
    func cardDigitsSwitch() {
        UIView.animateWithDuration(0.2, animations: {
            self.cardLabel.alpha = 0
            self.dateField.alpha = 0
            self.cvvField.alpha = 0
            self.zipField.alpha = 0
        }, completion: {
            (value: Bool) in
            self.cardField.hidden = false
            self.cardField.alpha = 0
            self.cardLabel.hidden = true
            self.dateField.hidden = true
            self.cvvField.hidden = true
            self.zipField.hidden = true
                
            UIView.animateWithDuration(0.2, animations: {
                self.cardField.alpha = 1
            })
        })
    }
    
    func hideCardForm() {
        
    }
    
    func storePaymentData(number: String, month: String, year: String, cvv: String, zip: String, id: Int, makeDefault: Bool) {
        self.braintreeClient = BTAPIClient(authorization: self.clientToken!)
        
        let cardClient = BTCardClient(APIClient: self.braintreeClient!)
        let card = BTCard(number: number, expirationMonth: month, expirationYear: year, cvv: cvv)
        cardClient.tokenizeCard(card) { (tokenizedCard, error) in
            if (error == nil) {
                GaskyFoundation.sharedInstance.updatePaymentMethod(tokenizedCard!.nonce, zip: zip, id: id, makeDefault: makeDefault) { (status: Int, error: String) in
                    if (status == 200) {
                        if (self.setupState == 2) {
                            self.cleanDisplayPaymentData()
                            self.displayPaymentData()
                            self.transitionToPaymentsList()
                            self.submittingInfo = false
                        } else {
                            NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
                        }
                    } else {
                        self.errorLabel.hidden = false
                        self.errorLabel.text = error
                        self.submittingInfo = false
                    }
                }
            } else {
                self.errorLabel.hidden = false
                self.errorLabel.text = "Error adding card, try again"
                self.submittingInfo = false
            }
            self.newClientToken()
        }
    }
    
    func nextButtonSwitch() {
        if (self.cardFieldValid == true && self.dateFieldValid == true && self.cvvFieldValid == true && self.zipFieldValid == true) {
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
            self.errorLabel.hidden = true
            
            if (self.cardField.text == self.cardPlaceholder || self.dateField.text == self.datePlaceholder || self.cvvField.text == self.cvvPlaceholder || self.zipField.text == self.zipPlaceholder) {
                if (self.cardField.text == self.cardPlaceholder) {
                    GaskyFoundation.setFieldColor(self.cardField, state: "error")
                }
                if (self.dateField.text == self.datePlaceholder) {
                    GaskyFoundation.setFieldColor(self.dateField, state: "error")
                }
                if (self.cvvField.text == self.cvvPlaceholder) {
                    GaskyFoundation.setFieldColor(self.cvvField, state: "error")
                }
                if (self.zipField.text == self.zipPlaceholder) {
                    GaskyFoundation.setFieldColor(self.zipField, state: "error")
                }
            } else if (self.cardFieldValid == false) {
                errorLabel.text = "Enter valid card number"
                errorLabel.hidden = false;
            } else if (self.dateFieldValid == false) {
                errorLabel.text = "Enter valid expiration date"
                errorLabel.hidden = false;
            } else if (self.cvvFieldValid == false) {
                errorLabel.text = "Enter valid card CVV"
                errorLabel.hidden = false;
            } else if (self.zipFieldValid == false) {
                errorLabel.text = "Enter valid zip code"
                errorLabel.hidden = false;
            }
            else if (self.doneButtonState == false) {
                // Done button is gray, soft validation not passed yet
            } else {
                if (self.clientToken == nil) {
                    errorLabel.text = "Wait a moment and try again"
                    errorLabel.hidden = false;
                } else {
                    self.submittingInfo = true
                    
                    // Split expiration into month and year
                    let dateString = self.dateField.text! as NSString
                    let cardMonth = dateString.substringWithRange(NSRange(location: 0, length: 2))
                    let cardYear = "20" + dateString.substringWithRange(NSRange(location: 3, length: 2))
                    
                    self.storePaymentData(self.cardNumbers, month: cardMonth, year: cardYear, cvv: self.cvvField.text!, zip: self.zipField.text!, id: 0, makeDefault: true)
                }
            }
        }
    }
    
    func newClientToken() {
        self.clientToken = nil
        
        GaskyFoundation.sharedInstance.getClientToken() { (result: String) in
            self.clientToken = result
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
            if (self.openField == "cardField") {
                self.dateField.becomeFirstResponder()
            } else if (self.openField == "dateField") {
                self.cvvField.becomeFirstResponder()
            } else if (self.openField == "cvvField") {
                self.zipField.becomeFirstResponder()
            } else if (self.openField == "zipField") {
                self.zipField.resignFirstResponder()
                self.submitInfo()
            }
        }
    }
    
    func transitionToPaymentsList() {
        self.backState = 0
        self.addPaymentConstraint.constant = 0
        self.viewPaymentsConstraint.constant = self.view.frame.height
        self.view.layoutIfNeeded()
        self.viewPaymentsView.hidden = false
        
        self.viewPaymentsConstraint.constant = 0
        self.addPaymentConstraint.constant = -self.view.frame.height
        
        self.dismissKeyboard()
        
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func transitionToAddForm() {
        if (self.cardField.text != self.cardPlaceholder) {
            self.cardField.text = self.cardPlaceholder
            self.dateField.text = self.datePlaceholder
            self.cvvField.text = self.cvvPlaceholder
            self.zipField.text = self.zipPlaceholder
            GaskyFoundation.setFieldColor(self.cardField, state: "neutral")
            GaskyFoundation.setFieldColor(self.dateField, state: "neutral")
            GaskyFoundation.setFieldColor(self.cvvField, state: "neutral")
            GaskyFoundation.setFieldColor(self.zipField, state: "neutral")
            self.cardDigitsSwitch()
        }
        
        self.backState = 1
        
        if (self.paymentIds.count == 0) {
            self.backState = 0
        }
        
        self.viewPaymentsConstraint.constant = 0
        self.addPaymentConstraint.constant = -self.view.frame.height
        self.view.layoutIfNeeded()
        
        self.viewPaymentsConstraint.constant = self.view.frame.height
        self.addPaymentConstraint.constant = 0
        
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func segueBack() {
        if (self.backState == 1) {
            self.transitionToPaymentsList()
        } else {
            let orderStatus = GaskyFoundation.sharedInstance.returnOrderStatus()
            
            if (orderStatus["id"]! != nil) {
                NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderTracker"])
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
            }
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
