//
//  ChooseDoctorViewController.swift
//  QuickDoc
//
//  Created by Edward Suczewski on 2/23/17.
//  Copyright © 2017 Edward Suczewski. All rights reserved.
//

import UIKit

class ChooseDoctorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Properties
    
    var virtualOffices = [VirtualOffice]()
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    
    @IBAction func reloadButtonTapped(_ sender: UIBarButtonItem) {
        updateViewWithVirtualOffices()
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewWithVirtualOffices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: Methods
    
    func updateViewWithVirtualOffices() {
        VirtualOfficeController.fetchAllVirtualOffices { (virtualOffices) in
            if let virtualOffices = virtualOffices {
                self.virtualOffices = virtualOffices
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func animateImageAtIndexPath(indexPath: IndexPath) {
        UIView.animate(withDuration: 0.15, animations: {
            self.tableView.cellForRow(at: indexPath)?.imageView?.center.x += 10
        }) { (_) in
            UIView.animate(withDuration: 0.15, animations: {
                self.tableView.cellForRow(at: indexPath)?.imageView?.center.x -= 20
            }) { (_) in
                UIView.animate(withDuration: 0.15, animations: {
                    self.tableView.cellForRow(at: indexPath)?.imageView?.center.x += 20
                }) { (_) in
                    UIView.animate(withDuration: 0.15, animations: {
                        self.tableView.cellForRow(at: indexPath)?.imageView?.center.x -= 10
                    }, completion: nil)
                }
            }
        }
    }


    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return virtualOffices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "virtualOfficeCell", for: indexPath)
        let virtualOffice = virtualOffices[indexPath.row]
        cell.imageView?.image = UIImage(named: virtualOffice.status)
        cell.textLabel?.text = "Dr. " + virtualOffice.doctorLastName
        cell.detailTextLabel?.text = virtualOffice.specialty
        return cell
    }
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let virtualOffice = virtualOffices[indexPath.row]
        if virtualOffice.status != "open" {
            animateImageAtIndexPath(indexPath: indexPath)
        } else {
            VirtualOfficeController.virtualOffice(withIdentifier: virtualOffice.identifier) { (virtualOffice) in
                if let virtualOffice = virtualOffice {
                    if virtualOffice.status == "open" {
                        VirtualOfficeController.updateVirtualOffice(virtualOffice, withStatus: "occupied", completion: { (virtualOffice) in
                            if let virtualOffice = virtualOffice {
                                self.performSegue(withIdentifier: "presentOfficeToPatient", sender: virtualOffice.identifier)
                            }
                        })
                    } else {
                        DispatchQueue.main.async {
                            self.tableView.cellForRow(at: indexPath)?.imageView?.image = UIImage(named: virtualOffice.status)
                            self.animateImageAtIndexPath(indexPath: indexPath)
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? VirtualOfficeViewController,
            let virtualOfficeIdentifier = sender as? String {
            destination.userIsPatient = true
            destination.virtualOfficeIdentifier = virtualOfficeIdentifier
        }
    }
    
    
}
