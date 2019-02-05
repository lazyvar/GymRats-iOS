//
//  Group.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

struct Group: Codable {
    let id: Int
    let name: String
    let code: String
    let pictureUrl: String?
    let startDate: Date
    let endDate: Date
}

extension Array where Element == Group {
    
    func getActiveGroups() -> [Group] {
        return self.filter { group in
            let today = Date()
            
            return today >= group.startDate && today <= group.endDate
        }
    }
    
    func getInActiveGroups() -> [Group] {
        return self.filter { Date() > $0.endDate }
    }
    
}
