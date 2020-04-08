//
//  StatsBabyCell.swift
//  GymRats
//
//  Created by mack on 12/7/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class StatsBabyCell: UITableViewCell {

    @IBOutlet weak var mostWorkoutsView: UserImageView!
    @IBOutlet weak var mostWorkoutsLabel: UILabel!
    
    @IBOutlet weak var streakView: UserImageView!
    @IBOutlet weak var streakLabel: UILabel!
    
    @IBOutlet weak var mostWorkoutsDayView: UserImageView!
    @IBOutlet weak var mostWorkoutsDayLabel: UILabel!
    
    @IBOutlet weak var relaxingView: UserImageView!
    @IBOutlet weak var relaxingLabel: UILabel!
    
    @IBOutlet weak var totalWorkoutsLabel: UILabel!
    @IBOutlet weak var workoutsPerDayLabel: UILabel!
    @IBOutlet weak var daysAllWorkedOutLabel: UILabel!
    @IBOutlet weak var daysNoOneWorkedOutLabel: UILabel!
    
    @IBOutlet weak var daysCompleteLabel: UILabel!
    @IBOutlet weak var daysRemainingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    func wow(_ challenge: Challenge, _ workouts: [Workout], _ users: [Account]) {
        guard !users.isEmpty else { return }
        
        let days = challenge.days

        if challenge.isPast {
            daysCompleteLabel.text = String(days.count)
            daysRemainingLabel.text = String(0)
        } else {
            daysCompleteLabel.text = String(challenge.daysCompletePure)
            daysRemainingLabel.text = String(challenge.daysLeftPure)
        }

        DispatchQueue.global().async {
            let daysWorkoutsBase = days.reduce([:]) { hash, day -> [Date: [Workout]] in
                return hash.merging([day: []], uniquingKeysWith: { _, new in new })
            }
            let workoutsPerDay = Dictionary(grouping: workouts, by: { $0.createdAt.respecting([.day, .month, .year], timeZone: .utc) })
            let bucketed = workoutsPerDay.merging(daysWorkoutsBase, uniquingKeysWith: { old, _ in old }).sorted { (a, b) -> Bool in
                return a.key < b.key
            }
            
            var daysAllPeepsTwerked = 0
            var daysNoPeepsTwerked = 0
            var userLookup = [Int: Account]()
            var userToWorkouts = [Account: [Workout]]()
            var userToMostWorkoutsInDay = [Account: Int]()
            var userToDaysRelaxed = [Account: Int]()
            var userToLongestStreak = [Account: Int]()
            var userToCurrentStreak = [Account: Int]()
            
            for user in users {
                userToWorkouts[user] = []
                userToMostWorkoutsInDay[user] = 0
                userToDaysRelaxed[user] = 0
                userLookup[user.id] = user
                userToLongestStreak[user] = 0
                userToCurrentStreak[user] = 0
            }
            
            for (_, workouts) in bucketed {
                if workouts.isEmpty {
                    daysNoPeepsTwerked += 1
                } else if users.allSatisfy({ user -> Bool in
                    return workouts.contains(where: { $0.gymRatsUserId == user.id })
                }) {
                    daysAllPeepsTwerked += 1
                }
                
                var workoutsForTheDay = [Account: Int]()
                for user in users {
                    workoutsForTheDay[user] = 0
                }

                for workout in workouts {
                    if let user = userLookup[workout.gymRatsUserId] {
                        var userWorkouts = userToWorkouts[user]!
                        userWorkouts.append(workout)
                        userToWorkouts[user] = userWorkouts

                        workoutsForTheDay[user] = workoutsForTheDay[user]! + 1
                    }
                }
                
                for user in users {
                    if workoutsForTheDay[user]! > userToMostWorkoutsInDay[user]! {
                        userToMostWorkoutsInDay[user] = workoutsForTheDay[user]
                    }
                    if workoutsForTheDay[user]! == 0 {
                        userToDaysRelaxed[user] = userToDaysRelaxed[user]! + 1
                        
                        let streak = userToCurrentStreak[user]!
                        if streak > userToLongestStreak[user]! {
                            userToLongestStreak[user] = streak
                        }
                        userToCurrentStreak[user] = 0
                    } else {
                        userToCurrentStreak[user] = userToCurrentStreak[user]! + 1
                    }
                }
            }
            
            for user in users {
                let streak = userToCurrentStreak[user]!
                if streak > userToLongestStreak[user]! {
                    userToLongestStreak[user] = streak
                }
            }

            let usersToNumberOfWorkoutsPre9am: [Account: Int] = users.reduce([:]) { hash, user -> [Account: Int] in
                let workouts = userToWorkouts[user]!
                let timeDiff = CGFloat(TimeZone.current.secondsFromGMT()) / CGFloat(3600)
                let datesBefore9amLocalTime = workouts.filter { workout -> Bool in
                    var t = workout.createdAt.hour + Int(timeDiff)
                    
                    if t < 0 {
                        t += 24
                    }
                    
                    if t >= 24 {
                        t -= 24
                    }
                    
                    return t < 9
                }
                
                return hash.merging([user: datesBefore9amLocalTime.count], uniquingKeysWith: { _, new in new })
            }

            let mostWorkoutsUser = userToWorkouts.sorted(by: { $0.value.count > $1.value.count }).first!
            let earlyBird = usersToNumberOfWorkoutsPre9am.sorted(by: { $0.value > $1.value }).first!
            let mostInDayUser = userToMostWorkoutsInDay.sorted(by: { $0.value > $1.value }).first!
            let nakedUser = userToLongestStreak.sorted(by: { $0.value > $1.value }).first!

            DispatchQueue.main.async {
              self.totalWorkoutsLabel.text = "\(workouts.count)"
              self.workoutsPerDayLabel.text = String(format: "%.2f", CGFloat(workouts.count)/CGFloat(challenge.days.count))
              self.daysAllWorkedOutLabel.text = "\(daysAllPeepsTwerked)"
              self.daysNoOneWorkedOutLabel.text = "\(daysNoPeepsTwerked)"
      
              self.mostWorkoutsLabel.text = "\(mostWorkoutsUser.value.count)"
              self.relaxingLabel.text = "\(earlyBird.value)"
              self.mostWorkoutsDayLabel.text = "\(mostInDayUser.value)"
              self.streakLabel.text = "\(nakedUser.value)"
                
              self.mostWorkoutsView.load(mostWorkoutsUser.key)
              self.streakView.load(nakedUser.key)
              self.mostWorkoutsDayView.load(mostInDayUser.key)
              self.relaxingView.load(earlyBird.key)
            }
        }
    }

}

extension Date {
    func respecting(_ dateComponents: Set<Calendar.Component>, timeZone: TimeZone = .current) -> Date {
        let components = Calendar.current.dateComponents(dateComponents, from: self)
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = timeZone
        
        return calendar.date(from: components)!
    }
}
