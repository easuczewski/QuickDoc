//
//  HomeViewController.swift
//  QuickDoc
//
//  Created by Edward Suczewski on 2/23/17.
//  Copyright © 2017 Edward Suczewski. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: Properties
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    
    
    
    // MARK: Actions
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
     // MARK: Methods

    


}
