//
//  VirtualOffice.swift
//  QuickDoc
//
//  Created by Edward Suczewski on 2/23/17.
//  Copyright © 2017 Edward Suczewski. All rights reserved.
//

import Foundation

struct VirtualOffice: FirebaseType {
    
    // MARK: Properties
    
    var identifier: String
    var doctorLastName: String
    var specialty: String
    /// Valid statuses are "open", "occupied", or "closed"
    var status: String
    
    var endpoint: String {
        return "virtualOffices"
    }
    
    var jsonValue: [String : AnyObject] {
        return [kDoctorLastName: doctorLastName as AnyObject, kSpecialty: specialty as AnyObject, kStatus: status as AnyObject]
    }
    
    // MARK: Initializers
    
    init(identifier: String, doctorLastName: String, specialty: String, status: String) {
        self.identifier = identifier
        self.doctorLastName = doctorLastName
        self.specialty = specialty
        self.status = status
    }
    
    init?(json: [String: AnyObject], identifier: String) {
        guard let doctorLastName = json[kDoctorLastName] as? String,
            let specialty = json[kSpecialty] as? String,
            let status = json[kStatus] as? String else {
                return nil
        }
        self.identifier = identifier
        self .doctorLastName = doctorLastName
        self.specialty = specialty
        self.status = status
    }
    
}

// MARK: Keys

private let kDoctorLastName = "doctorLastName"
private let kSpecialty = "specialty"
private let kStatus = "status"
