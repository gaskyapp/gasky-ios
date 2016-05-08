//
//  AccountViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 2/18/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class AccountViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // label connections
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var photoLabel: UILabel!
    
    // Text field connections
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var mobileField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    // Button connections
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    
    // Primary scroll view connection
    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    // Layout connections
    @IBOutlet weak var closeButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // Image view connections
    @IBOutlet weak var accountPhoto: UIImageView!
    @IBOutlet weak var addPhotoIcon: UIImageView!
    
    // Placeholder trackers
    var namePlaceholder: String = ""
    var emailPlaceholder: String = ""
    var mobilePlaceholder: String = ""
    
    // View state variables
    var nameFieldValid: Bool = false
    var mobileFieldValid: Bool = false
    var emailFieldValid: Bool = false
    var doneButtonState: Bool = false
    var submittingInfo: Bool = false
    var lockContentScroll: Bool = false
    var button: UIButton?
    var openField: String? = nil
    // Current close action tracker. 0 = scene, 1 = camera
    var closeAction: Int = 0
    
    // Camera variables
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var shutterButtonTreatment: UIView!
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var torchOnImage: UIImageView!
    @IBOutlet weak var torchOffImage: UIImageView!
    @IBOutlet weak var rollButton: UIButton!
    @IBOutlet weak var rollImage: UIImageView!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var retakeImage: UIImageView!
    @IBOutlet weak var retakeLabel: UILabel!
    @IBOutlet weak var useButton: UIButton!
    @IBOutlet weak var useImage: UIImageView!
    @IBOutlet weak var useLabel: UILabel!
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var cameraTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cameraView: UIView!
    
    var session: AVCaptureSession!
    var input: AVCaptureDeviceInput!
    var output: AVCaptureStillImageOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var camera: AVCaptureDevice!
    var approvedPhoto: UIImage? = nil
    var photoOnFile: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set status bar color to light
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Set up attributed strings, bug in IB doesn't allow for definition there
        let lostPasswordAttributes = [
            NSForegroundColorAttributeName: GaskyFoundation.neutralColor,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ]
        let underlineLostPassword = NSAttributedString(string: self.forgotPasswordButton.currentTitle!, attributes: lostPasswordAttributes)
        self.forgotPasswordButton.setAttributedTitle(underlineLostPassword, forState: .Normal)
        let underlineSignOut = NSAttributedString(string: self.signOutButton.currentTitle!, attributes: lostPasswordAttributes)
        self.signOutButton.setAttributedTitle(underlineSignOut, forState: .Normal)
        
        // Set up initial camera off screen
        self.cameraView.hidden = true
        
        // Hide error label
        self.errorLabel.hidden = true
        self.accountPhoto.alpha = 0
        
        // Setup text fields and note placeholders
        self.namePlaceholder = self.nameField.text!
        self.emailPlaceholder = self.emailField.text!
        self.mobilePlaceholder = self.mobileField.text!
        let accountInfo = GaskyFoundation.sharedInstance.getPersonalInfo()
        if (accountInfo["name"]! != nil && !accountInfo["name"]!!.isEmpty) {
            self.nameField.text = accountInfo["name"]!
            GaskyFoundation.setFieldColor(self.nameField, state: "normal")
            self.nameFieldDidChange(self.nameField)
        }
        if (accountInfo["phone"]! != nil && !accountInfo["phone"]!!.isEmpty) {
            self.mobileField.text = accountInfo["phone"]!
            GaskyFoundation.setFieldColor(self.mobileField, state: "normal")
            self.mobileFieldDidChange(self.mobileField)
        }
        if (accountInfo["email"]! != nil) {
            self.emailField.text = accountInfo["email"]!
            GaskyFoundation.setFieldColor(self.emailField, state: "normal")
            self.emailFieldDidChange(self.emailField)
        }
        
        if (accountInfo["photo"]! != nil) {
            self.photoOnFile = true
            self.photoLabel.text = "Edit Photo"
            self.addPhotoIcon.hidden = true
            self.accountPhoto.downloadedFrom(link: accountInfo["photo"]!!, contentMode: .ScaleAspectFill)
        }
        self.nameField.delegate = self
        self.mobileField.delegate = self
        self.emailField.delegate = self
        self.nameField.addTarget(self, action: "nameFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.mobileField.addTarget(self, action: "mobileFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.emailField.addTarget(self, action: "emailFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        // Setup buttons
        self.nextButton.backgroundColor = GaskyFoundation.buttonDisabled
        self.nextButton.setTitleColor(GaskyFoundation.buttonDisabledText, forState: UIControlState.Normal)
        
        // Add swipe gesture
        let swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeGesture.direction = .Down
        view.addGestureRecognizer(swipeGesture)
        
        // Create custom return button for num pad
        //self.createReturnButton()

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
        self.accountPhoto.layer.cornerRadius = self.accountPhoto.frame.width / 2
        self.accountPhoto.clipsToBounds = true
        UIView.animateWithDuration(0.25, animations: {
            self.accountPhoto.alpha = 1
        })
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
    
    @IBAction func emailLabelTap(sender: AnyObject) {
        self.emailField.becomeFirstResponder()
    }
    
    @IBAction func nextButtonTap(sender: AnyObject) {
        self.submitInfo()
    }
    
    @IBAction func closeButtonTap(sender: AnyObject) {
        if (self.submittingInfo == false) {
            self.segueBack()
        }
    }
    
    @IBAction func forgotPasswordButtonTap(sender: AnyObject) {
        if (self.submittingInfo == false) {
            NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedForgotPassword"])
        }
    }
    
    @IBAction func signOut(sender: AnyObject) {
        GaskyFoundation.sharedInstance.logout()
    }
    
    @IBAction func photoButtonTap(sender: AnyObject) {
        self.transitionToCamera()
    }
    
    @IBAction func torchButtonTap(sender: AnyObject) {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureTorchMode.On) {
                    device.torchMode = AVCaptureTorchMode.Off
                    self.torchOffImage.hidden = false
                    self.torchOnImage.hidden = true
                } else {
                    do {
                        try device.setTorchModeOnWithLevel(1.0)
                        self.torchOffImage.hidden = true
                        self.torchOnImage.hidden = false
                    } catch { }
                }
                device.unlockForConfiguration()
            } catch { }
        }
    }
    
    @IBAction func shutterButtonTap(sender: AnyObject) {
        guard let connection = self.output.connectionWithMediaType(AVMediaTypeVideo) else { return }
        connection.videoOrientation = .Portrait
        
        output.captureStillImageAsynchronouslyFromConnection(connection) { (sampleBuffer, error) in
            guard sampleBuffer != nil && error == nil else { return }
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
            guard let image = UIImage(data: imageData) else { return }
            
            self.displayCapturedImage(image)
        }
        
        self.transitionControlsToConfirm()
    }
    
    @IBAction func rollButtonTap(sender: AnyObject) {
        self.disableTorch()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func retakeButtonTap(sender: AnyObject) {
        self.transitionConfirmToControls()
    }
    
    @IBAction func useButtonTap(sender: AnyObject) {
        self.transitionToForm()
        if (self.approvedPhoto != nil) {
            GaskyFoundation.sharedInstance.updateInfoPhoto(self.approvedPhoto!) { (result: NSInteger) in
                if (result == 200) {
                    // Photo uploaded
                } else {
                    if (result == 401) {
                        // User is invalid, send back to intro screen
                    }
                    
                    if (result == 0) {
                        // Service is currently down
                        //++ Display popup error notification
                    }
                }
            }
        }
        self.photoOnFile = true
        self.accountPhoto.image = self.approvedPhoto
        self.addPhotoIcon.hidden = true
        self.photoLabel.text = "Edit Photo"
        self.nextButtonSwitch()
    }

    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        if (self.submittingInfo == false) {
            self.segueBack()
        }
    }
    
    func adjustBackButtonForCamera() {
        self.closeAction = 1
        self.closeButtonConstraint.constant = 25
        
        UIView.animateWithDuration(0.05, delay: 0.45, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (_) -> Void in
                // Nothing after
        }
    }
    
    func adjustBackButtonForAccount() {
        self.closeAction = 0
        self.closeButtonConstraint.constant = 23
        
        UIView.animateWithDuration(0.08, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (_) -> Void in
                // Nothing after
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
        
        if (textField === self.emailField) {
            self.openField = "emailField"
        }
        
        if (textField.text == self.emailPlaceholder) {
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
            
            if (textField == self.emailField) {
                textField.text = self.emailPlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === self.nameField) {
            self.emailField.becomeFirstResponder()
        } else if (textField == self.emailField) {
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
        nextButtonSwitch()
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
        nextButtonSwitch()
    }
    
    func emailFieldDidChange(textField: UITextField) {
        if (Validation.validateEmail(textField.text!) == true) {
            self.emailFieldValid = true
        } else {
            self.emailFieldValid = false
        }
        nextButtonSwitch()
    }
    
    func nextButtonSwitch() {
        if (self.nameFieldValid == true && self.mobileFieldValid == true && self.emailFieldValid == true) {
            self.nextButton.backgroundColor = GaskyFoundation.buttonEnabled
            self.nextButton.setTitleColor(GaskyFoundation.buttonEnabledText, forState: UIControlState.Normal)
            self.doneButtonState = true
        } else {
            self.nextButton.backgroundColor = GaskyFoundation.buttonDisabled
            self.nextButton.setTitleColor(GaskyFoundation.buttonDisabledText, forState: UIControlState.Normal)
            self.doneButtonState = false
        }
    }
    
    func transitionToCamera() {
        self.cameraTopConstraint.constant = self.view.frame.height
        self.view.layoutIfNeeded()
        self.cameraView.hidden = false
        
        self.setupSession()
        self.previewLayer!.frame = self.previewView.bounds
        
        view.endEditing(true)
        self.contentScrollView.showsVerticalScrollIndicator = false
        self.lockContentScroll = true
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.contentScrollView.contentOffset.y = 0
            }) { (_) -> Void in
        }
        
        self.setupCameraControls()
        self.adjustBackButtonForCamera()
        
        self.cameraTopConstraint.constant = self.closeButton.frame.height + 5 + self.closeButtonConstraint.constant
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func transitionToForm() {
        self.contentScrollView.showsVerticalScrollIndicator = true
        self.lockContentScroll = false
        
        self.adjustBackButtonForAccount()
        
        self.cameraTopConstraint.constant = self.view.frame.height
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
        
        self.nextButtonSwitch()
    }
    
    func submitInfo() {
        view.endEditing(true)
        if (self.submittingInfo == false) {
            errorLabel.hidden = true
            
            if (self.nameField.text == self.namePlaceholder || self.mobileField.text == self.mobilePlaceholder || self.emailField.text == self.emailPlaceholder) {
                if (self.mobileField.text == self.mobilePlaceholder) {
                    GaskyFoundation.setFieldColor(self.mobileField, state: "error")
                }
                if (self.nameField.text == self.namePlaceholder) {
                    GaskyFoundation.setFieldColor(self.nameField, state: "error")
                }
                if (self.emailField.text == self.emailPlaceholder) {
                    GaskyFoundation.setFieldColor(self.emailField, state: "error")
                }
            } else if (self.nameFieldValid == false) {
                errorLabel.text = "Enter first & last name"
                errorLabel.hidden = false;
            } else if (self.mobileFieldValid == false) {
                errorLabel.text = "Enter valid U.S. number"
                errorLabel.hidden = false;
            } else if (self.emailFieldValid == false) {
                errorLabel.text = "Enter valid email address"
                errorLabel.hidden = false;
            }
            else if (self.doneButtonState == false) {
                // Done button is gray, soft validation not passed yet
            } else {
                self.submittingInfo = true
                GaskyFoundation.sharedInstance.updateInfo(self.nameField.text!, mobile: self.mobileField.text!, email: self.emailField.text!) { (result: NSInteger) in
                    if (result == 200) {
                        self.errorLabel.hidden = true
                        
                        self.segueBack()
                    } else {
                        if (result == 401) {
                            // User is invalid, send back to intro screen
                        }
                        
                        if (result == 409) {
                            // Email address exists in system already
                            self.errorLabel.text = "Email address already exists"
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
        if (closeAction == 0) {
            let orderStatus = GaskyFoundation.sharedInstance.returnOrderStatus()
                
            if (orderStatus["id"]! != nil) {
                NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderTracker"])
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
            }
        }
        if (closeAction == 1) {
            self.adjustBackButtonForAccount()
            self.transitionToForm()
        }
    }
    
    func setupCameraControls() {
        self.capturedImage.hidden = true
        self.controlsView.hidden = false
        //self.controlsView.alpha = 1
        self.torchOffImage.hidden = false
        self.torchOnImage.hidden = true
        self.retakeButton.hidden = true
        self.retakeImage.hidden = true
        self.retakeLabel.hidden = true
        self.useButton.hidden = true
        self.useImage.hidden = true
        self.useLabel.hidden = true
        self.retakeButton.alpha = 0
        self.retakeImage.alpha = 0
        self.retakeLabel.alpha = 0
        self.useButton.alpha = 0
        self.useImage.alpha = 0
        self.useLabel.alpha = 0
        self.shutterButton.hidden = false
        self.shutterButtonTreatment.hidden = false
        self.torchButton.hidden = false
        self.rollButton.hidden = false
        self.rollImage.hidden = false
        self.shutterButton.alpha = 1
        self.shutterButtonTreatment.alpha = 1
        self.torchButton.alpha = 1
        self.torchOnImage.alpha = 1
        self.torchOffImage.alpha = 1
        self.rollButton.alpha = 1
        self.rollImage.alpha = 1
        self.makeLayerCircular(self.shutterButton)
        self.makeLayerCircular(self.shutterButtonTreatment)
        self.makeLayerCircular(self.torchButton)
        self.makeLayerCircular(self.rollButton)
        self.makeLayerCircular(self.retakeButton)
        self.makeLayerCircular(self.useButton)
        self.view.layoutIfNeeded()
    }
    
    func makeLayerCircular(object: UIView) {
        object.layer.cornerRadius = object.layer.frame.width / 2.0
        object.clipsToBounds = true
    }
    
    func transitionControlsToConfirm() {
        self.retakeButton.hidden = false
        self.retakeImage.hidden = false
        self.retakeLabel.hidden = false
        self.useButton.hidden = false
        self.useImage.hidden = false
        self.useLabel.hidden = false
        
        UIView.animateWithDuration(0.25, animations: {
            self.shutterButton.alpha = 0
            self.shutterButtonTreatment.alpha = 0
            self.torchButton.alpha = 0
            self.torchOnImage.alpha = 0
            self.torchOffImage.alpha = 0
            self.rollButton.alpha = 0
            self.rollImage.alpha = 0
            }, completion: {
                (value: Bool) in
                self.shutterButton.hidden = true
                self.shutterButtonTreatment.hidden = true
                self.torchButton.hidden = true
                self.torchOnImage.hidden = true
                self.torchOffImage.hidden = true
                self.rollButton.hidden = true
                self.rollImage.hidden = true
                self.disableTorch()
                
                UIView.animateWithDuration(0.25, animations: {
                    self.retakeButton.alpha = 1
                    self.retakeImage.alpha = 1
                    self.retakeLabel.alpha = 1
                    self.useButton.alpha = 1
                    self.useImage.alpha = 1
                    self.useLabel.alpha = 1
                })
        })
    }
    
    func transitionConfirmToControls() {
        self.photoOnFile = false
        self.capturedImage.hidden = true
        self.shutterButton.hidden = false
        self.shutterButtonTreatment.hidden = false
        self.torchButton.hidden = false
        self.torchOnImage.hidden = false
        self.torchOffImage.hidden = false
        self.rollButton.hidden = false
        self.rollImage.hidden = false
        
        UIView.animateWithDuration(0.25, animations: {
            self.retakeButton.alpha = 0
            self.retakeImage.alpha = 0
            self.retakeLabel.alpha = 0
            self.useButton.alpha = 0
            self.useImage.alpha = 0
            self.useLabel.alpha = 0
            }, completion: {
                (value: Bool) in
                self.retakeButton.hidden = true
                self.retakeImage.hidden = true
                self.retakeLabel.hidden = true
                self.useButton.hidden = true
                self.useImage.hidden = true
                self.useLabel.hidden = true
                
                UIView.animateWithDuration(0.25, animations: {
                    self.shutterButton.alpha = 1
                    self.shutterButtonTreatment.alpha = 1
                    self.torchButton.alpha = 1
                    self.torchOnImage.alpha = 1
                    self.torchOffImage.alpha = 1
                    self.rollButton.alpha = 1
                    self.rollImage.alpha = 1
                })
        })
    }
    
    func setupSession() {
        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSessionPresetPhoto
        
        self.camera = AVCaptureDevice
            .defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do { self.input = try AVCaptureDeviceInput(device: self.camera) } catch { return }
        
        self.output = AVCaptureStillImageOutput()
        self.output.outputSettings = [ AVVideoCodecKey: AVVideoCodecJPEG ]
        
        guard self.session.canAddInput(self.input) && self.session.canAddOutput(self.output) else { return }
        
        self.session.addInput(self.input)
        self.session.addOutput(self.output)
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.previewLayer!.frame = self.previewView.bounds
        self.previewLayer!.connection?.videoOrientation = .Portrait
        
        self.previewView.layer.addSublayer(self.previewLayer!)
        
        self.session.startRunning()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.displayCapturedImage(image)
        self.approvedPhoto = image
        self.dismissViewControllerAnimated(true, completion: nil);
        self.transitionControlsToConfirm()
    }
    
    func displayCapturedImage(image: UIImage) {
        self.capturedImage.hidden = false
        self.capturedImage.image = image
        self.capturedImage.contentMode = UIViewContentMode.ScaleAspectFill
        self.capturedImage.clipsToBounds = true
        self.approvedPhoto = image
    }
    
    func disableTorch() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureTorchMode.On) {
                    device.torchMode = AVCaptureTorchMode.Off
                    self.torchOffImage.hidden = false
                    self.torchOnImage.hidden = true
                }
                device.unlockForConfiguration()
            } catch { }
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

extension UIImageView {
    func downloadedFrom(link link:String, contentMode mode: UIViewContentMode) {
        guard
            let url = NSURL(string: link)
            else {return}
        contentMode = mode
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.image = image
            }
        }).resume()
    }
}