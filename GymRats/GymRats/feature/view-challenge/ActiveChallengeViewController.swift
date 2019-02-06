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
    
    let disposeBag = DisposeBag()
    let challenge: Challenge
    
    var userWorkouts: [UserWorkout] = []
    
    let refresher = UIRefreshControl()
    
    init(challenge: Challenge) {
        self.challenge = challenge
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "gr-logo"))
        logoImageView.contentMode = .scaleAspectFit

        navigationItem.titleView = logoImageView

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: nil, action: nil)
        
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
            
            self.userWorkouts = users.map({ (user: User) -> UserWorkout in
                let workout = workouts.first(where: { $0.userId == user.id })
                
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
            self.refresher.endRefreshing()
            self.tableView.reloadData()
        }, onError: { error in
            self.refresher.endRefreshing()
            print(error)
        }).disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserWorkoutCell") as! UserWorkoutTableViewCell
        let userWorkout = userWorkouts[indexPath.row]
        
        cell.userWorkout = userWorkout
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userWorkouts.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // TODO
    }
    
}
