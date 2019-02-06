//
//  Switch.swift
//  GymRats
//
//  Created by Mack Hasz on 2/6/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

class Trap {
    
    private var value: Bool = true
    
    func getValue() -> Bool {
        defer {
            value = false
        }
        
        return value
    }
    
    var isOn: Bool {
        return getValue()
    }
    
    var isOff: Bool {
        return !getValue()
    }

    var yes: Bool {
        return getValue()
    }
    
    var no: Bool {
        return !getValue()
    }

}
