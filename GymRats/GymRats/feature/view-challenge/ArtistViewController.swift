//
//  ArtistViewController.swift
//  GymRats
//
//  Created by Mack on 9/8/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ArtistViewController: UITableViewController {
    
    let disposeBag = DisposeBag()
    let challenge: Challenge
    
    var userWorkouts: [UserWorkout] = []
    var members: [User] = []

    var users: [User] = []
    var workouts: [Workout] = []
    
    init(challenge: Challenge) {
        self.challenge = challenge
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = challenge.name
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        tableView.separatorStyle = .none
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.view.backgroundColor = UIColor.white
        
        tableView.register(UINib(nibName: "GoatCell", bundle: nil), forCellReuseIdentifier: "goat")
        
        setupBackButton()
        fetchUserWorkouts()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("WorkoutDeleted"), object: nil, queue: nil) { notification in
            self.fetchUserWorkouts()
        }
    }
    
    @objc func fetchUserWorkouts() {
        let users = gymRatsAPI.getUsers(for: challenge)
        let workouts = gymRatsAPI.getWorkouts(for: challenge)
        
        showLoadingBar()
        
        Observable.zip(users, workouts).subscribe(onNext: { zipped in
            let (users, workouts) = zipped
            
            self.users = users
            self.workouts = workouts
            
            UserDefaults.standard.set(users.count, forKey: "\(self.challenge.id)_user_count")
            
            self.hideLoadingBar()
            self.tableView.reloadData()
        }, onError: { error in
            // TODO
            self.hideLoadingBar()
        }).disposed(by: disposeBag)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 0
        case 2:
            return 0 // workouts.count
        default:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goat") as! GoatCell
        
        cell.picture.kf.setImage(with: URL(string: challenge.pictureUrl!)!)
        cell.selectionStyle = .none
        cell.usersLabel.text = "\(users.count)\nmembers"
        cell.activityLabel.text = "\(workouts.count)\nworkouts"

        let daysLeft = challenge.daysLeft.split(separator: " ")
        let new = daysLeft[0]
        let left = daysLeft[daysLeft.startIndex+1..<daysLeft.endIndex]
        let left2 = left.joined(separator: " ")
        let ok = new + "\n" + left2
        
        cell.calLabel.text = ok
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section > 0 else { return 0 }

        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0 else { return nil }
        
        let label = UILabel()
        label.frame = CGRect(x: 20, y: 8, width: 320, height: 20)
        label.font = .systemFont(ofSize: 20, weight: .bold)
    
        switch section {
        case 1:
            label.text = "Leaderboard"
        case 2:
            label.text = "Workouts"
        default:
            break
        }
        
        let headerView = UIView()
        headerView.addSubview(label)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
