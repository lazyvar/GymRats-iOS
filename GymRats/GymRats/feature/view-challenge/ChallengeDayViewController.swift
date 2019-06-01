//
//  ChallengeDayViewController.swift
//  GymRats
//
//  Created by Mack on 5/29/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class ChallengeDayViewController: UITableViewController {
    
    let date: Date
    let userWorkouts: [UserWorkout]
    let challenge: Challenge
    
    private var showRows = false
    
    init(date: Date, userWorkouts: [UserWorkout], challenge: Challenge) {
        self.date = date
        self.userWorkouts = userWorkouts
        self.challenge = challenge
        
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "UserWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "UserWorkoutCell")
    }
    
    func loadData() {
        guard !showRows else { return }
        
        self.showRows = true
        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }

}

extension ChallengeDayViewController {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .bigAndBlack
        
        if date.isToday {
            label.text = "Today"
        } else if date.isYesterday {
            label.text = "Yesterday"
        } else {
            label.text = date.toFormat("EEEE, MMM d")
        }
        
        container.addSubview(label)
        
        container.addConstraint(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 8))
        label.verticallyCenter(in: container)
        
        container.constrainHeight(40)
        
        return container
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserWorkoutCell") as! UserWorkoutTableViewCell
        let userWorkout = userWorkouts[indexPath.row]
        
        cell.userWorkout = userWorkout
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard showRows else { return 0 }
        
        return userWorkouts.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let userWorkout = userWorkouts[indexPath.row]
        
        if let workout = userWorkout.workout {
            let workoutViewController = WorkoutViewController(user: userWorkout.user, workout: workout, challenge: challenge)
            
            push(workoutViewController)
        } else {
            let profileViewController = ProfileViewController(user: userWorkout.user, challenge: challenge)
            
            push(profileViewController)
        }
    }


}
