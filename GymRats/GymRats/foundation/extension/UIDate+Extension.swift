//
//  UIDate+Extension.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

extension Date {
    
    static let formatter = DateFormatter()
    
    var challengeTime: String {
        Date.formatter.timeZone = TimeZone.current
        Date.formatter.dateFormat = "h:mm a"
        
        return Date.formatter.string(from: self)
    }

    var challengeTimeTime: String {
        Date.formatter.timeZone = TimeZone.current
        Date.formatter.dateFormat = "h:mm"
        
        return Date.formatter.string(from: self)
    }

    var challengeTimeA: String {
        Date.formatter.timeZone = TimeZone.current
        Date.formatter.dateFormat = "a"
        
        return Date.formatter.string(from: self)
    }

}
