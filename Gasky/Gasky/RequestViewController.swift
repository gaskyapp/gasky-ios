//
//  RequestViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 2/23/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class RequestViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    // Side menu
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var menuButtonOffset: NSLayoutConstraint!
    @IBOutlet weak var menu: UIView!
    @IBOutlet weak var menuOffset: NSLayoutConstraint!
    @IBOutlet weak var menuWidth: NSLayoutConstraint!
    @IBOutlet weak var returnButton: UIButton!
    var menuOpen: Bool = false
    
    // Google Maps
    @IBOutlet weak var mapsView: UIView!
    @IBOutlet weak var mapTopOffset: NSLayoutConstraint!
    @IBOutlet weak var mapPin: UIView!
    @IBOutlet weak var mapPinButton: UIButton!
    @IBOutlet weak var pinTop: UIView!
    @IBOutlet weak var pinTopWidth: NSLayoutConstraint!
    @IBOutlet weak var pinIconBackground: UIView!
    @IBOutlet weak var pinIconBlue: UIImageView!
    @IBOutlet weak var pinIconBlack: UIImageView!
    @IBOutlet weak var pinLabel: UILabel!
    @IBOutlet weak var pinShadow: UIView!
    @IBOutlet weak var mapArrow: UIView!
    @IBOutlet weak var mapArrowButton: UIButton!
    var mapView: GMSMapView? = nil
    var pinchReference: CGFloat = 0
    //var mapMarker: GMSMarker? = nil
    var locationManager = CLLocationManager()
    var myCurrentLocation: CLLocationCoordinate2D? = nil
    var didFindMyLocation: Bool = false
    var liveTrackLocation: Bool = true
    var didLayoutGoogle: Bool = false
    var canTap: Bool = true
    var pricing = [String:Float?]()
    var serviceAreas: [[[Double]]] = []
    var serviceAreaPaths: [GMSPath] = []
    
    // Order Information
    var orderAddress: String? = nil
    var orderCoords: CLLocationCoordinate2D? = nil
    var extraDetails: String = ""
    
    // Order Form
    var submittingInfo = false
    @IBOutlet weak var orderFormHeader: UIView!
    @IBOutlet weak var orderFormBack: UIView!
    @IBOutlet weak var orderFormContainer: UIScrollView!
    @IBOutlet weak var orderFormContents: UIView!
    @IBOutlet weak var shortFormMeasure: UIView!
    @IBOutlet weak var regularLabel: UILabel!
    @IBOutlet weak var regularButton: UIButton!
    @IBOutlet weak var dieselLabel: UILabel!
    @IBOutlet weak var dieselButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var detailsField: UITextField!
    @IBOutlet weak var deliveryTimeSelected: UILabel!
    @IBOutlet weak var deliveryTimeButton: UIButton!
    @IBOutlet weak var paymentOnFile: UILabel!
    @IBOutlet weak var carOnFile: UILabel!
    @IBOutlet weak var promoOnFile: UILabel!
    @IBOutlet weak var finePrint: UILabel!
    @IBOutlet weak var orderFormOffset: NSLayoutConstraint!
    @IBOutlet weak var orderFormBackOffset: NSLayoutConstraint!
    @IBOutlet weak var orderFormHeight: NSLayoutConstraint!
    @IBOutlet weak var requestOfset: NSLayoutConstraint!
    @IBOutlet weak var requestOffsetBottom: NSLayoutConstraint!
    @IBOutlet weak var finePrintOffset: NSLayoutConstraint!
    @IBOutlet weak var promoButton: UIButton!
    
    // Time selection form
    @IBOutlet weak var separatorLine: UIView!
    @IBOutlet weak var timeSelectionView: UIView!
    @IBOutlet weak var timeListContainer: UIScrollView!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var tomorrowLabel: UILabel!
    @IBOutlet weak var timeSelectionOffset: NSLayoutConstraint!
    @IBOutlet weak var closeTimeSelection: UIButton!
    @IBOutlet weak var today9am10amLabel: UILabel!
    @IBOutlet weak var today9am10amButton: UIButton!
    @IBOutlet weak var today9am10amOffset: NSLayoutConstraint!
    @IBOutlet weak var today10am11amLabel: UILabel!
    @IBOutlet weak var today10am11amButton: UIButton!
    @IBOutlet weak var today10am11amConstraint: NSLayoutConstraint!
    @IBOutlet weak var today11am12pmLabel: UILabel!
    @IBOutlet weak var today11am12pmButton: UIButton!
    @IBOutlet weak var today11am12pmConstraint: NSLayoutConstraint!
    @IBOutlet weak var today12pm1pmLabel: UILabel!
    @IBOutlet weak var today12pm1pmButton: UIButton!
    @IBOutlet weak var today12pm1pmConstraint: NSLayoutConstraint!
    @IBOutlet weak var today1pm2pmLabel: UILabel!
    @IBOutlet weak var today1pm2pmButton: UIButton!
    @IBOutlet weak var today1pm2pmConstraint: NSLayoutConstraint!
    @IBOutlet weak var today2pm3pmLabel: UILabel!
    @IBOutlet weak var today2pm3pmButton: UIButton!
    @IBOutlet weak var today2pm3pmConstraint: NSLayoutConstraint!
    @IBOutlet weak var today3pm4pmLabel: UILabel!
    @IBOutlet weak var today3pm4pmButton: UIButton!
    @IBOutlet weak var today3pm4pmConstraint: NSLayoutConstraint!
    @IBOutlet weak var today4pm5pmLabel: UILabel!
    @IBOutlet weak var today4pm5pmButton: UIButton!
    @IBOutlet weak var today4pm5pmConstraint: NSLayoutConstraint!
    @IBOutlet weak var today4pm5pmOffset: NSLayoutConstraint!
    @IBOutlet weak var tomorrow9am10amLabel: UILabel!
    @IBOutlet weak var tomorrow9am10amButton: UIButton!
    @IBOutlet weak var tomorrow9am10amOffset: NSLayoutConstraint!
    @IBOutlet weak var tomorrow10am11amLabel: UILabel!
    @IBOutlet weak var tomorrow10am11amButton: UIButton!
    @IBOutlet weak var tomorrow11am12pmLabel: UILabel!
    @IBOutlet weak var tomorrow11am12pmButton: UIButton!
    @IBOutlet weak var tomorrow12pm1pmLabel: UILabel!
    @IBOutlet weak var tomorrow12pm1pmButton: UIButton!
    @IBOutlet weak var tomorrow1pm2pmLabel: UILabel!
    @IBOutlet weak var tomorrow1pm2pmButton: UIButton!
    @IBOutlet weak var tomorrow2pm3pmLabel: UILabel!
    @IBOutlet weak var tomorrow2pm3pmButton: UIButton!
    @IBOutlet weak var tomorrow3pm4pmLabel: UILabel!
    @IBOutlet weak var tomorrow3pm4pmButton: UIButton!
    @IBOutlet weak var tomorrow4pm5pmLabel: UILabel!
    @IBOutlet weak var tomorrow4pm5pmButton: UIButton!
    @IBOutlet weak var tomorrow4pm5pmOffset: NSLayoutConstraint!
    var lineIsShown: Bool = false
    var currentTime = [String: Int]()
    var currentDateOffsetSelection: Int = 0
    var currentTimeSelection: Int = 9
    let months: [Int: String] = [
        1: "JAN",
        2: "FEB",
        3: "MAR",
        4: "APR",
        5: "MAY",
        6: "JUN",
        7: "JUL",
        8: "AUG",
        9: "SEP",
        10: "OCT",
        11: "NOV",
        12: "DEC"
    ]

    // Step to reintroduce data collection, if not all present
    var reintroductionStep: Int = 0
    
    var timeSelectionOpen: Bool = false
    var downSwipeGesture: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboard()
        
        // Set status bar color to light
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Round corners
        self.pinTop.layer.cornerRadius = 20
        self.pinTop.clipsToBounds = true
        self.pinIconBackground.layer.cornerRadius = 15
        self.pinIconBackground.clipsToBounds = true
        self.pinShadow.layer.cornerRadius = 3
        self.pinShadow.clipsToBounds = true
        
        // Hide black gas icon and full menu return button
        self.pinIconBlack.alpha = 0
        self.returnButton.hidden = true
        
        // Hide time selection view and time selection view separator line
        self.timeSelectionView.hidden = true
        self.separatorLine.alpha = 0
        self.timeListContainer.delegate = self
        
        // Set order form header z-position
        self.orderFormHeader.layer.zPosition = 20
        
        // Check if there is an open order to track
        let orderStatus = GaskyFoundation.sharedInstance.returnOrderStatus()
        if (orderStatus["id"]! != nil) {
            if (orderStatus["status"]! == "feedback" || orderStatus["status"]! == "in progress") {
                NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderTracker"])
            }
        } else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedOrderStatusUpdate:", name: "orderStatusUpdated", object: nil)
        }
        
        // Check if existing order attempt date is on the back end and assign that data to the current session
        self.orderAddress = GaskyFoundation.sharedInstance.getRequestFormStateLocation()
        self.orderCoords = GaskyFoundation.sharedInstance.getRequestFormStateCoords()
        self.extraDetails = GaskyFoundation.sharedInstance.getRequestFormStateDetails()
        
        let retrievedDateOffset = GaskyFoundation.sharedInstance.getRequestFormStateDate()
        if (retrievedDateOffset != nil) {
            self.currentDateOffsetSelection = retrievedDateOffset!
        }
        
        let retrievedTimeOffset = GaskyFoundation.sharedInstance.getRequestFormStateTime()
        if (retrievedTimeOffset != nil) {
            self.currentTimeSelection = retrievedTimeOffset!
        }
        
        
        // Setup time components
        self.getCurrentTimeComponents()
        NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "getCurrentTimeComponents", userInfo: nil, repeats: true)
        
        // Retrieve current pricing and setup notification for pricing retrieval, in case they're not yet available or are updated
        self.pricing = GaskyFoundation.sharedInstance.returnPricing()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedPricing:", name: "pricingReceived", object: nil)
        
        // Set up pricing
        self.injectPricing()

        // Retrieve current service areas and setup notification for service area retrieval, in case they're not yet available or are updated
        self.serviceAreas = GaskyFoundation.sharedInstance.returnServiceAreas()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedServiceAreas:", name: "serviceAreasReceived", object: nil)
        
        // Set up the selection button styles
        self.outlineButton(self.regularButton, enabled: true)
        self.outlineButton(self.dieselButton, enabled: false)
        
        // Add text field delegates
        self.locationField.delegate = self
        self.detailsField.delegate = self
        
        // Disable scrolling for order form on load
        self.orderFormContainer.scrollEnabled = false
        
        // Add swipe gestures
        let swipeLeftGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeLeftGesture.direction = .Left
        view.addGestureRecognizer(swipeLeftGesture)
        let swipeRightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeRightGesture.direction = .Right
        view.addGestureRecognizer(swipeRightGesture)
        let mapSwipe = UISwipeGestureRecognizer(target: self, action: Selector("cancelSwipe:"))
        mapsView.addGestureRecognizer(mapSwipe)
        self.downSwipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        self.downSwipeGesture.direction = .Down
        view.addGestureRecognizer(self.downSwipeGesture)
        
        // Add keyboard show/hide observers and outside tap close
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeShown:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name:UIKeyboardWillHideNotification, object: nil);
        let tapDismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tapDismissKeyboard)
        
        // Set extended form data, or get information state if data isn't all available
        self.setExtendedFormData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedUserData:", name: "userDataReceived", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.orderFormBack.hidden = true
        self.menuWidth.constant = -(self.menuButton.frame.width + self.menuButtonOffset.constant * 2)
        self.menuOffset.constant = -self.menu.frame.width
        self.orderFormHeight.constant = self.shortFormMeasure.frame.height
        self.finePrintOffset.constant = -8
        //self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.orderFormBackOffset.constant = -self.orderFormBack.frame.height
        self.orderFormBack.hidden = false
        self.menuOffset.constant = -self.menu.frame.width
        self.orderFormHeight.constant = self.shortFormMeasure.frame.height
        self.view.layoutIfNeeded()
        self.setupMaps()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "orderStatusUpdated", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        if (self.mapView != nil) {
            //self.mapView.removeObserver(self, forKeyPath: "myLocation", context: nil)
        }
    }
    
    @IBAction func menuButtonTap(sender: AnyObject) {
        if (self.menuOpen == false) {
            openMenu()
        } else {
            closeMenu()
        }
    }
    
    @IBAction func mneuReturnButtonTap(sender: AnyObject) {
        closeMenu()
    }
    
    @IBAction func menuRequestTap(sender: AnyObject) {
        if (self.menuOpen == true) {
            closeMenu()
        }
    }
    
    @IBAction func menuAccountTap(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedAccount"])
    }
    
    @IBAction func menuPaymentTap(sender: AnyObject) {
        GaskyFoundation.sharedInstance.setPaymentViewOverride(2)
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedInfoStepThree"])
    }
    
    @IBAction func menuCarTap(sender: AnyObject) {
        GaskyFoundation.sharedInstance.setVehicleViewOverride(2)
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedInfoStepTwo"])
    }
    
    @IBAction func menuHelpTap(sender: AnyObject) {
        let contactEmail = "support@gasky.co"
        let url = NSURL(string: "mailto:\(contactEmail)")
        UIApplication.sharedApplication().openURL(url!)
        //closeMenu()
    }
    
    @IBAction func menuPromotionTap(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedPromotion"])
    }
    
    @IBAction func menuAboutTap(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedAbout"])
    }
    
    @IBAction func regularButtonTap(sender: AnyObject) {
        // Silent for now, regular is the only option
    }
    
    @IBAction func dieselButtonTap(sender: AnyObject) {
        let alertController = UIAlertController(title: "Coming Soon!", message:
            "", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func locationLabelTap(sender: AnyObject) {
        self.locationField.becomeFirstResponder()
    }
    
    @IBAction func timeSelectionTap(sender:AnyObject) {
        closeMenu()
        dismissKeyboard()
        self.openTimeSelectionMenu()
    }
    
    @IBAction func makeOrderCloseTap(sender: AnyObject) {
        transitionToMakeOrder()
    }
    
    @IBAction func promoButtonTap(sender: AnyObject) {
        let alertController = UIAlertController(title: "Enter Promo Code", message: "", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "Apply", style: .Default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                GaskyFoundation.sharedInstance.updatePromo(field.text!) { (result: NSInteger) in
                    if (result == 200) {
                        let alertController = UIAlertController(title: "Your promo code has been applied successfully", message:
                            "", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        let promoData = GaskyFoundation.sharedInstance.getPromoInfo()
                        if (promoData["code"]! != nil) {
                            var discountString = ""
                            
                            if (promoData["dollarAmountOff"]! != nil) {
                                discountString = "$" + String(promoData["dollarAmountOff"]!!) + " Off"
                            }
                            
                            if (promoData["percentOff"]! != nil) {
                                discountString = String(promoData["percentOff"]!!) + "% Off"
                            }
                            
                            self.promoButton.userInteractionEnabled = false
                            self.promoOnFile.text = String(promoData["code"]!!) + " / " + discountString
                            self.promoOnFile.textColor = UIColor.whiteColor()
                        }
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
                }
            } else {
                // Nothing
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Enter promo code"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        /*let alertController = UIAlertController(title: "Are you sure you want to cancel the request?", message:
            "There will be a $5 delivery fee if the request is cancelled while Gasky is on its way", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Never Mind", style: UIAlertActionStyle.Default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { action -> Void in
            GaskyFoundation.sharedInstance.cancelOpenOrder()
        }))*/
    }
    
    @IBAction func orderQuestionMarkTap(sender: AnyObject) {
        let alertController = UIAlertController(title: "Total Cost", message:
            "We will send you the total cost with the photo of gas meter upon completion of delivery", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func closeTimeSelectionTap(sender: AnyObject) {
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func today910tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 0
        self.currentTimeSelection = 9
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func today1011tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 0
        self.currentTimeSelection = 10
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func today1112tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 0
        self.currentTimeSelection = 11
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func today121tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 0
        self.currentTimeSelection = 12
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func today12tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 0
        self.currentTimeSelection = 13
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func today23tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 0
        self.currentTimeSelection = 14
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func today34tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 0
        self.currentTimeSelection = 15
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func today45tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 0
        self.currentTimeSelection = 16
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func tomorrow910tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 1
        self.currentTimeSelection = 9
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func tomorrow1011tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 1
        self.currentTimeSelection = 10
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func tomorrow1112tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 1
        self.currentTimeSelection = 11
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func tomorrow121tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 1
        self.currentTimeSelection = 12
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func tomorrow12tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 1
        self.currentTimeSelection = 13
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func tomorrow23tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 1
        self.currentTimeSelection = 14
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func tomorrow34tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 1
        self.currentTimeSelection = 15
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func tomorrow45tap(sender: AnyObject) {
        self.currentDateOffsetSelection = 1
        self.currentTimeSelection = 16
        self.updateTimeFormDisplay()
        self.closeTimeSelectionMenu()
    }
    
    @IBAction func confirmRequest(sender: AnyObject) {
        self.submitOrder()
    }
    
    @IBAction func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if (self.mapView != nil) {
            if (recognizer.state == .Began) {
                self.pinchReference = recognizer.scale
            }
            
            if (recognizer.state == .Changed) {
                self.liveTrackLocation = false
                let change = (recognizer.scale - self.pinchReference) * 2
                self.pinchReference = recognizer.scale
                let updatedZoom = GMSCameraUpdate.zoomBy(Float(change))
                self.mapView!.moveCamera(updatedZoom)
            }
        }
    }
    
    @IBAction func handlePinTap(sender: AnyObject) {
        if (self.canTap == true) {
            self.transitionToSummary()
        }
    }
    
    @IBAction func focusMyLocation(sender: AnyObject) {
        if (self.canTap == true && self.liveTrackLocation == false && self.didFindMyLocation == true) {
            self.liveTrackLocation = true
            self.makeRequestAtLocation(mapView!, coordinate: self.myCurrentLocation!, updateAddress: true)
        }
    }
    
    func keyboardWillBeShown(notification: NSNotification) {
        if (self.menuOpen == true) {
            closeMenu()
        }
        
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.requestOffsetBottom.constant = keyboardFrame.size.height
        
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        self.requestOffsetBottom.constant = 0
        
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .Left && self.menuOpen == true) {
            self.closeMenu()
        }
        
        if (sender.direction == .Right && self.menuOpen == false) {
            self.openMenu()
        }
        
        if (sender.direction == .Down && self.timeSelectionOpen == true) {
            self.closeTimeSelectionMenu()
        }
        
        if (sender.direction == .Down && self.canTap == false) {
            self.transitionToMakeOrder()
        }
    }
    
    func cancelSwipe(sender: UISwipeGestureRecognizer) {
       
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView == self.timeListContainer) {
            let scrollOffset = scrollView.contentOffset.y
            
            if (scrollOffset > 30) {
                if (self.lineIsShown == false) {
                    UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.separatorLine.alpha = 1
                    }, completion: nil)
                    
                    lineIsShown = true
                }
            } else {
                if (self.lineIsShown == true) {
                    UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.separatorLine.alpha = 0
                    }, completion: nil)
                    
                    lineIsShown = false
                }
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        GaskyFoundation.setFieldColor(textField, state: "normal")
        
        if (textField.text == "DETAILS (Apt #, Floor #, Parking #)") {
            textField.text = ""
            textField.textAlignment = .Right
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (self.locationField.text! == "" && self.orderAddress != nil) {
            self.locationField.text = self.orderAddress
        }
        self.digestAddressEntry()
        if (self.detailsField.text == "") {
            self.detailsField.text = "DETAILS (Apt #, Floor #, Parking #)"
            GaskyFoundation.setFieldColor(self.detailsField, state: "neutral")
            textField.textAlignment = .Left
        }
        if (self.detailsField.text != "DETAILS (Apt #, Floor #, Parking #)") {
            self.extraDetails = self.detailsField.text!
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (self.detailsField.text == "") {
            self.detailsField.text = "DETAILS (Apt #, Floor #, Parking #)"
            GaskyFoundation.setFieldColor(self.detailsField, state: "neutral")
            textField.textAlignment = .Left
        }
        
        if (self.detailsField.text != "DETAILS (Apt #, Floor #, Parking #)") {
            self.extraDetails = self.detailsField.text!
        }
        textField.resignFirstResponder()
        return true
    }
    
    func openMenu() {
        if (self.canTap == true) {
            self.dismissKeyboard()
            self.returnButton.hidden = false
            self.menuOffset.constant = 0
            self.requestOfset.constant = self.menu.frame.width
            self.menuOpen = true
            
            UIView.animateWithDuration(0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func getCurrentTimeComponents() {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Month, .Day, .Hour, .Minute], fromDate: date)
        self.currentTime["month"] = components.month
        self.currentTime["day"] = components.day
        self.currentTime["hour"] = components.hour
        self.currentTime["minute"] = components.minute
        let tomorrow = calendar.dateByAddingUnit(.Day, value: 1, toDate: NSDate(), options: [])
        let tomorrowComponents = calendar.components([.Month, .Day], fromDate: tomorrow!)
        self.currentTime["tomorrowMonth"] = tomorrowComponents.month
        self.currentTime["tomorrowDay"] = tomorrowComponents.day

        self.updateTimeFormDisplay()
    }
    
    func receivedServiceAreas(notification: NSNotification) {
        self.serviceAreas = GaskyFoundation.sharedInstance.returnServiceAreas()
        
        if (self.didLayoutGoogle == true) {
            self.addServiceAreasToMap()
        }
    }
    
    func receivedPricing(notification: NSNotification) {
        self.pricing = GaskyFoundation.sharedInstance.returnPricing()
        self.injectPricing()
    }
    
    func receivedUserData(notification: NSNotification) {
        self.setExtendedFormData()
    }
    
    func receivedOrderStatusUpdate(notification: NSNotification) {
        let orderStatus = GaskyFoundation.sharedInstance.returnOrderStatus()
        if (orderStatus["id"]! != nil) {
            if (orderStatus["status"]! == "feedback" || orderStatus["status"]! == "in progress") {
                NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderTracker"])
            }
        }
    }
    
    func addServiceAreasToMap() {
        self.serviceAreas = GaskyFoundation.sharedInstance.returnServiceAreas()
        self.mapView!.clear()
        
        for serviceArea in serviceAreas {
            let area = GMSMutablePath()
            
            for position in serviceArea {
                area.addCoordinate(CLLocationCoordinate2D(latitude: position[0], longitude: position[1]))
            }
            
            let polygon = GMSPolygon(path: area)
            polygon.fillColor = UIColor(red: 70/255, green: 189/255, blue: 255/255, alpha: 0.1);
            polygon.strokeColor = UIColor(red: 70/255, green: 189/255, blue: 255/255, alpha: 0.7);
            polygon.strokeWidth = 1
            polygon.map = self.mapView
            self.serviceAreaPaths.append(area)
        }
        
        self.locationManager.startUpdatingLocation()
    }
    
    func closeMenu() {
        self.returnButton.hidden = true
        self.menuOffset.constant = -self.menu.frame.width
        self.requestOfset.constant = 0
        self.menuOpen = false
        
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setupMaps() {
        self.didLayoutGoogle = true
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        var updateAddress: Bool = true
        var camera = GMSCameraPosition.cameraWithTarget(CLLocationCoordinate2DMake(33.7490496549016, -84.3881341069937), zoom: 17)
        
        if (self.orderCoords != nil) {
            self.liveTrackLocation = false
            camera = GMSCameraPosition.cameraWithTarget(self.orderCoords!, zoom: 17)
            self.locationField.text = self.orderAddress
            if (self.extraDetails != "") {
                GaskyFoundation.setFieldColor(self.detailsField, state: "normal")
                self.detailsField.text = self.extraDetails
                self.detailsField.textAlignment = .Right
            }
            updateAddress = false
        }
        
        self.mapView = GMSMapView.mapWithFrame(CGRectMake(0, 0, self.mapsView.frame.width, self.mapsView.frame.height), camera: camera)
        self.mapView?.mapType = kGMSTypeHybrid
        self.makeRequestAtLocation(mapView!, coordinate: camera.target, updateAddress: updateAddress)
        
        self.mapsView.addSubview(self.mapView!)
        //self.mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        self.mapView!.delegate = self
        
        self.mapView!.settings.consumesGesturesInView = false
        self.mapView!.settings.rotateGestures = false
        self.mapView!.settings.tiltGestures = false
        self.mapView!.settings.zoomGestures = false
        self.mapView!.settings.allowScrollGesturesDuringRotateOrZoom = false
        
        if (self.serviceAreas.count > 0) {
            self.addServiceAreasToMap()
        }
        
        self.mapPin.layer.zPosition = 10
        self.mapPinButton.layer.zPosition = 11
        self.mapArrow.layer.zPosition = 12
        self.mapArrowButton.layer.zPosition = 13
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (manager.location?.coordinate != nil) {
            self.myCurrentLocation = locations[0].coordinate
            
            if (self.liveTrackLocation == true && self.orderCoords?.longitude != self.myCurrentLocation?.longitude && self.orderCoords?.latitude != self.myCurrentLocation?.latitude) {
                self.focusCameraOnMap(mapView!, coordinate: locations[0].coordinate, zoom: 17)
                self.makeRequestAtLocation(mapView!, coordinate: locations[0].coordinate, updateAddress: true)
            }
            
            self.didFindMyLocation = true
        }
    }
    
    // Tap at target location
    /*func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if (self.canTap == true) {
            self.makeRequestAtLocation(mapView, coordinate: coordinate, updateAddress: true)
        }
    }*/
    
    /*func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        self.transitionToSummary()
        return true
    }*/
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        if (position.target.latitude != 0 && position.target.longitude != 0) {
            self.makeRequestAtLocation(mapView, coordinate: position.target, updateAddress: true)
        }
    }
    
    func mapView(mapView: GMSMapView, willMove gesture: Bool) {
        if (gesture == true) {
            self.liveTrackLocation = false
        }
    }
    
    func makeRequestAtLocation(mapView: GMSMapView, coordinate: CLLocationCoordinate2D, updateAddress: Bool, outOfNetworkNotify: Bool = false) {
        self.orderCoords = coordinate
        
        if (updateAddress == true) {
            self.convertCoordinateToAddress(coordinate)
        } else {
            self.orderAddress = self.locationField.text
        }
        
        self.moveCameraOnMap(mapView, coordinate: coordinate)
        self.orderCoords = coordinate
        
        //var validLocation: Bool = false
        
        /*for serviceArea in self.serviceAreaPaths {
            if (GMSGeometryContainsLocation(coordinate, serviceArea, false) == true) {
                //self.popRequestLocationOnMap(mapView, coordinate: coordinate)
                if (updateAddress == true) {
                    self.convertCoordinateToAddress(coordinate)
                } else {
                    self.orderAddress = self.locationField.text
                }
                self.moveCameraOnMap(mapView, coordinate: coordinate)
                self.locationManager.stopUpdatingLocation()
                self.orderCoords = coordinate
                validLocation = true
                break
            }
        }*/
        
        /*if (outOfNetworkNotify == true && validLocation == false) {
            let alertController = UIAlertController(title: "Outside of Service Area", message:
                "Delivery to your requested address is not available.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
            self.locationField.text = self.orderAddress
        }*/
    }
    
    func focusCameraOnMap(mapView: GMSMapView, coordinate: CLLocationCoordinate2D, zoom: Float) {
        mapView.camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: zoom)
    }
    
    func moveCameraOnMap(mapView: GMSMapView, coordinate: CLLocationCoordinate2D) {
        mapView.animateToLocation(coordinate)
    }
    
    /*func popRequestLocationOnMap(mapView: GMSMapView, coordinate: CLLocationCoordinate2D) {
        if (self.mapMarker != nil) {
            self.mapMarker!.map = nil
        }
        
        self.mapMarker = GMSMarker(position: coordinate)
        self.mapMarker!.appearAnimation = GoogleMaps.kGMSMarkerAnimationPop
        self.mapMarker!.title = "Request Delivery"
        self.mapMarker!.icon = UIImage(named:"MapMarker")
        self.mapMarker!.map = mapView
    }*/
    
    /*func popOrderPositionPointOnMap(mapView: GMSMapView, coordinate: CLLocationCoordinate2D) {
        if (self.mapMarker != nil) {
            self.mapMarker!.map = nil
        }
        
        self.mapMarker = GMSMarker(position: coordinate)
        self.mapMarker!.appearAnimation = GoogleMaps.kGMSMarkerAnimationPop
        self.mapMarker!.title = "Delivery Location"
        self.mapMarker!.icon = UIImage(named:"OrderLocation")
        self.mapMarker!.map = mapView
    }*/
    
    func convertCoordinateToAddress(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            if let address = response?.firstResult() {
                self.locationField.text = address.thoroughfare
                self.orderAddress = address.thoroughfare
            }
        }
    }
    
    func digestAddressEntry() {
        if (self.orderAddress != self.locationField.text) {
            self.liveTrackLocation = false
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(self.locationField.text!, completionHandler: { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if (placemarks != nil && placemarks!.count > 0) {
                    var compareCoords: CLLocation
                    var closestLocationIndex: Int? = nil
                    var closestLocationDistance: Double? = nil
                    
                    if (self.orderCoords != nil) {
                        compareCoords = CLLocation(latitude: (self.orderCoords?.latitude)!, longitude: (self.orderCoords?.longitude)!)
                    } else if (self.locationManager.location != nil) {
                        compareCoords = CLLocation(latitude: self.locationManager.location!.coordinate.latitude, longitude: self.locationManager.location!.coordinate.longitude)
                    } else {
                        compareCoords = CLLocation(latitude: 33.744999, longitude: -84.390025)
                    }
                    
                    for (var index = 0; index < placemarks!.count; ++index) {
                        let thisDistance: Double? = placemarks![index].location?.distanceFromLocation(compareCoords)
                        
                        if (thisDistance != nil) {
                            if (index == 0 || closestLocationIndex == nil) {
                                closestLocationIndex = index
                                closestLocationDistance = thisDistance
                            } else {
                                if (thisDistance < closestLocationDistance) {
                                    closestLocationIndex = index
                                    closestLocationDistance = thisDistance
                                }
                            }
                        }
                    }
                    
                    if (closestLocationIndex != nil) {
                        if let finalCoords = placemarks![closestLocationIndex!].location?.coordinate {
                            self.makeRequestAtLocation(self.mapView!, coordinate: finalCoords, updateAddress: false, outOfNetworkNotify: true)
                        }
                    }
                }
            })
        }
    }
    
    func transitionToSummary() {
        var validLocation: Bool = false
        
        for serviceArea in self.serviceAreaPaths {
            if (GMSGeometryContainsLocation(self.orderCoords!, serviceArea, false) == true) {
                validLocation = true
                break
            }
        }
        
        if (validLocation == false) {
            let alertController = UIAlertController(title: "Outside of Service Area", message:
                "Delivery to your requested address is not available.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            let promoData = GaskyFoundation.sharedInstance.getPromoInfo()
            
            if (promoData["code"]! != nil) {
                GaskyFoundation.sharedInstance.checkPromoValidity({ (valid: Bool) in
                    if (valid == false) {
                        let alertController = UIAlertController(title: "Your promo code has expired", message:
                            "", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        self.promoButton.userInteractionEnabled = true
                        self.promoOnFile.text = "Enter Promo Code"
                        self.promoOnFile.textColor = GaskyFoundation.neutralColor
                    }
                })
            }
            
            self.canTap = false
            if (self.reintroductionStep > 0) {
                GaskyFoundation.sharedInstance.setRequestFormState(self.orderCoords, location: self.orderAddress, details: self.extraDetails, time: self.currentTimeSelection, date: self.currentDateOffsetSelection)
                
                if (self.reintroductionStep == 1) {
                    GaskyFoundation.sharedInstance.setPersonalInfoViewOverride(1)
                    GaskyFoundation.sharedInstance.setVehicleViewOverride(1)
                    GaskyFoundation.sharedInstance.setPaymentViewOverride(1)
                    NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedInfoStepOne"])
                } else if (self.reintroductionStep == 2) {
                    GaskyFoundation.sharedInstance.setVehicleViewOverride(1)
                    GaskyFoundation.sharedInstance.setVehicleInfoStep(1)
                    GaskyFoundation.sharedInstance.setPaymentViewOverride(1)
                    GaskyFoundation.sharedInstance.setPaymentMethodStep(2)
                    NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedInfoStepTwo"])
                } else {
                    GaskyFoundation.sharedInstance.setPaymentViewOverride(1)
                    GaskyFoundation.sharedInstance.setPaymentMethodStep(1)
                    NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedInfoStepThree"])
                }
            } else {
                // Animate request gasky pin
                UIView.animateWithDuration(0.16, animations: {
                    self.pinIconBlack.alpha = 1
                    self.pinIconBlue.alpha = 0
                    self.pinLabel.alpha = 0
                    self.mapArrow.alpha = 0
                    }, completion: {
                        (value: Bool) in
                        self.pinTopWidth.constant = 40
                        UIView.animateWithDuration(0.14) {
                            self.view.layoutIfNeeded()
                        }
                })
                
                self.orderFormOffset.constant = -self.orderFormHeader.frame.height
                self.orderFormBackOffset.constant = 20
                self.mapTopOffset.constant = self.orderFormHeader.frame.height - self.orderFormBack.frame.height
                
                // Disable fields
                self.regularButton.userInteractionEnabled = false
                self.dieselButton.userInteractionEnabled = false
                self.locationButton.userInteractionEnabled = false
                self.locationField.userInteractionEnabled = false
                self.detailsField.userInteractionEnabled = false
                self.deliveryTimeButton.userInteractionEnabled = false
                
                if (self.orderFormContents.frame.height < self.view.frame.height * 0.65) {
                    self.orderFormHeight.constant = self.orderFormContents.frame.height
                } else {
                    self.orderFormHeight.constant = self.view.frame.height * 0.657
                }
                
                UIView.animateWithDuration(0.25) {
                    self.view.layoutIfNeeded()
                    self.mapView!.frame = CGRectMake(0, 0, self.mapsView.frame.width, self.mapsView.frame.height)
                }
                
                //let adjustCoords = CLLocationCoordinate2D(latitude: self.orderCoords!.latitude + 0.00025, longitude: self.orderCoords!.longitude)
                //self.focusCameraOnMap(self.mapView!, coordinate: adjustCoords, zoom: 17)
                
                //self.popOrderPositionPointOnMap(self.mapView, coordinate: self.orderCoords!)
                self.orderFormContainer.scrollEnabled = true
                self.mapsView.userInteractionEnabled = false
            }
        }
    }
    
    func transitionToMakeOrder() {
        self.canTap = true
        
        // Animate request gasky pin
        self.pinTopWidth.constant = 153
        UIView.animateWithDuration(0.14, animations: {
            self.view.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
                UIView.animateWithDuration(0.16) {
                    self.pinIconBlack.alpha = 0
                    self.pinIconBlue.alpha = 1
                    self.pinLabel.alpha = 1
                    self.mapArrow.alpha = 1
                }
        })
        
        self.orderFormOffset.constant = 0
        self.orderFormBackOffset.constant = -self.orderFormHeader.frame.height
        self.mapTopOffset.constant = 0
        self.orderFormHeight.constant = self.shortFormMeasure.frame.height
        
        // Enable fields
        self.regularButton.userInteractionEnabled = true
        self.dieselButton.userInteractionEnabled = true
        self.locationButton.userInteractionEnabled = true
        self.locationField.userInteractionEnabled = true
        self.detailsField.userInteractionEnabled = true
        self.deliveryTimeButton.userInteractionEnabled = true
        
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
            self.mapView!.frame = CGRectMake(0, 0, self.mapsView.frame.width, self.mapsView.frame.height)
            self.orderFormContainer.contentOffset = CGPoint(x: 0, y: 0)
        }
        
        //let adjustCoords = CLLocationCoordinate2D(latitude: self.orderCoords!.latitude, longitude: self.orderCoords!.longitude)
        //self.focusCameraOnMap(self.mapView!, coordinate: adjustCoords, zoom: 17)
        
        //self.popRequestLocationOnMap(self.mapView, coordinate: self.orderCoords!)
        self.orderFormContainer.scrollEnabled = false
        self.mapsView.userInteractionEnabled = true
    }
    
    func outlineButton(button: UIButton, enabled: Bool) {
        if (enabled == true) {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.whiteColor().CGColor
        } else {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: 135/255, green: 135/255, blue: 135/255, alpha: 1).CGColor;
        }
    }
    
    func injectPricing() {
        if (self.pricing["regular"]! != nil) {
            self.regularLabel.text = String(format: "REGULAR / $%.2f", self.pricing["regular"]!!)
        }
        
        if (self.pricing["regular"]! != nil && self.pricing["delivery"]! != nil) {
            self.finePrint.text = String(format: "$%.2f/gal (min. $25 purchase) + $%.2f service fee", self.pricing["regular"]!!, self.pricing["delivery"]!!)
        }
    }
    
    func setExtendedFormData() {
        if (GaskyFoundation.sharedInstance.doesHavePersonalInfo() == true) {
            if (GaskyFoundation.sharedInstance.doesHaveVehicleInfo() == true) {
                if (GaskyFoundation.sharedInstance.doesHavePaymentMethodInfo() == true) {
                    self.reintroductionStep = 0
                    
                    let paymentInfo: NSArray = GaskyFoundation.sharedInstance.getPaymentMethodInfo()
                    let vehicleInfo: [String:String?] = GaskyFoundation.sharedInstance.getVehicleInfo()
                    let promoData = GaskyFoundation.sharedInstance.getPromoInfo()
                    
                    for paymentData in paymentInfo {
                        if let defaultMethod = paymentData["default"].boolValue as? Bool, let digits = paymentData["digits"] as? String,
                            let expired = paymentData["expired"].boolValue as? Bool, let idString = paymentData["id"] as? String,
                            let type = paymentData["type"] as? String {
                                if (defaultMethod == true) {
                                    self.paymentOnFile.text = type + " " + digits
                                    break
                                }
                        }
                    }
                    
                    self.carOnFile.text = vehicleInfo["make"]!! + " " + vehicleInfo["model"]!! + " / " + vehicleInfo["color"]!!
                    
                    if (promoData["code"]! != nil) {
                        var discountString = ""
                        
                        if (promoData["dollarAmountOff"]! != nil) {
                            discountString = "$" + String(promoData["dollarAmountOff"]!!) + " Off"
                        }
                        
                        if (promoData["percentOff"]! != nil) {
                            discountString = String(promoData["percentOff"]!!) + "% Off"
                        }
                        
                        self.promoButton.userInteractionEnabled = false
                        self.promoOnFile.text = String(promoData["code"]!!) + " / " + discountString
                        self.promoOnFile.textColor = UIColor.whiteColor()
                    }
                } else {
                    self.reintroductionStep = 3
                }
            } else {
                self.reintroductionStep = 2
            }
        } else {
            self.reintroductionStep = 1
        }
    }
    
    func openTimeSelectionMenu() {
        self.timeSelectionOpen = true
        self.timeSelectionOffset.constant = -self.view.frame.height
        self.timeSelectionView.hidden = false
        self.view.layoutIfNeeded()
        
        self.timeSelectionOffset.constant = 0
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func closeTimeSelectionMenu() {
        self.timeSelectionOpen = false
        self.timeSelectionOffset.constant = -self.view.frame.height
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func updateTimeFormDisplay() {
        self.todayLabel.text = "TODAY / " + months[self.currentTime["month"]!]! + " " + String(self.currentTime["day"]!)
        self.tomorrowLabel.text = "TOMORROW / " + months[self.currentTime["tomorrowMonth"]!]! + " " + String(self.currentTime["tomorrowDay"]!)
        
        self.today10am11amConstraint.constant = 0
        self.today11am12pmConstraint.constant = 0
        self.today12pm1pmConstraint.constant = 0
        self.today1pm2pmConstraint.constant = 0
        self.today2pm3pmConstraint.constant = 0
        self.today3pm4pmConstraint.constant = 0
        self.today4pm5pmConstraint.constant = 0
        
        let singleHeight: CGFloat = 40
        
        if (self.currentTime["hour"] >= 9 || (self.currentTime["hour"] == 8 && self.currentTime["minute"] > 30)) {
            self.today9am10amLabel.hidden = true
            self.today9am10amButton.hidden = true
            self.today10am11amConstraint.constant = -singleHeight
            
            if (self.currentDateOffsetSelection == 0 && self.currentTimeSelection == 9) {
                self.currentTimeSelection = 10
            }
        }
        
        if (self.currentTime["hour"] >= 10 || (self.currentTime["hour"] == 9 && self.currentTime["minute"] > 30)) {
            self.today10am11amLabel.hidden = true
            self.today10am11amButton.hidden = true
            self.today11am12pmConstraint.constant = -singleHeight
            
            if (self.currentDateOffsetSelection == 0 && self.currentTimeSelection == 10) {
                self.currentTimeSelection = 11
            }
        }

        if (self.currentTime["hour"] >= 11 || (self.currentTime["hour"] == 10 && self.currentTime["minute"] > 30)) {
            self.today11am12pmLabel.hidden = true
            self.today11am12pmButton.hidden = true
            self.today12pm1pmConstraint.constant = -singleHeight
            
            if (self.currentDateOffsetSelection == 0 && self.currentTimeSelection == 11) {
                self.currentTimeSelection = 12
            }
        }
        
        if (self.currentTime["hour"] >= 12 || (self.currentTime["hour"] == 11 && self.currentTime["minute"] > 30)) {
            self.today12pm1pmLabel.hidden = true
            self.today12pm1pmButton.hidden = true
            self.today1pm2pmConstraint.constant = -singleHeight
            
            if (self.currentDateOffsetSelection == 0 && self.currentTimeSelection == 12) {
                self.currentTimeSelection = 13
            }
        }
        
        if (self.currentTime["hour"] >= 13 || (self.currentTime["hour"] == 12 && self.currentTime["minute"] > 30)) {
            self.today1pm2pmLabel.hidden = true
            self.today1pm2pmButton.hidden = true
            self.today2pm3pmConstraint.constant = -singleHeight
            
            if (self.currentDateOffsetSelection == 0 && self.currentTimeSelection == 13) {
                self.currentTimeSelection = 14
            }
        }
        
        if (self.currentTime["hour"] >= 14 || (self.currentTime["hour"] == 13 && self.currentTime["minute"] > 30)) {
            self.today2pm3pmLabel.hidden = true
            self.today2pm3pmButton.hidden = true
            self.today3pm4pmConstraint.constant = -singleHeight
            
            if (self.currentDateOffsetSelection == 0 && self.currentTimeSelection == 14) {
                self.currentTimeSelection = 15
            }
        }
        
        if (self.currentTime["hour"] >= 15 || (self.currentTime["hour"] == 14 && self.currentTime["minute"] > 30)) {
            self.today3pm4pmLabel.hidden = true
            self.today3pm4pmButton.hidden = true
            self.today4pm5pmConstraint.constant = -singleHeight
            
            if (self.currentDateOffsetSelection == 0 && self.currentTimeSelection == 15) {
                self.currentTimeSelection = 16
            }
        }
        
        if (self.currentTime["hour"] >= 16 || (self.currentTime["hour"] == 15 && self.currentTime["minute"] > 30)) {
            self.today4pm5pmLabel.hidden = true
            self.today4pm5pmButton.hidden = true
            self.today4pm5pmConstraint.constant = -singleHeight * 2
            
            if (self.currentDateOffsetSelection == 0) {
                self.currentDateOffsetSelection = 1
                self.currentTimeSelection = 9
            }
        }
        
        self.updateSelectedTime()
    }
    
    func updateSelectedTime() {
        self.today9am10amButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.today10am11amButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.today11am12pmButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.today12pm1pmButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.today1pm2pmButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.today2pm3pmButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.today3pm4pmButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.today4pm5pmButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.tomorrow9am10amButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.tomorrow10am11amButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.tomorrow11am12pmButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.tomorrow12pm1pmButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.tomorrow1pm2pmButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.tomorrow2pm3pmButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.tomorrow3pm4pmButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.tomorrow4pm5pmButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        if (self.currentDateOffsetSelection == 0) {
            if (self.currentTimeSelection == 9) {
                self.deliveryTimeSelected.text = "Today 9AM-10AM"
                self.today9am10amButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
            
            if (self.currentTimeSelection == 10) {
                self.deliveryTimeSelected.text = "Today 10AM-11AM"
                self.today10am11amButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
            
            if (self.currentTimeSelection == 11) {
                self.deliveryTimeSelected.text = "Today 11AM-12PM"
                self.today11am12pmButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
            
            if (self.currentTimeSelection == 12) {
                self.deliveryTimeSelected.text = "Today 12PM-1PM"
                self.today12pm1pmButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
            
            if (self.currentTimeSelection == 13) {
                self.deliveryTimeSelected.text = "Today 1PM-2PM"
                self.today1pm2pmButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
            
            if (self.currentTimeSelection == 14) {
                self.deliveryTimeSelected.text = "Today 2PM-3PM"
                self.today2pm3pmButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
            
            if (self.currentTimeSelection == 15) {
                self.deliveryTimeSelected.text = "Today 3PM-4PM"
                self.today3pm4pmButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
            
            if (self.currentTimeSelection == 16) {
                self.deliveryTimeSelected.text = "Today 4PM-5PM"
                self.today4pm5pmButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
        }
        
        if (self.currentDateOffsetSelection == 1) {
            if (self.currentTimeSelection == 9) {
                self.deliveryTimeSelected.text = "Tomorrow 9AM-10AM"
                self.tomorrow9am10amButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
            
            if (self.currentTimeSelection == 10) {
                self.deliveryTimeSelected.text = "Tomorrow 10AM-11AM"
                self.tomorrow10am11amButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
            
            if (self.currentTimeSelection == 11) {
                self.deliveryTimeSelected.text = "Tomorrow 11AM-12PM"
                self.tomorrow11am12pmButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
            
            if (self.currentTimeSelection == 12) {
                self.deliveryTimeSelected.text = "Tomorrow 12PM-1PM"
                self.tomorrow12pm1pmButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
            
            if (self.currentTimeSelection == 13) {
                self.deliveryTimeSelected.text = "Tomorrow 1PM-2PM"
                self.tomorrow1pm2pmButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
            
            if (self.currentTimeSelection == 14) {
                self.deliveryTimeSelected.text = "Tomorrow 2PM-3PM"
                self.tomorrow2pm3pmButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
            
            if (self.currentTimeSelection == 15) {
                self.deliveryTimeSelected.text = "Tomorrow 3PM-4PM"
                self.tomorrow3pm4pmButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
            
            if (self.currentTimeSelection == 16) {
                self.deliveryTimeSelected.text = "Tomorrow 4PM-5PM"
                self.tomorrow4pm5pmButton.backgroundColor = GaskyFoundation.buttonEnabled
            }
        }
    }
    
    func submitOrder() {
        self.timeSelectionView.hidden = true
        
        if (self.submittingInfo == false) {
            self.submittingInfo = true
            
            GaskyFoundation.sharedInstance.submitNewOrder("regular", location: self.orderAddress!, latitude: (self.orderCoords?.latitude)!, longitude: (self.orderCoords?.longitude)!, details: self.extraDetails, day: self.currentDateOffsetSelection, time: self.currentTimeSelection)  { (status: Int, error: String) in
                if (status == 200) {
                    NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderThankYou"])
                } else {
                    let alertController = UIAlertController(title: "Error", message:
                        error, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    self.submittingInfo = false
                }
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
