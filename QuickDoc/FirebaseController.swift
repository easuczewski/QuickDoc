//
//  FirebaseController.swift
//  QuickDoc
//
//  Created by Edward Suczewski on 2/23/17.
//  Copyright © 2017 Edward Suczewski. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseController {
    
    // MARK: Methods
    
    static func dataAtEndpoint(endpoint: String, completion: @escaping(_ data: Any?) -> Void) {
        FIRDatabase.database().reference().child(endpoint).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot.value)
        })
    }
    
}

protocol FirebaseType {
    var identifier: String { get set }
    var endpoint: String { get }
    var jsonValue: [String: AnyObject] { get }
    
    init?(json: [String: AnyObject], identifier: String)
    
    func save(completion: @escaping(_ error: Error?) -> Void)
    func delete(completion: @escaping(_ error: Error?) -> Void)
}

extension FirebaseType {
    
    func save(completion: @escaping(_ error: Error?) -> Void) {
        var databaseReference: FIRDatabaseReference
        databaseReference = FIRDatabase.database().reference().child(endpoint).child(identifier)
        databaseReference.updateChildValues(self.jsonValue) { (error, ref) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func delete(completion: @escaping(_ error: Error?) -> Void) {
        FIRDatabase.database().reference().child(endpoint).child(identifier).removeValue(completionBlock: { (error, ref) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        })
    }
    
}
