//
//  TutorialViewController.swift
//  Gasky
//
//  Created by Eric Lorentz on 1/19/16.
//  Copyright © 2016 Gasky, LLC. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var tutorialImageView: UIImageView!
    
    var pageIndex: Int!
    var imageFile: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tutorialImageView.image = UIImage(named: self.imageFile)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
