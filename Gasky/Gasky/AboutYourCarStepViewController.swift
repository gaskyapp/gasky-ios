//
//  AboutYourCarStepViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 2/19/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class AboutYourCarStepViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Label connections
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var licenseLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    
    // Text field connections
    @IBOutlet weak var licenseField: UITextField!
    @IBOutlet weak var makeField: UITextField!
    @IBOutlet weak var modelField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var colorField: UITextField!
    
    // Button connections
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    // Sub-view connections
    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    // Layout connections
    @IBOutlet weak var closeButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var formTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var skipButtonConstraint: NSLayoutConstraint!
    
    // Placeholder trackers
    var licensePlaceholder: String = ""
    var makePlaceholder: String = ""
    var modelPlaceholder: String = ""
    var yearPlaceholder: String = ""
    var colorPlaceholder: String = ""
    
    // View state variales
    var setupState: Int = 0
    var licenseFieldValid: Bool = false
    var makeFieldValid: Bool = false
    var modelFieldValid: Bool = false
    var yearFieldValid: Bool = false
    var colorFieldValid: Bool = false
    var doneButtonState: Bool = false
    var submittingInfo: Bool = false
    var lockContentScroll: Bool = false
    // Current close action tracker. 0 = scene, 1 = camera
    var closeAction: Int = 0
    
    // Layout constraint changes
    var formTopConstantNormal: CGFloat = 110
    var formTopConstantKeyboard: CGFloat = 50
    
    // Camera related variables
    @IBOutlet weak var introView: UIView!
    @IBOutlet weak var introButton: UIButton!
    @IBOutlet weak var exampleOverlay: UIImageView!
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
    var swipeGesture: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Constraint adjustments for smaller iPhones 5/SE
        if (UIScreen.mainScreen().bounds.size.height <= 480) {
            self.formTopConstantNormal = 50
            self.formTopConstantKeyboard = 40
            
            self.formTopConstraint.constant = self.formTopConstantNormal
        }
        
        // Set status bar color to light
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Set up attributed strings, bug in IB doesn't allow for definition there
        let skipAttributes = [
            NSForegroundColorAttributeName: GaskyFoundation.neutralColor,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ]
        let underlineSkip = NSAttributedString(string: self.skipButton.currentTitle!, attributes: skipAttributes)
        self.skipButton.setAttributedTitle(underlineSkip, forState: .Normal)
        
        // Set up initial camera off screen
        self.cameraView.hidden = true
        
        // Hide error label
        self.errorLabel.hidden = true
        
        self.nextButton.backgroundColor = GaskyFoundation.buttonDisabled
        self.nextButton.setTitleColor(GaskyFoundation.buttonDisabledText, forState: UIControlState.Normal)
        
        // Set placeholder values
        self.licensePlaceholder = self.licenseField.text!
        self.makePlaceholder = self.makeField.text!
        self.modelPlaceholder = self.modelField.text!
        self.yearPlaceholder = self.yearField.text!
        self.colorPlaceholder = self.colorField.text!
        
        let assignedStep: Int = GaskyFoundation.sharedInstance.getVehicleInfoStep()
        
        var totalSteps = 3;
        if (assignedStep == 1) {
            totalSteps = 2
        }
        
        if (GaskyFoundation.sharedInstance.doesHavePaymentMethodInfo() == true) {
            totalSteps = assignedStep
        }
        
        self.stepLabel.text = "Step " + String(assignedStep) + " of " + String(totalSteps)
        
        self.setupState = GaskyFoundation.sharedInstance.getVehicleViewOverride()
        if (self.setupState == 1) {
            // Reintroduced to registration path
            GaskyFoundation.setFieldColor(self.licenseField, state: "neutral")
            GaskyFoundation.setFieldColor(self.makeField, state: "neutral")
            GaskyFoundation.setFieldColor(self.modelField, state: "neutral")
            GaskyFoundation.setFieldColor(self.yearField, state: "neutral")
            GaskyFoundation.setFieldColor(self.colorField, state: "neutral")
            self.skipButton.hidden = true
        } else if (self.setupState == 2) {
            // Single point edit
            self.mainLabel.text = "CAR "
            self.stepLabel.text = ""
            self.nextButton.setTitle("Save Changes", forState: UIControlState.Normal)
            self.skipButton.hidden = true
            self.skipButtonConstraint.constant = 5
            
            let vehicleInfo = GaskyFoundation.sharedInstance.getVehicleInfo()
            if (vehicleInfo["license"]! != nil) {
                self.licenseField.text = vehicleInfo["license"]!
                GaskyFoundation.setFieldColor(self.licenseField, state: "normal")
                self.licenseFieldValid = true
            } else {
                GaskyFoundation.setFieldColor(self.licenseField, state: "neutral")
            }
            
            if (vehicleInfo["make"]! != nil) {
                self.makeField.text = vehicleInfo["make"]!
                GaskyFoundation.setFieldColor(self.makeField, state: "normal")
                self.makeFieldValid = true
            } else {
                GaskyFoundation.setFieldColor(self.makeField, state: "neutral")
            }
            
            if (vehicleInfo["model"]! != nil) {
                self.modelField.text = vehicleInfo["model"]!
                GaskyFoundation.setFieldColor(self.modelField, state: "normal")
                self.modelFieldValid = true
            } else {
                GaskyFoundation.setFieldColor(self.modelField, state: "neutral")
            }
            
            if (vehicleInfo["year"]! != nil) {
                self.yearField.text = vehicleInfo["year"]!
                GaskyFoundation.setFieldColor(self.yearField, state: "normal")
                self.yearFieldValid = true
            } else {
                GaskyFoundation.setFieldColor(self.yearField, state: "neutral")
            }
            
            if (vehicleInfo["color"]! != nil) {
                self.colorField.text = vehicleInfo["color"]!
                GaskyFoundation.setFieldColor(self.colorField, state: "normal")
                self.colorFieldValid = true
            } else {
                GaskyFoundation.setFieldColor(self.colorField, state: "neutral")
            }
            
            if (vehicleInfo["photo"]! != nil) {
                self.photoOnFile = true
                self.nextButtonSwitch()
            }
        } else {
            // Initial registration path
            GaskyFoundation.setFieldColor(self.licenseField, state: "neutral")
            GaskyFoundation.setFieldColor(self.makeField, state: "neutral")
            GaskyFoundation.setFieldColor(self.modelField, state: "neutral")
            GaskyFoundation.setFieldColor(self.yearField, state: "neutral")
            GaskyFoundation.setFieldColor(self.colorField, state: "neutral")
        }
        
        self.licenseField.delegate = self
        self.makeField.delegate = self
        self.modelField.delegate = self
        self.yearField.delegate = self
        self.colorField.delegate = self
        self.contentScrollView.delegate = self
        
        self.licenseField.addTarget(self, action: "licenseFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.makeField.addTarget(self, action: "makeFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.modelField.addTarget(self, action: "modelFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.yearField.addTarget(self, action: "yearFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.colorField.addTarget(self, action: "colorFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        // Add swipe gesture
        self.swipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        self.swipeGesture.direction = .Down
        view.addGestureRecognizer(self.swipeGesture)
        self.swipeGesture.enabled = true
        self.contentScrollView.panGestureRecognizer.requireGestureRecognizerToFail(self.swipeGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeShown:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name:UIKeyboardWillHideNotification, object: nil);
        
        let tapDismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tapDismissKeyboard)
        
        self.view.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.introButton.layer.borderWidth = 1
        self.introButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        if (photoOnFile == true) {
            self.photoButton.setTitleColor(GaskyFoundation.normalColor, forState: .Normal)
            self.photoButton.setTitle("Change", forState: .Normal)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if (self.setupState != 2) {
            self.licenseField.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func licenseLabelTap(sender: AnyObject) {
        self.licenseField.becomeFirstResponder()
    }
    
    @IBAction func makeLabelTap(sender: AnyObject) {
        self.makeField.becomeFirstResponder()
    }
    
    @IBAction func modelLabelTap(sender: AnyObject) {
        self.modelField.becomeFirstResponder()
    }
    
    @IBAction func yearLabelTap(sender: AnyObject) {
        self.yearField.becomeFirstResponder()
    }
    
    @IBAction func colorLabelTap(sender: AnyObject) {
        self.colorField.becomeFirstResponder()
    }
    
    @IBAction func photoLabelTap(sender: AnyObject) {
        self.transitionToCamera()
    }
    
    @IBAction func photoButtonTap(sender: AnyObject) {
        self.transitionToCamera()
    }
    
    @IBAction func nextButtonTap(sender: AnyObject) {
        view.endEditing(true)
        self.cameraView.hidden = true
        if (self.submittingInfo == false) {
            self.errorLabel.hidden = true
            
            if (self.licenseField.text == self.licensePlaceholder || self.makeField.text == self.makePlaceholder || self.colorField.text == self.colorPlaceholder || self.photoOnFile == false) {
                if (self.licenseField.text == self.licensePlaceholder) {
                    GaskyFoundation.setFieldColor(self.licenseField, state: "error")
                }
                if (self.makeField.text == self.makePlaceholder) {
                    GaskyFoundation.setFieldColor(self.makeField, state: "error")
                }
                if (self.modelField.text == self.modelPlaceholder) {
                    GaskyFoundation.setFieldColor(self.modelField, state: "error")
                }
                if (self.yearField.text == self.yearPlaceholder) {
                    GaskyFoundation.setFieldColor(self.yearField, state: "error")
                }
                if (self.colorField.text == self.colorPlaceholder) {
                    GaskyFoundation.setFieldColor(self.colorField, state: "error")
                }
                if (self.photoOnFile == false) {
                    self.photoButton.setTitleColor(GaskyFoundation.errorColor, forState: .Normal)
                }
            } else if (self.doneButtonState == false) {
                // Done button is gray, soft validation not passed yet
            } else {
                self.submittingInfo = true
                GaskyFoundation.sharedInstance.updateVehicle(self.licenseField.text!, make: self.makeField.text!, model: self.modelField.text!, year: self.yearField.text!, color: self.colorField.text!) { (result: NSInteger) in
                    if (result == 200) {
                        if (self.approvedPhoto != nil) {
                            GaskyFoundation.sharedInstance.updateVehiclePhoto(self.approvedPhoto!) { (result: NSInteger) in
                                if (result == 200) {
                                    if (self.setupState == 2) {
                                        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
                                    } else {
                                        if (GaskyFoundation.sharedInstance.doesHavePaymentMethodInfo() == false) {
                                            NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedInfoStepThree"])
                                        } else {
                                            NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
                                        }
                                        
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
                        } else {
                            if (self.setupState == 2) {
                                NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
                            } else {
                                NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedInfoStepThree"])
                            }
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
                        self.submittingInfo = false
                    }
                }
            }
        }
    }
    
    @IBAction func closeButtonTap(sender: AnyObject) {
        self.segueBack()
    }
    
    @IBAction func skipButtonTap(sender: AnyObject) {
        self.segueBack()
    }
    
    @IBAction func introButtonTap(sender: AnyObject) {
        self.transitionIntroToControls()
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
        self.photoButton.setTitleColor(GaskyFoundation.normalColor, forState: .Normal)
        self.photoButton.setTitle("Change", forState: .Normal)
        self.photoOnFile = true
        self.nextButtonSwitch()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (self.lockContentScroll == true) {
            scrollView.contentOffset.y = 0
        }
        
        if (scrollView.contentOffset.y == 0) {
            self.swipeGesture.enabled = true
        } else {
            self.swipeGesture.enabled = false
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        self.segueBack()
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
    
    func adjustBackButtonForRegistration() {
        self.closeAction = 0
        self.closeButtonConstraint.constant = 23
        
        UIView.animateWithDuration(0.08, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (_) -> Void in
                // Nothing after
        }
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
        GaskyFoundation.setFieldColor(textField, state: "normal")
        
        if (textField.text == self.licensePlaceholder) {
            textField.text = ""
        }
        
        if (textField.text == self.makePlaceholder) {
            textField.text = ""
        }
        
        if (textField.text == self.modelPlaceholder) {
            textField.text = ""
        }
        
        if (textField.text == self.yearPlaceholder) {
            textField.text = ""
        }
        
        if (textField.text == self.colorPlaceholder) {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text == "") {
            if (textField == self.licenseField) {
                textField.text = self.licensePlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
            
            if (textField == self.makeField) {
                textField.text = self.makePlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
            
            if (textField == self.modelField) {
                textField.text = self.modelPlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
            
            if (textField == self.yearField) {
                textField.text = self.yearPlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
            
            if (textField == self.colorField) {
                textField.text = self.colorPlaceholder
                GaskyFoundation.setFieldColor(textField, state: "neutral")
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === self.licenseField) {
            self.makeField.becomeFirstResponder()
        } else if (textField === self.makeField) {
            self.modelField.becomeFirstResponder()
        } else if (textField === self.modelField) {
            self.yearField.becomeFirstResponder()
        } else if (textField === self.yearField) {
            self.colorField.becomeFirstResponder()
        } else if (textField === self.colorField) {
            self.colorField.resignFirstResponder()
        }
        
        return true
    }
    
    func licenseFieldDidChange(textField: UITextField) {
        if (textField.text!.characters.count > 0) {
            self.licenseFieldValid = true
        } else {
            self.licenseFieldValid = false
        }
        nextButtonSwitch();
    }
    
    func makeFieldDidChange(textField: UITextField) {
        if (textField.text!.characters.count > 0) {
            self.makeFieldValid = true
        } else {
            self.makeFieldValid = false
        }
        nextButtonSwitch();
    }
    
    func modelFieldDidChange(textField: UITextField) {
        if (textField.text!.characters.count > 0) {
            self.modelFieldValid = true
        } else {
            self.modelFieldValid = false
        }
        nextButtonSwitch();
    }
    
    func yearFieldDidChange(textField: UITextField) {
        if (yearField.text!.characters.count > 3) {
            self.yearFieldValid = true
        } else {
            self.yearFieldValid = false
        }
        nextButtonSwitch();
    }
    
    func colorFieldDidChange(textField: UITextField) {
        if (textField.text!.characters.count > 0) {
            self.colorFieldValid = true
        } else {
            self.colorFieldValid = false
        }
        nextButtonSwitch();
    }
    
    func nextButtonSwitch() {
        if (self.licenseFieldValid == true && self.makeFieldValid == true && self.modelFieldValid == true && self.yearFieldValid == true && self.colorFieldValid == true && self.photoOnFile == true) {
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
        
        self.adjustBackButtonForRegistration()
        
        self.cameraTopConstraint.constant = self.view.frame.height
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
        
        self.nextButtonSwitch()
    }
    
    func setupCameraControls() {
        self.cameraViewHeight.constant = self.view.frame.height - self.closeButton.frame.height - 5 - self.closeButtonConstraint.constant
        self.capturedImage.hidden = true
        self.introView.hidden = false
        self.introView.alpha = 1
        self.exampleOverlay.hidden = false
        self.exampleOverlay.alpha = 0.7
        self.controlsView.hidden = true
        self.controlsView.alpha = 0
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
        self.torchOnImage.hidden = false
        self.torchOffImage.hidden = false
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
    
    func transitionIntroToControls() {
        self.capturedImage.hidden = true
        self.controlsView.hidden = false
        
        UIView.animateWithDuration(0.25, animations: {
            self.introView.alpha = 0
            self.exampleOverlay.alpha = 0
            }, completion: {
                (value: Bool) in
                self.introView.hidden = true
                self.exampleOverlay.hidden = true
                
                UIView.animateWithDuration(0.25, animations: {
                    self.controlsView.alpha = 1
                })
        })
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
    
    func segueBack() {
        if (self.submittingInfo == false) {
            if (closeAction == 0) {
                let orderStatus = GaskyFoundation.sharedInstance.returnOrderStatus()
                
                if (orderStatus["id"]! != nil) {
                    NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderTracker"])
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
                }
            }
            if (closeAction == 1) {
                self.adjustBackButtonForRegistration()
                self.transitionToForm()
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
