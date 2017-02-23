//
//  ArrayExtension.swift
//  QuickDoc
//
//  Created by Edward Suczewski on 2/23/17.
//  Copyright © 2017 Edward Suczewski. All rights reserved.
//

import Foundation

extension Array {
    mutating func shuffle() {
        for index in 0..<(count - 1) {
            let newIndex = Int(arc4random_uniform(UInt32(count - 1)))
            if index != newIndex {
                swap(&self[index], &self[newIndex])
            }
        }
    }
}
