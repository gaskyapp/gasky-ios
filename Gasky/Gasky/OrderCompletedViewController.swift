//
//  OrderCompletedViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 3/7/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class OrderCompletedViewController: UIViewController {
    @IBOutlet weak var topMeasurement: UIView!
    @IBOutlet weak var feedbackOffset: NSLayoutConstraint!
    @IBOutlet weak var totalDollars: UILabel!
    @IBOutlet weak var totalCents: UILabel!
    @IBOutlet weak var deliveryTime: UILabel!
    @IBOutlet weak var star1Empty: UIImageView!
    @IBOutlet weak var star1Full: UIImageView!
    @IBOutlet weak var star2Empty: UIImageView!
    @IBOutlet weak var star2Full: UIImageView!
    @IBOutlet weak var star3Empty: UIImageView!
    @IBOutlet weak var star3Full: UIImageView!
    @IBOutlet weak var star4Empty: UIImageView!
    @IBOutlet weak var star4Full: UIImageView!
    @IBOutlet weak var star5Empty: UIImageView!
    @IBOutlet weak var star5Full: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var lateButton: UIButton!
    @IBOutlet weak var unprofessionalButton: UIButton!
    @IBOutlet weak var tankButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var costBreakdown: UIView!
    @IBOutlet weak var costBreakdownOffset: NSLayoutConstraint!
    @IBOutlet weak var gasRecapLabel: UILabel!
    @IBOutlet weak var gasCostLabel: UILabel!
    @IBOutlet weak var deliveryFeeCostLabel: UILabel!
    @IBOutlet weak var discountAmountlabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var meterPhoto: UIImageView!
    
    var optionsVisible: Bool = false
    var rating: Int = 0
    var details: String? = nil
    var submittingInfo: Bool = false
    var orderSummary = [String:String?]()
    var loadedData: NSData?
    var viewingSummary: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set status bar color to light
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Offset cost breakdown
        self.costBreakdown.hidden = true

        // Get order summary data
        GaskyFoundation.sharedInstance.getOrderSummary()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedOrderSummary", name: "orderSummaryUpdated", object: nil)
        
        // Set stars
        self.setStars(0)
        
        // Set up button borders
        self.resetButtons()
        self.lateButton.alpha = 0
        self.lateButton.hidden = true
        self.unprofessionalButton.alpha = 0
        self.unprofessionalButton.hidden = true
        self.tankButton.alpha = 0
        self.tankButton.hidden = true
        self.otherButton.alpha = 0
        self.otherButton.hidden = true
        self.submitButton.backgroundColor = GaskyFoundation.buttonDisabled
        self.submitButton.setTitleColor(GaskyFoundation.buttonDisabledText, forState: UIControlState.Normal)
        
        // Add swipe gesture
        let swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeGesture.direction = .Down
        view.addGestureRecognizer(swipeGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func receivedOrderSummary() {
        self.orderSummary = GaskyFoundation.sharedInstance.returnOrderSummary()
        
        if (self.orderSummary["total"]! != nil) {
            self.totalCostLabel.text = "$" + self.orderSummary["total"]!!
            
            let priceSplit = self.orderSummary["total"]!!.characters.split(".")
            self.totalDollars.text = String(priceSplit.first!)
            self.totalCents.text = "." + String(priceSplit.last!)
        }
        
        if (self.orderSummary["completed"]! != nil) {
            self.deliveryTime.text = self.orderSummary["completed"]!
        }
        
        if (self.orderSummary["gasTotal"]! != nil) {
            self.gasCostLabel.text = "$" + self.orderSummary["gasTotal"]!!
        }
        
        if (self.orderSummary["pricePerGallon"]! != nil && self.orderSummary["gallons"]! != nil) {
            self.gasRecapLabel.text = self.orderSummary["gallons"]!! + " gal @ $" + self.orderSummary["pricePerGallon"]!! + "/gal"
        }
        
        if (self.orderSummary["deliveryFee"]! != nil) {
            self.deliveryFeeCostLabel.text = "$" + self.orderSummary["deliveryFee"]!!
        }
        
        if (self.orderSummary["discount"]! != nil) {
            self.discountAmountlabel.text = "$" + self.orderSummary["discount"]!!
        }
        
        if (self.orderSummary["meterPhoto"]! != nil) {
            let url = NSURL(string: self.orderSummary["meterPhoto"]!!)
            self.loadedData = NSData(contentsOfURL: url!)
            if (self.loadedData != nil) {
                meterPhoto?.image = UIImage(data: self.loadedData!)
            }
        }
    }
    
    @IBAction func detailsButtonTap(sender: AnyObject) {
        self.costBreakdown.hidden = false
        self.costBreakdownOffset.constant = -self.view.frame.height
        self.view.layoutIfNeeded()
        
        self.costBreakdownOffset.constant = 0
        self.viewingSummary = true
        
        UIView.animateWithDuration(0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func detailsButtonCloseTap(sender: AnyObject) {
        self.costBreakdownOffset.constant = -self.view.frame.height
        self.viewingSummary = false
        
        UIView.animateWithDuration(0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func star1ButtonTap(sender: AnyObject) {
        self.setStars(1)
        self.updateMessage(1)
    }
    
    @IBAction func star2ButtonTap(sender: AnyObject) {
        self.setStars(2)
        self.updateMessage(2)
    }
    
    @IBAction func star3ButtonTap(sender: AnyObject) {
        self.setStars(3)
        self.updateMessage(3)
    }
    
    @IBAction func star4ButtonTap(sender: AnyObject) {
        self.setStars(4)
        self.updateMessage(4)
    }
    
    @IBAction func star5ButtonTap(sender: AnyObject) {
        self.setStars(5)
        self.updateMessage(5)
        self.resetButtons()
        self.details = nil
    }
    
    @IBAction func lateButtonTap(sender: AnyObject) {
        if (self.rating < 5) {
            self.resetButtons()
            self.lateButton.layer.borderColor = GaskyFoundation.normalColor.CGColor
            self.details = "Late Delivery"
        }
    }
    
    @IBAction func unprofessionalButtonTap(sender: AnyObject) {
        if (self.rating < 5) {
            self.resetButtons()
            self.unprofessionalButton.layer.borderColor = GaskyFoundation.normalColor.CGColor
            self.details = "Unprofessional Driver"
        }
    }
    
    @IBAction func tankButtonTap(sender: AnyObject) {
        if (self.rating < 5) {
            self.resetButtons()
            self.tankButton.layer.borderColor = GaskyFoundation.normalColor.CGColor
            self.details = "Tank Wasn't Full"
        }
    }
    
    @IBAction func otherButtonTap(sender: AnyObject) {
        if (self.rating < 5) {
            self.resetButtons()
            self.otherButton.layer.borderColor = GaskyFoundation.normalColor.CGColor
            self.details = "Other"
        }
    }

    @IBAction func submitButtonTap(sender: AnyObject) {
        self.costBreakdown.hidden = true
        
        if (self.rating > 0 && self.submittingInfo == false) {
            self.submittingInfo = true
            
            GaskyFoundation.sharedInstance.submitOrderFeedback(Int(self.orderSummary["id"]!!)!, rating: self.rating, details: self.details)  { (status: Int, error: String) in
                if (status == 200) {
                    GaskyFoundation.sharedInstance.setOrderStatus(nil, scheduled: nil, deliveryDay: nil, latitude: nil, longitude: nil, received: nil, delivering: nil, delivered: nil, status: nil)
                    GaskyFoundation.sharedInstance.setOrderSummary(nil, completed: nil, total: nil, pricePerGallon: nil, gallons: nil, gasTotal: nil, deliveryFee: nil, meterPhoto: nil, discount: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedOrderMap"])
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
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        if (self.viewingSummary == true) {
            self.costBreakdownOffset.constant = -self.view.frame.height
            self.viewingSummary = false
            
            UIView.animateWithDuration(0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func resetButtons() {
        self.lateButton.layer.borderWidth = 1
        self.lateButton.layer.borderColor = GaskyFoundation.neutralColor.CGColor
        self.unprofessionalButton.layer.borderWidth = 1
        self.unprofessionalButton.layer.borderColor = GaskyFoundation.neutralColor.CGColor
        self.tankButton.layer.borderWidth = 1
        self.tankButton.layer.borderColor = GaskyFoundation.neutralColor.CGColor
        self.otherButton.layer.borderWidth = 1
        self.otherButton.layer.borderColor = GaskyFoundation.neutralColor.CGColor
    }
    
    func setStars(num: Int) {
        self.star1Full.hidden = true
        self.star2Full.hidden = true
        self.star3Full.hidden = true
        self.star4Full.hidden = true
        self.star5Full.hidden = true
        
        if (num > 0) {
            self.star1Full.hidden = false
        }
        
        if (num > 1) {
            self.star2Full.hidden = false
            self.submitButton.layer.backgroundColor = GaskyFoundation.buttonEnabled.CGColor
            self.submitButton.backgroundColor = GaskyFoundation.buttonEnabled
            self.submitButton.setTitleColor(GaskyFoundation.buttonEnabledText, forState: UIControlState.Normal)
        }
        
        if (num > 2) {
            self.star3Full.hidden = false
        }
        
        if (num > 3) {
            self.star4Full.hidden = false
        }
        
        if (num > 4) {
            self.star5Full.hidden = false
        }
        
        self.rating = num
    }
    
    func updateMessage(num: Int) {
        if (num > 4) {
            self.messageLabel.text = "Awesome!"
        } else {
            self.messageLabel.text = "Uh oh... What happened?"
            self.transitionOptions()
        }
    }
    
    func transitionOptions() {
        if (self.optionsVisible == false) {
            self.optionsVisible = true
            
            self.lateButton.hidden = false
            self.unprofessionalButton.hidden = false
            self.tankButton.hidden = false
            self.otherButton.hidden = false
            self.view.layoutIfNeeded()
            
            self.feedbackOffset.constant = -topMeasurement.frame.height + 20
            
            UIView.animateWithDuration(0.25, animations: {
                self.lateButton.alpha = 1
                self.unprofessionalButton.alpha = 1
                self.tankButton.alpha = 1
                self.otherButton.alpha = 1
                self.view.layoutIfNeeded()
            })
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
