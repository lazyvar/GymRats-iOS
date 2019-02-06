//
//  UIDate+Extension.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import SwiftDate

extension Date {
    
    var localTime: String {
        return self.in(region: .current).toFormat("h:mm a")
    }
    
}
