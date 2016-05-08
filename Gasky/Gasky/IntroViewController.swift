//
//  ViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 1/19/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController /* , UIPageViewControllerDataSource */ {
    
    // View connections
    @IBOutlet weak var buttonView: UIView!
    
    // Button connections
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    // UIPageViewController reference and tutorial image array
    var pageViewController: UIPageViewController!
    var pageImages: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set status bar color to light
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        // Add border to sign in button
        signInButton.layer.borderWidth = 1
        signInButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Assign images to tutorial image array and setup tutorial pageview contorller
        // Pulled via direction from Daniel, commented below in case we need to revert and place it back into the app
        /*
        self.pageImages = NSArray(objects: "screen1", "screen2", "screen3")
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialPageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        let startVC = self.viewControllerAtIndex(0) as TutorialViewController
        let viewControllers = NSArray(object: startVC)
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        self.pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.width, self.view.frame.size.height - self.buttonView.frame.height - 45)
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInButtonTapped(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedLogin"])
    }
    
    @IBAction func registerButtonTapped(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("segueTo", object: nil, userInfo: ["target": "embedRegister"])
    }
    
    // Page view function for handling page indexes
    // Pulled via direction from Daniel, commented below in case we need to revert and place it back into the app
    /*
    func viewControllerAtIndex(index: Int) -> TutorialViewController {
        if (self.pageImages.count == 0 || index >= self.pageImages.count) {
            return TutorialViewController()
        }
        
        let vc: TutorialViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialContentViewController") as! TutorialViewController
        vc.imageFile = self.pageImages[index] as! String
        vc.pageIndex = index
        
        return vc
    }
    */
    
    // Page view function for scrolling backwward through page indexes
    // Pulled via direction from Daniel, commented below in case we need to revert and place it back into the app
    /*
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! TutorialViewController
        var index = vc.pageIndex as Int
        
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index)
    }
    */
    
    // Page view function for scrolling forwards through page indexes
    // Pulled via direction from Daniel, commented below in case we need to revert and place it back into the app
    /*
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! TutorialViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound) {
            return nil
        }
        
        index++
        
        if (index == self.pageImages.count) {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
    }
    */
    
    // Page view function for setting the number of page dots to display
    // Pulled via direction from Daniel, commented below in case we need to revert and place it back into the app
    /*
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageImages.count
    }
    */
    
    // Page view function for returning the initial page number (always starts at the beginning)
    // Pulled via direction from Daniel, commented below in case we need to revert and place it back into the app
    /*
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    */
}

