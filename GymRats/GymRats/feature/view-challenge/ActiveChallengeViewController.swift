//
//  ActiveChallengeViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct UserWorkout {
    let user: User
    let workout: Workout?
}

class ActiveChallengeViewController: UITableViewController {

    static var timeZone: String = TimeZone.current.abbreviation()!
    
    let disposeBag = DisposeBag()
    let challenge: Challenge
    let refresher = UIRefreshControl()

    var users: [User] = []
    var workouts: [Workout] = []
    var currentDate = Date()
    
    var userWorkoutsForCurrentDate: [UserWorkout] = []
    
    init(challenge: Challenge) {
        self.challenge = challenge
        
        super.init(nibName: nil, bundle: nil)
        
        ActiveChallengeViewController.timeZone = challenge.timeZone
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "UserWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "UserWorkoutCell")

        refresher.addTarget(self, action: #selector(reload), for: .valueChanged)
        
        tableView.addSubview(refresher)
        
        reload()
    }
    
    @objc func reload() {
        let users = gymRatsAPI.getUsers(for: challenge)
        let workouts = gymRatsAPI.getWorkouts(for: challenge)
        
        refresher.beginRefreshing()
        
        Observable.zip(users, workouts).subscribe(onNext: { zipped in
            let (users, workouts) = zipped
            
            self.users = users
            self.workouts = workouts
            
            self.updateUserWorkoutsForCurrentDate()
            
            self.refresher.endRefreshing()
            self.tableView.reloadData()
        }, onError: { error in
            self.refresher.endRefreshing()
            print(error)
        }).disposed(by: disposeBag)
    }
    
    func updateUserWorkoutsForCurrentDate() {
        let workoutsForToday = self.workouts.workouts(on: self.currentDate)
        
        self.userWorkoutsForCurrentDate = users.map({ (user: User) -> UserWorkout in
            let workout = workoutsForToday.first(where: { $0.userId == user.id })
            
            return UserWorkout(user: user, workout: workout)
        }).sorted(by: { a, b in
            if let aWorkout = a.workout, let bWorkout = b.workout {
                return aWorkout.date > bWorkout.date
            } else if a.workout != nil {
                return true
            } else if b.workout != nil  {
                return false
            } else {
                return a.user.fullName < b.user.fullName
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserWorkoutCell") as! UserWorkoutTableViewCell
        let userWorkout = userWorkoutsForCurrentDate[indexPath.row]
        
        cell.userWorkout = userWorkout
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userWorkoutsForCurrentDate.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let userWorkout = userWorkoutsForCurrentDate[indexPath.row]
        
        if let workout = userWorkout.workout {
            let workoutViewController = WorkoutViewController(user: userWorkout.user, workout: workout)
            
            push(workoutViewController)
        } else {
            let profileViewController = ProfileViewController(user: userWorkout.user)
            
            push(profileViewController)
        }
    }
    
}
