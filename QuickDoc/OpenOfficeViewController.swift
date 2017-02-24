//
//  OpenOfficeViewController.swift
//  QuickDoc
//
//  Created by Edward Suczewski on 2/23/17.
//  Copyright © 2017 Edward Suczewski. All rights reserved.
//

import UIKit

class OpenOfficeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, VirtualOfficeDelegate {

    // MARK: Properties
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    var selectedSpecialty: String?
    
    // MARK: Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var specialtyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var openOfficeImageView: UIImageView!
    
    // MARK: Actions
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lastNameTextField.delegate = self
        setUpTapGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        updateViewWithDefaults()
    }
    
    // MARK: Methods
    
    func updateViewWithDefaults() {
        if let lastName = UserDefaults.standard.string(forKey: "lastName"),
            let specialty = UserDefaults.standard.string(forKey: "specialty"),
            let index = SpecialtiesManager.specialties.index(of: specialty) {
            lastNameTextField.text = lastName
            tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .top)
            selectedSpecialty = specialty
        }
    }
    
    func setUpTapGestureRecognizers() {
        let openOfficeTGR = UITapGestureRecognizer(target: self, action: #selector(continueTapped))
        self.openOfficeImageView.addGestureRecognizer(openOfficeTGR)
    }
    
    func continueTapped() {
        guard lastNameTextField.text?.replacingOccurrences(of: " ", with: "") != "",
            lastNameTextField.text != nil else {
            animateName()
            return
        }
        guard self.selectedSpecialty != nil else {
            animateSpecialty()
            return
        }
        VirtualOfficeController.createVirtualOffice(forDoctor: lastNameTextField.text!, withSpecialty: selectedSpecialty!) { (virtualOffice) in
            if let virtualOffice = virtualOffice {
                VirtualOfficeController.sharedInstance.currentVirtualOffice = virtualOffice
                VirtualOfficeController.sharedInstance.userIsPatient = false
                self.performSegue(withIdentifier: "presentOfficeToDoctor", sender: nil)
            }
        }
    }
    
    func animateName() {
        UIView.animate(withDuration: 0.15, animations: {
            self.nameLabel.center.x += 15
            self.lastNameTextField.center.x += 15
            self.underlineView.center.x += 15
        }) { (_) in
            UIView.animate(withDuration: 0.15, animations: {
                self.nameLabel.center.x -= 30
                self.lastNameTextField.center.x -= 30
                self.underlineView.center.x -= 30
            }) { (_) in
                UIView.animate(withDuration: 0.15, animations: {
                    self.nameLabel.center.x += 30
                    self.lastNameTextField.center.x += 30
                    self.underlineView.center.x += 30
                }) { (_) in
                    UIView.animate(withDuration: 0.15, animations: {
                        self.nameLabel.center.x -= 15
                        self.lastNameTextField.center.x -= 15
                        self.underlineView.center.x -= 15
                    }, completion: nil)
                }
            }
        }
    }
    
    func animateSpecialty() {
        UIView.animate(withDuration: 0.15, animations: {
            self.specialtyLabel.center.x += 15
            self.tableView.center.x += 15
        }) { (_) in
            UIView.animate(withDuration: 0.15, animations: {
                self.specialtyLabel.center.x -= 30
                self.tableView.center.x -= 30
            }) { (_) in
                UIView.animate(withDuration: 0.15, animations: {
                    self.specialtyLabel.center.x += 30
                    self.tableView.center.x += 30
                }) { (_) in
                    UIView.animate(withDuration: 0.15, animations: {
                        self.specialtyLabel.center.x -= 15
                        self.tableView.center.x -= 15
                    }, completion: nil)
                }
            }
        }
    }

    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SpecialtiesManager.specialties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "specialtyCell", for: indexPath)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = SpecialtiesManager.specialties[indexPath.row]
        return cell
    }
    
    // Mark: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSpecialty = SpecialtiesManager.specialties[indexPath.row]
    }
    
    
    // MARK: Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Virtual Office Delegate
    func virtualOfficeDismissed() {
        if let virtualOffice = VirtualOfficeController.sharedInstance.currentVirtualOffice {
            VirtualOfficeController.updateVirtualOffice(virtualOffice, withStatus: "closed", completion: { (virtualOffice) in
                if let virtualOffice = virtualOffice {
                    VirtualOfficeController.sharedInstance.currentVirtualOffice = nil
                    print("disappeared correctly")
                }
            })
        }
    }

    
   // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? VirtualOfficeViewController {
            destination.delegate = self
        }
    }
    
    

}
