//
//  Challenge.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import SwiftDate

struct Challenge: Codable {
    let id: Int
    let name: String
    let code: String
    let profilePictureUrl: String?
    let startDate: Date
    let endDate: Date
    let timeZone: String
}

extension Challenge {

    var days: [Date] {
        let daysGone: Int
        
        if Date().localDateIsLessThanUTCDate(endDate) {
            daysGone = abs(startDate.utcDateIsDaysApartFromLocalDate(Date()))
        } else {
            daysGone = abs(startDate.utcDateIsDaysApartFromUtcDate(endDate))
        }
        
        return (0..<(daysGone + 1)).map { startDate + Int($0).days }
    }
    
    func daysWithWorkouts(workouts: [Workout]) -> [Date] {
        return days.filter({ date -> Bool in
            return workouts.workoutsExist(on: date)
        })
    }

    var daysLeft: String {
        let difference = Date().localDateIsDaysApartFromUTCDate(endDate)
        
        if difference > 0 {
            return "Completed \(endDate.toFormat("MMM d, yyyy"))"
        } else if difference < 0 {
            let diff = abs(difference)
            
            if diff == 1 {
                return "1 day left"
            } else {
                return "\(diff) days left"
            }
        } else {
            return "Last day"
        }
    }

}

extension Challenge {
    
    var isActive: Bool {
        let today = Date()

        return today.localDateIsGreaterThanOrEqualToUTCDate(startDate) && today.localDateIsLessThanOrEqualToUTCDate(endDate)
    }
    
    var isPast: Bool {
        return Date().localDateIsGreaterThanUTCDate(endDate)
    }
    
    var isUpcoming: Bool {
        let today = Date()

        return today.localDateIsLessThanUTCDate(startDate)
    }
}

extension Array where Element == Challenge {
    
    func getActiveChallenges() -> [Challenge] {
        return self.filter { $0.isActive }
            .sorted(by: { $0.startDate < $1.startDate })
    }
    
    func getActiveAndUpcomingChallenges() -> [Challenge] {
        return self.filter { $0.isActive || $0.isUpcoming }
             .sorted(by: { $0.isActive && !$1.isActive })
    }
    
    func getPastChallenges() -> [Challenge] {
        return self.filter { $0.isPast }
    }
    
    func getUpcomingChallenges() -> [Challenge] {
        return self.filter { $0.isUpcoming }
    }
    
}

extension Challenge: AvatarProtocol {
    
    var pictureUrl: String? {
        return self.profilePictureUrl
    }
    
    var myName: String? {
        return name
    }
    
}
