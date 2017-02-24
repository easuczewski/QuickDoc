//
//  HomeViewController.swift
//  QuickDoc
//
//  Created by Edward Suczewski on 2/23/17.
//  Copyright © 2017 Edward Suczewski. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    // MARK: Properties
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var userIsPatient: Bool = true
    
    // MARK: Outlets
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var roleImageView: UIImageView!
    @IBOutlet weak var patientButton: UIButton!
    @IBOutlet weak var doctorButton: UIButton!
    @IBOutlet weak var continueImageView: UIImageView!
    
    // MARK: Actions
    
    @IBAction func patientButtonTapped(_ sender: UIButton) {
        if !userIsPatient {
            userIsPatient = true
            updateViewWithUserRole(animated: true)
        } else {
            updateViewWithUserRole(animated: false)
        }
    }
    
    @IBAction func doctorButtonTapped(_ sender: UIButton) {
        if userIsPatient {
            userIsPatient = false
            updateViewWithUserRole(animated: true)
        } else {
            updateViewWithUserRole(animated: false)
        }
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTapGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateViewWithUserRole(animated: false)
        navigationController?.setNavigationBarHidden(true, animated: true)
        animateLogo()
    }
    
     // MARK: Methods
    
    // animations
    func animateLogo() {
        var images = [UIImage]()
        for n in 1...27 {
            if let image = UIImage(named: "cybermedLogo" + String(n)) {
                images.append(image)
            }
        }
        images.shuffle()
        logoImageView.animationImages = images
        logoImageView.animationDuration = 30
        logoImageView.animationRepeatCount = Int.max
        logoImageView.startAnimating()
    }

    // update UI
    func updateViewWithUserRole(animated: Bool) {
        if userIsPatient {
            patientButton.backgroundColor = CustomColors.quickDocCerulean
            doctorButton.backgroundColor = UIColor.white
            roleImageView.image = UIImage(named: "patientSelfID")
            if animated {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                    self.continueImageView.center.y += 100
                }, completion: { (_) in
                    self.continueImageView.image = UIImage(named: "findADoctor")
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                        self.continueImageView.center.y -= 100
                    }, completion: nil)
                })
            } else {
                self.continueImageView.image = UIImage(named: "findADoctor")
            }
        } else {
            patientButton.backgroundColor = UIColor.white
            doctorButton.backgroundColor = CustomColors.quickDocCerulean
            roleImageView.image = UIImage(named: "doctorSelfID")
            if animated {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                    self.continueImageView.center.y += 100
                }, completion: { (_) in
                    self.continueImageView.image = UIImage(named: "createAVirtualOffice")
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                        self.continueImageView.center.y -= 100
                    }, completion: nil)
                })
            } else {
                self.continueImageView.image = UIImage(named: "createAVirtualOffice")
            }
        }
    }
    
    // tap gestures & actions
    func setUpTapGestureRecognizers() {
        let toggleRoleTGR = UITapGestureRecognizer(target: self, action: #selector(toggleRoleTapped))
        self.roleImageView.addGestureRecognizer(toggleRoleTGR)
        let continueTGR = UITapGestureRecognizer(target: self, action: #selector(continueTapped))
        self.continueImageView.addGestureRecognizer(continueTGR)
    }
    
    func toggleRoleTapped() {
        if userIsPatient {
            userIsPatient = false
            updateViewWithUserRole(animated: true)
        } else {
            userIsPatient = true
            updateViewWithUserRole(animated: true)
        }
    }
    
    func continueTapped() {
        if userIsPatient {
            self.performSegue(withIdentifier: "showChooseDoctorVC", sender: nil)
        } else {
            self.performSegue(withIdentifier: "showOpenOfficeVC", sender: nil)
        }
    }

}
