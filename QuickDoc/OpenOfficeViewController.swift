//
//  OpenOfficeViewController.swift
//  QuickDoc
//
//  Created by Edward Suczewski on 2/23/17.
//  Copyright © 2017 Edward Suczewski. All rights reserved.
//

import UIKit

class OpenOfficeViewController: UIViewController {

    // MARK: Properties
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Outlets
    
    // MARK: Actions
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: Methods


}
