//
//  Challenge.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import SwiftDate

typealias ScoreBy = Challenge.ScoreBy

struct Challenge: Codable, Equatable {
  let id: Int
  let name: String
  let code: String
  let profilePictureUrl: String?
  let startDate: Date
  let endDate: Date
  let description: String?
  let scoreBy: ScoreBy
  
  enum ScoreBy: String, Codable, CaseIterable {
    case workouts
    case duration
    case distance
    case steps
    case calories
    case points
  }
}

extension ScoreBy {
  init?(intValue: Int) {
    switch intValue {
    case 0: self = .workouts
    case 1: self = .duration
    case 2: self = .distance
    case 3: self = .steps
    case 4: self = .calories
    case 5: self = .points
    default: return nil
    }
  }

  var display: String {
    switch self {
    case .workouts: return "Number of workouts"
    case .duration: return "Minutes"
    case .distance: return "Miles"
    case .steps: return "Steps"
    case .calories: return "Calories"
    case .points: return "Points"
    }
  }
}

extension Challenge: Avatar {
  var avatarName: String? { return name }
  var avatarImageURL: String? { return profilePictureUrl }
}

extension Challenge {

  var days: [Date] {
    let daysGone: Int

    if Date().localDateIsLessThanUTCDate(startDate) {
      daysGone = abs(startDate.utcDateIsDaysApartFromUtcDate(endDate))
    } else if Date().localDateIsLessThanUTCDate(endDate) {
      daysGone = abs(startDate.utcDateIsDaysApartFromLocalDate(Date()))
    } else {
      daysGone = abs(startDate.utcDateIsDaysApartFromUtcDate(endDate))
    }
      
    return (0..<(daysGone + 1)).map { startDate + Int($0).days }
  }
    
  func daysWithWorkouts(workouts: [Workout]) -> [Date] {
    return days.reversed().filter({ date -> Bool in
      return workouts.workoutsExist(on: date)
    })
  }
  
  func bucket(_ workouts: [Workout]) -> [(Date, [Workout])] {
    return days.reversed().compactMap({ day -> (Date, [Workout])? in
      let workouts = workouts.workouts(on: day)
      
      return workouts.isNotEmpty ? (day, workouts) : nil
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

    var daysCompletePure: Int {
       return abs(Date().localDateIsDaysApartFromUTCDate(startDate))
    }

    
    var daysLeftPure: Int {
       return abs(Date().localDateIsDaysApartFromUTCDate(endDate))
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
