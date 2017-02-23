//
//  VirtualOfficeController.swift
//  QuickDoc
//
//  Created by Edward Suczewski on 2/23/17.
//  Copyright © 2017 Edward Suczewski. All rights reserved.
//

import Foundation
import Firebase

class VirtualOfficeController {
        
    // MARK: Create
    
    static func createVirtualOffice(forDoctor lastName: String, withSpecialty specialty: String, completion: @escaping(_ virtualOffice: VirtualOffice?) -> Void) {
        if let identifier = FIRAuth.auth()?.currentUser?.uid {
            let virtualOffice = VirtualOffice(identifier: identifier, doctorLastName: lastName, specialty: specialty, status: "open")
            virtualOffice.save(completion: { (error) in
                if error == nil {
                    UserDefaults.standard.set(lastName, forKey: "lastName")
                    UserDefaults.standard.set(specialty, forKey: "specialty")
                    completion(virtualOffice)
                } else {
                    completion(nil)
                }
            })
        } else {
            completion(nil)
        }
    }
    
    // MARK: Read
    
    static func fetchAllVirtualOffices(completion: @escaping(_ virtualOffices: [VirtualOffice]?) -> Void) {
        FirebaseController.dataAtEndpoint(endpoint: "virtualOffices") { (data) in
            if let virtualOfficeDictionaries = data as? [String: AnyObject] {
                var virtualOffices = virtualOfficeDictionaries.flatMap({VirtualOffice(json: $0.1 as! [String : AnyObject], identifier: $0.0)})
                virtualOffices.sort(by: { (vo1, vo2) -> Bool in
                    if vo1.status == vo2.status {
                        return vo1.specialty < vo2.specialty
                    } else {
                        return vo1.status > vo2.status
                    }
                })
                completion(virtualOffices)
            } else {
                completion(nil)
            }
        }
    }
    
    static func virtualOffice(withIdentifier identifier: String, completion: @escaping(_ virtualOffice: VirtualOffice?) -> Void) {
        FirebaseController.dataAtEndpoint(endpoint: "virtualOffices/\(identifier)") { (data) in
            if let json = data as? [String: AnyObject] {
                completion(VirtualOffice(json: json, identifier: identifier))
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: Update
    /// Valid statuses are "open", "occupied", or "closed"
    static func updateVirtualOffice(_ virtualOffice: VirtualOffice, withStatus status: String, completion: @escaping(_ virtualOffice: VirtualOffice?) -> Void) {
        var newVirtualOffice = virtualOffice
        newVirtualOffice.status = status
        newVirtualOffice.save { (error) in
            if error == nil {
                completion(newVirtualOffice)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: Delete
    
    
}
