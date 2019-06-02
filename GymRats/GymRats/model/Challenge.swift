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
        let endingDate: Date
        
        if Date() < endDate {
            endingDate = Date()
        } else {
            endingDate = endDate
        }
        
        let daysGone = startDate.getInterval(toDate: endingDate, component: .day)
        
        return (0...daysGone).map { startDate + Int($0).days }
    }

    var daysLeft: String {
        let difference = Date().getInterval(toDate: endDate, component: .day)
        
        if difference < 0 {
            return "Completed on \(endDate.toFormat("MMM d, yyyy"))"
        } else if difference > 0 {
            return "\(difference) days remaining"
        } else {
            return "Last day"
        }
    }

}

extension Challenge {
    
    var isActive: Bool {
        let today = Date().challengeDate()

         return startDate.challengeDate().isToday || endDate.challengeDate().isToday || (today.compare(.isLater(than: startDate)) && today.compare(.isEarlier(than: endDate)))
    }
    
    var isPast: Bool {
        return Date() > endDate
    }
    
}

extension Array where Element == Challenge {
    
    func getActiveChallenges() -> [Challenge] {
        let today = Date().challengeDate()
        
        return self.filter { challenge in
            let startDate = challenge.startDate
            let endDate = challenge.endDate
            
            return startDate.isToday || endDate.isToday || (today.compare(.isEarlier(than: endDate)) && startDate.compare(.isEarlier(than: today)))
        }.sorted(by: { $0.startDate < $1.startDate })
    }
    
    func getActiveAndUpcomingChallenges() -> [Challenge] {
        let today = Date().challengeDate()

        return self.filter { challenge in
            let startDate = challenge.startDate
            let endDate = challenge.endDate
            
            return startDate.isToday || endDate.isToday || today.compare(.isEarlier(than: endDate))
        }.sorted(by: { $0.isActive && !$1.isActive })
    }
    
    func getInActiveChallenges() -> [Challenge] {
        return self.filter { Date() > $0.endDate }
    }
    
    func getUpcomingChallenges() -> [Challenge] {
        return self.filter { Date() < $0.startDate }
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
