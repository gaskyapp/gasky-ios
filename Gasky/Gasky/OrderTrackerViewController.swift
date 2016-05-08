//
//  OrderTrackerViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 3/7/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit
import GoogleMaps

class OrderTrackerViewController: UIViewController, GMSMapViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
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
    var mapView: GMSMapView!
    var mapMarker: GMSMarker? = nil
    var didLayoutGoogle: Bool = false
    
    // Order Status Visuals
    @IBOutlet weak var trackingOffset: NSLayoutConstraint!
    @IBOutlet weak var orderStatusView: UIView!
    @IBOutlet weak var proportionalHeight: NSLayoutConstraint!
    @IBOutlet weak var receivedIcon: UIView!
    @IBOutlet weak var receivedOff: UIImageView!
    @IBOutlet weak var receivedOn: UIImageView!
    @IBOutlet weak var receivedLabelOffset: NSLayoutConstraint!
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var receivedTimeLabel: UILabel!
    @IBOutlet weak var deliveringIcon: UIView!
    @IBOutlet weak var deliveringOff: UIImageView!
    @IBOutlet weak var deliveringOn: UIImageView!
    @IBOutlet weak var deliveringLabelOffset: NSLayoutConstraint!
    @IBOutlet weak var deliveringLabel: UILabel!
    @IBOutlet weak var deliveringTimeLabel: UILabel!
    @IBOutlet weak var deliveredIcon: UIView!
    @IBOutlet weak var deliveredOff: UIImageView!
    @IBOutlet weak var deliveredOn: UIImageView!
    @IBOutlet weak var deliveredLabelOffset: NSLayoutConstraint!
    @IBOutlet weak var deliveredLabel: UILabel!
    @IBOutlet weak var deliveredTimeLabel: UILabel!
    @IBOutlet weak var paw1: UIImageView!
    @IBOutlet weak var paw2: UIImageView!
    @IBOutlet weak var paw3: UIImageView!
    @IBOutlet weak var paw4: UIImageView!
    @IBOutlet weak var paw5: UIImageView!
    @IBOutlet weak var paw6: UIImageView!
    
    // Order Information
    var receivedDisplayed = false
    var deliveringDisplayed = false
    var deliveredDisplayed = false
    var orderStatus = [String:String?]()
    var timer: NSTimer? = nil
    var footerButtonsEnabled = true
    
    // Bottom Options
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var paymentIcon: UIImageView!
    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet weak var cancelIcon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set status bar color to light
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Hide return button
        self.returnButton.hidden = true
        
        // Set initial icon states
        self.receivedIcon.alpha = 0
        self.deliveringIcon.alpha = 0
        self.deliveredIcon.alpha = 0
        self.receivedOn.alpha = 0
        self.deliveringOn.alpha = 0
        self.deliveredOn.alpha = 0
        
        // Constraint adjustments for smaller iPhones 5/SE
        if (UIScreen.mainScreen().bounds.size.height <= 480) {
            self.proportionalHeight.constant = 50
            self.view.layoutIfNeeded()
        }
        
        // Add swipe gestures
        let swipeLeftGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeLeftGesture.direction = .Left
        view.addGestureRecognizer(swipeLeftGesture)
        let swipeRightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeRightGesture.direction = .Right
        view.addGestureRecognizer(swipeRightGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        // Set timer
        self.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "getOrderStatusUpdate", userInfo: nil, repeats: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedOrderStatusUpdate", name: "orderStatusUpdated", object: nil)
        self.menuWidth.constant = -(self.menuButton.frame.width + self.menuButtonOffset.constant * 2)
        self.menuOffset.constant = -self.menu.frame.width
    }
    
    override func viewDidAppear(animated: Bool) {
        // Hide time information
        self.receivedTimeLabel.alpha = 0
        self.deliveringTimeLabel.alpha = 0
        self.deliveredTimeLabel.alpha = 0
        
        // Round step icon corners
        self.receivedIcon.layer.cornerRadius = self.receivedIcon.frame.width / 2
        self.receivedIcon.clipsToBounds = true
        self.deliveringIcon.layer.cornerRadius = self.deliveringIcon.frame.width / 2
        self.deliveringIcon.clipsToBounds = true
        self.deliveredIcon.layer.cornerRadius = self.deliveredIcon.frame.width / 2
        self.deliveredIcon.clipsToBounds = true
        
        UIView.animateWithDuration(0.25, animations: {
            self.receivedIcon.alpha = 1
            self.deliveringIcon.alpha = 1
            self.deliveredIcon.alpha = 1
        })
        
        //++ THIS MAY NEED TO GO
        /*
        if (self.orderStatusView.frame.height < self.view.frame.height * 0.6) {
            self.proportionalHeight.constant = -((self.view.frame.height * 0.6) - self.orderStatusView.frame.height)
            UIView.animateWithDuration(0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }*/

        self.receivedOrderStatusUpdate()
    }

    override func viewWillDisappear(animated: Bool) {
        self.timer?.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "orderStatusUpdated", object: nil)
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .Left && self.menuOpen == true) {
            self.closeMenu()
        }
        
        if (sender.direction == .Right && self.menuOpen == false) {
            self.openMenu()
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
    
    @IBAction func menuTrackTap(sender: AnyObject) {
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
    
    @IBAction func paymentTap(sender: AnyObject) {
        GaskyFoundation.sharedInstance.setPaymentViewOverride(2)
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedInfoStepThree"])
    }
    
    @IBAction func contactTap(sender: AnyObject) {
        let contactEmail = "support@gasky.co"
        let url = NSURL(string: "mailto:\(contactEmail)")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func cancelTap(sender: AnyObject) {
        let alertController = UIAlertController(title: "Are you sure you want to cancel the request?", message:
            "There will be a $5 delivery fee if the request is cancelled while Gasky is on its way", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Never Mind", style: UIAlertActionStyle.Default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { action -> Void in
            GaskyFoundation.sharedInstance.cancelOpenOrder()
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func receivedOrderStatusUpdate() {
        self.orderStatus = GaskyFoundation.sharedInstance.returnOrderStatus()
        
        if (didLayoutGoogle == false) {
            self.setupMaps()
        }
        
        self.updateTrackingSteps()
    }
    
    func getOrderStatusUpdate() {
        GaskyFoundation.sharedInstance.getOpenOrder()
    }
    
    func openMenu() {
        self.returnButton.hidden = false
        self.menuOffset.constant = 0
        self.trackingOffset.constant = self.menu.frame.width
        self.menuOpen = true
        
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func closeMenu() {
        self.returnButton.hidden = true
        self.menuOffset.constant = -self.menu.frame.width
        self.trackingOffset.constant = 0
        self.menuOpen = false
        
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setupMaps() {
        if (self.orderStatus["latitude"]! != nil) {
            self.didLayoutGoogle = true
            
            let latitude = Double(self.orderStatus["latitude"]!!)
            let longitude = Double(self.orderStatus["longitude"]!!)
            
            let camera = GMSCameraPosition.cameraWithTarget(CLLocationCoordinate2DMake(latitude! + 0.00025, longitude!), zoom: 17)
            self.mapView = GMSMapView.mapWithFrame(CGRectMake(0, 0, self.mapsView.frame.width, self.mapsView.frame.height), camera: camera)
            self.mapView?.mapType = kGMSTypeHybrid
            
            self.mapsView.userInteractionEnabled = false
            self.mapsView.addSubview(self.mapView)
            self.mapView.delegate = self
            
            let mapMarkerReference = self.orderStatus["deliveryDay"]!! + self.orderStatus["scheduled"]!!
            let image: UIImage? = UIImage(named: mapMarkerReference)
            if (image != nil) {
                if (self.mapMarker != nil) {
                    self.mapMarker!.map = nil
                }
                
                self.mapMarker = GMSMarker(position: CLLocationCoordinate2DMake(latitude!, longitude!))
                //self.mapMarker!.appearAnimation = GoogleMaps.kGMSMarkerAnimationPop
                self.mapMarker!.title = "Delivery Location"
                self.mapMarker!.icon = image
                self.mapMarker!.map = mapView
            }
        }
    }
    
    func updateTrackingSteps() {
        if (self.timer != nil) {
            var animationDelay: NSTimeInterval = 0
            
            if (self.receivedDisplayed == false && self.orderStatus["received"]! != nil) {
                self.enableReceived(self.orderStatus["received"]!!)
                animationDelay += 0.85
            }
            
            if (self.deliveringDisplayed == false && self.orderStatus["delivering"]! != nil) {
                self.enableDelivering(self.orderStatus["delivering"]!!, delay: animationDelay)
                animationDelay += 1.85
            }
            
            if (self.deliveredDisplayed == false && self.orderStatus["delivered"]! != nil) {
                self.enableDelivered(self.orderStatus["delivered"]!!, delay: animationDelay)
                animationDelay += 1.85
            }
            
            if (self.orderStatus["status"]! != "in progress") {
                self.timer!.invalidate()
                self.timer = nil
            }
            
            let delay = animationDelay * Double(NSEC_PER_SEC)
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                if (self.orderStatus["status"]! != nil) {
                    if (self.orderStatus["status"]! == "canceled") {
                        // clear order data and go back to request
                        GaskyFoundation.sharedInstance.setOrderStatus(nil, scheduled: nil, deliveryDay: nil, latitude: nil, longitude: nil, received: nil, delivering: nil, delivered: nil, status: nil)
                        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
                    }
                    
                    if (self.orderStatus["status"]! == "feedback") {
                        // go to order completed
                        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderCompleted"])
                    }
                    
                    if (self.orderStatus["status"]! == "completed") {
                        // clear order data and go back to request
                        GaskyFoundation.sharedInstance.setOrderStatus(nil, scheduled: nil, deliveryDay: nil, latitude: nil, longitude: nil, received: nil, delivering: nil, delivered: nil, status: nil)
                        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
                    }
                }
            })
        }
    }
    
    func enableReceived(timeString: String) {
        self.receivedDisplayed = true
        self.receivedTimeLabel.text = timeString
        
        UIView.animateWithDuration(0.5, animations: {
            self.receivedIcon.alpha = 1
            self.receivedOff.alpha = 0
            self.receivedOn.alpha = 1
        }, completion: {
            (value: Bool) in
            self.receivedLabelOffset.constant = -(self.receivedTimeLabel.frame.height + 3) / 2
            UIView.animateWithDuration(0.35, animations: {
                self.receivedLabel.alpha = 1
                self.receivedTimeLabel.alpha = 1
                self.view.layoutIfNeeded()
            })
        })
    }
    
    func enableDelivering(timeString: String, delay: NSTimeInterval) {
        self.deliveringDisplayed = true
        self.deliveringTimeLabel.text = timeString
        
        UIView.animateWithDuration(0.333, delay: delay, options: .CurveEaseInOut, animations: {
            self.paw1.alpha = 1
        }, completion: {
             (value: Bool) in
        })
        
        UIView.animateWithDuration(0.334, delay: delay + 0.333, options: .CurveEaseInOut, animations: {
            self.paw2.alpha = 1
        }, completion: {
            (value: Bool) in
        })
        
        UIView.animateWithDuration(0.333, delay: delay + 0.667, options: .CurveEaseInOut, animations: {
            self.paw3.alpha = 1
        }, completion: {
            (value: Bool) in
        })
        
        UIView.animateWithDuration(0.5, delay: delay + 1, options: .CurveEaseInOut, animations: {
            self.deliveringIcon.alpha = 1
            self.deliveringOff.alpha = 0
            self.deliveringOn.alpha = 1
        }, completion: {
            (value: Bool) in
            self.deliveringLabelOffset.constant = -(self.deliveringTimeLabel.frame.height + 3) / 2
            UIView.animateWithDuration(0.35, animations: {
                self.deliveringLabel.alpha = 1
                self.deliveringTimeLabel.alpha = 1
                self.view.layoutIfNeeded()
            })
        })
    }
    
    func enableDelivered(timeString: String, delay: NSTimeInterval) {
        self.deliveredDisplayed = true
        self.deliveredTimeLabel.text = timeString
        
        UIView.animateWithDuration(0.333, delay: delay, options: .CurveEaseInOut, animations: {
            self.paw4.alpha = 1
            }, completion: {
                (value: Bool) in
        })
        
        UIView.animateWithDuration(0.334, delay: delay + 0.333, options: .CurveEaseInOut, animations: {
            self.paw5.alpha = 1
            }, completion: {
                (value: Bool) in
        })
        
        UIView.animateWithDuration(0.333, delay: delay + 0.667, options: .CurveEaseInOut, animations: {
            self.paw6.alpha = 1
            }, completion: {
                (value: Bool) in
        })
        
        UIView.animateWithDuration(0.5, delay: delay + 1, options: .CurveEaseInOut, animations: {
            self.deliveredIcon.alpha = 1
            self.deliveredOff.alpha = 0
            self.deliveredOn.alpha = 1
            }, completion: {
                (value: Bool) in
                self.deliveredLabelOffset.constant = -(self.deliveredTimeLabel.frame.height + 3) / 2
                UIView.animateWithDuration(0.35, animations: {
                    self.deliveredLabel.alpha = 1
                    self.deliveredTimeLabel.alpha = 1
                    self.view.layoutIfNeeded()
                })
        })
        
        // Disable Payment and Cancel Buttons
        self.footerButtonsEnabled = false
        UIView.animateWithDuration(0.333) {
            self.paymentIcon.alpha = 0.2
            self.paymentLabel.alpha = 0.2
            self.cancelIcon.alpha = 0.2
            self.cancelLabel.alpha = 0.2
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
