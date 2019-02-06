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
        let region = Region (
            calendar: Calendar.autoupdatingCurrent,
            zone: TimeZone(abbreviation: ActiveChallengeViewController.timeZone)!,
            locale: Locale.autoupdatingCurrent
        )

        return self.in(region: region).toFormat("h:mm a")
    }
    
}
