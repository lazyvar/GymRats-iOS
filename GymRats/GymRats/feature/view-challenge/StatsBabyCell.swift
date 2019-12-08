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
    
    func wow(_ challenge: Challenge, _ workouts: [Workout], _ users: [User]) {
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
            let workoutsPerDay = Dictionary(grouping: workouts, by: { $0.createdAt.respecting([.day, .month, .year]) })
            let bucketed = workoutsPerDay.merging(daysWorkoutsBase, uniquingKeysWith: { old, _ in old }).sorted { (a, b) -> Bool in
                return a.key < b.key
            }

            let users = users.filter {
                if workouts.contains(where: { $0.gymRatsUserId == 9 }) {
                    return true
                } else {
                    return $0.id != 9
                }
            }
            
            var daysAllPeepsTwerked = 0
            var daysNoPeepsTwerked = 0
            var userLookup = [Int: User]()
            var userToWorkouts = [User: [Workout]]()
            var userToMostWorkoutsInDay = [User: Int]()
            var userToDaysRelaxed = [User: Int]()
            var userToLongestStreak = [User: Int]()
            var userToCurrentStreak = [User: Int]()
            
            for user in users {
                userToWorkouts[user] = []
                userToMostWorkoutsInDay[user] = 0
                userToDaysRelaxed[user] = 0
                userLookup[user.id] = user
                userToLongestStreak[user] = 0
                userToCurrentStreak[user] = 0
            }
            
            for (day, workouts) in bucketed {
                if workouts.isEmpty {
                    daysNoPeepsTwerked += 1
                } else if users.allSatisfy({ user -> Bool in
                    return workouts.contains(where: { $0.gymRatsUserId == user.id })
                }) {
                    daysAllPeepsTwerked += 1
                }
                
                var workoutsForTheDay = [User: Int]()
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
            
            let mostWorkoutsUser = userToWorkouts.sorted(by: { $0.value.count > $1.value.count }).first!
            let mostRelaxedUser = userToDaysRelaxed.sorted(by: { $0.value > $1.value }).first!
            let mostInDayUser = userToMostWorkoutsInDay.sorted(by: { $0.value > $1.value }).first!
            let nakedUser = userToLongestStreak.sorted(by: { $0.value > $1.value }).first!

            DispatchQueue.main.async {
                self.totalWorkoutsLabel.text = "\(workouts.count)"
                self.workoutsPerDayLabel.text = String(format: "%.2f", CGFloat(workouts.count)/CGFloat(challenge.days.count))
                self.daysAllWorkedOutLabel.text = "\(daysAllPeepsTwerked)"
                self.daysNoOneWorkedOutLabel.text = "\(daysNoPeepsTwerked)"
        
                self.mostWorkoutsLabel.text = "\(mostWorkoutsUser.value.count)"
                self.relaxingLabel.text = "\(mostRelaxedUser.value)"
                self.mostWorkoutsDayLabel.text = "\(mostInDayUser.value)"
                self.streakLabel.text = "\(nakedUser.value)"
                
                self.mostWorkoutsView.load(avatarInfo: mostWorkoutsUser.key)
                self.streakView.load(avatarInfo: nakedUser.key)
                self.mostWorkoutsDayView.load(avatarInfo: mostInDayUser.key)
                self.relaxingView.load(avatarInfo: mostRelaxedUser.key)
            }
        }
    }
    
}

extension Date {
    func respecting(_ dateComponents: Set<Calendar.Component>) -> Date {
        let components = Calendar.current.dateComponents(dateComponents, from: self)
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .utc
        
        return calendar.date(from: components)!
    }
}
