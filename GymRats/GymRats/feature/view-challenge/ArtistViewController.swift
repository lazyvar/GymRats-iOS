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
        navigationItem.title = challenge.name
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        tableView.separatorStyle = .none
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.view.backgroundColor = UIColor.white
        
        let more = UIImage(named: "more-vertical")?.withRenderingMode(.alwaysTemplate)
        let menu = UIBarButtonItem(image: more, landscapeImagePhone: nil, style: .plain, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = menu
        
        tableView.register(UINib(nibName: "GoatCell", bundle: nil), forCellReuseIdentifier: "goat")
        tableView.register(UINib(nibName: "TwerkoutCell", bundle: nil), forCellReuseIdentifier: "twer")
        tableView.register(UINib(nibName: "LeaderboardCell", bundle: nil), forCellReuseIdentifier: "ld")

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
            
            self.users = users.sorted(by: { a, b -> Bool in
                let workoutsA = self.workouts.filter { $0.gymRatsUserId == a.id }.count
                let workoutsB = self.workouts.filter { $0.gymRatsUserId == b.id }.count
                
                return workoutsA > workoutsB
            })
            
            self.workouts = workouts.sorted(by: { $0.createdAt > $1.createdAt })
            
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
            return 1
        case 2:
            return workouts.count
        default:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
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
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ld") as! LeaderboardCell
            cell.onTap = { user in
                self.navigationController?.pushViewController(ProfileViewController(user: user, challenge: self.challenge), animated: true)
            }
            cell.selectionStyle = .none
            cell.workouts = workouts
            cell.users = users.sorted(by: { a, b -> Bool in
                let workoutsA = self.workouts.filter { $0.gymRatsUserId == a.id }.count
                let workoutsB = self.workouts.filter { $0.gymRatsUserId == b.id }.count
                
                return workoutsA > workoutsB
            })
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "twer") as! TwerkoutCell
            let workout = workouts[indexPath.row]
            let user = users.first(where: { $0.id == workout.gymRatsUserId })!
            cell.selectionStyle = .default

            cell.twerk.kf.setImage(with: URL(string: workout.photoUrl ?? ""))
            cell.tit.text = workout.title
            cell.det.isHidden = workout.description == nil
            cell.det.text = workout.description

            cell.little.text = "\(user.fullName) \(workout.createdAt.challengeTime)"
            
            return cell
        }
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
        
        guard indexPath.section > 1 else { return }
        
        let workout = workouts[indexPath.row]
        let user = users.first(where: { $0.id == workout.gymRatsUserId })!
        
        self.push(WorkoutViewController(user: user, workout: workout, challenge: challenge))
    }
}
