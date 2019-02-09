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
    
    var challengeTime: String {
        return challengeDate().toFormat("h:mm a")
    }
    
    func challengeDate(in timeZone: TimeZone = TimeZone(abbreviation: ActiveChallengeViewController.timeZone)!) -> DateInRegion {
        return self.in(region: .region(in: timeZone))
    }
    
}

extension Region {
    
    static func region(in timeZone: TimeZone = TimeZone(abbreviation: ActiveChallengeViewController.timeZone)!) -> Region {
        return Region (
            calendar: Calendar.autoupdatingCurrent,
            zone: timeZone,
            locale: Locale.autoupdatingCurrent
        )
    }
    
}
