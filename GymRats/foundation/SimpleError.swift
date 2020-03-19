//
//  SimpleError.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

struct SimpleError: Error, LocalizedError {
    let message: String
    
    var localizedDescription: String {
        return message
    }
    
    var description: String {
        get {
            return message
        }
    }

    var errorDescription: String? {
        get {
            return message
        }
    }

}
