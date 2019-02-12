//
//  Challenge.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

struct Challenge: Codable {
    let id: Int
    let name: String
    let code: String
    let profilePictureUrl: String?
    let startDate: Date
    let endDate: Date
    let timeZone: String
}

extension Array where Element == Challenge {
    
    func getActiveChallenges() -> [Challenge] {
        return self.filter { challenge in
            let today = Date().challengeDate()
            let startDate = challenge.startDate
            let endDate = challenge.endDate
            
            return startDate.isToday || endDate.isToday || (today.compare(.isLater(than: startDate)) && today.compare(.isEarlier(than: endDate)))
        }
    }
    
    func getInActiveChallenges() -> [Challenge] {
        return self.filter { Date() > $0.endDate }
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
