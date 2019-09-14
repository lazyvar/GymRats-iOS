//
//  ChallengeInfoViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/11/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import MMDrawerController
import YogaKit
import RxSwift

class ChallengeInfoViewController: UITableViewController {
    
    private let disposeBag = DisposeBag()
    
    let challenge: Challenge
    let workouts: [Workout]
    let members: [User]
    
    init(challenge: Challenge, workouts: [Workout], users: [User]) {
        self.workouts = workouts
        self.members = users
        self.challenge = challenge
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "UserWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "ChallengeUserCell")
        
        let containerView = UIView()
        
        containerView.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.justifyContent = .flexStart
            layout.alignContent = .flexStart
            layout.width = 280
            layout.paddingTop = 10
            layout.padding = 10
        }

        let imageView = UserImageView()
        imageView.load(avatarInfo: challenge)
        
        imageView.configureLayout { layout in
            layout.isEnabled = true
            layout.width = 80
            layout.height = 80
            layout.margin = 5
        }
        
        let imageViewContainer = UIView()
        
        imageViewContainer.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .row
            layout.alignContent = .center
            layout.justifyContent = .center
        }
        
        let challengeNameLabel = UILabel()
        challengeNameLabel.font = .body
        challengeNameLabel.textAlignment = .center
        challengeNameLabel.textColor = .black
        challengeNameLabel.text = challenge.name
        
        challengeNameLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 5
        }

        let codeLabel = UILabel()
        codeLabel.font = .details
        codeLabel.textAlignment = .center
        codeLabel.text = "Join code: \(challenge.code)"
        
        codeLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 5
        }
        
        imageViewContainer.addSubview(imageView)
        
        imageViewContainer.yoga.applyLayout(preservingOrigin: true)
        
        let daysLeft = UILabel()
        daysLeft.font = .details
        daysLeft.textAlignment = .center
        
        let difference = Date().localDateIsDaysApartFromUTCDate(challenge.endDate)
        
        if difference > 0 {
            daysLeft.text = "Completed on \(challenge.endDate.toFormat("MMM d, yyyy"))"
        } else if difference < 0 {
            let diff = abs(difference)
            
            if diff == 1 {
                daysLeft.text = "1 day remaining (\(challenge.endDate.toFormat("MMM d")))"
            } else {
                daysLeft.text = "\(diff) days remaining (\(challenge.endDate.toFormat("MMM d")))"
            }
        } else {
            daysLeft.text = "Last day (\(challenge.endDate.toFormat("MMM d")))"
        }
        
        daysLeft.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 5
        }

        let leaveChallengeButton = UIButton()
        leaveChallengeButton.backgroundColor = .firebrick
        leaveChallengeButton.setTitle("Leave Challenge", for: .normal)
        leaveChallengeButton.setTitleColor(.white, for: .normal)
        leaveChallengeButton.titleLabel?.font = .body
        leaveChallengeButton.layer.cornerRadius = 8
        leaveChallengeButton.clipsToBounds = true
        
        leaveChallengeButton.onTouchUpInside { [weak self] in
            self?.showAlert()
        }.disposed(by: disposeBag)
        
        leaveChallengeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 10
            layout.marginBottom = 5
            layout.marginLeft = 30
            layout.marginRight = 30
            layout.height = YGValue(30)
        }

        containerView.addSubview(imageViewContainer)
        containerView.addSubview(challengeNameLabel)
        containerView.addSubview(codeLabel)
        containerView.addSubview(daysLeft)
        containerView.addSubview(leaveChallengeButton)

        containerView.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: .flexibleHeight)

        tableView.tableHeaderView = containerView
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Are you sure you want to leave \(challenge.name)?", message: nil, preferredStyle: .actionSheet)
        let leave = UIAlertAction(title: "Leave", style: .destructive) { _ in
            self.showLoadingBar()
            gymRatsAPI.leaveChallenge(self.challenge)
                .subscribe({ e in
                    self.hideLoadingBar()
                    switch e {
                    case .next:
                        if let nav = GymRatsApp.coordinator.drawer.centerViewController as? UINavigationController {
                            // MACK
                            if let home = nav.children.first as? HomeViewController {
                                home.fetchAllChallenges()
                                
                                GymRatsApp.coordinator.drawer.closeDrawer(animated: true, completion: nil)
                            } else {
                                let center = HomeViewController()
                                let nav = GRNavigationController(rootViewController: center)
                                
                                GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
                            }
                        }
                    case .error(let error):
                        self.presentAlert(with: error)
                    case .completed:
                        break
                    }
                }).disposed(by: self.disposeBag)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(leave)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Top Rats"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeUserCell") as! UserWorkoutTableViewCell
        let usersRanked = members.map { user in
            return (user: user, workouts: workouts.filter({ $0.gymRatsUserId == user.id }))
        }.sorted { a, b in
            return a.workouts.count > b.workouts.count
        }
        
        let user = usersRanked[indexPath.row].user
        let numberOfWorkouts = usersRanked[indexPath.row].workouts.count
        
        cell.configure(for: user, withNumberOfWorkouts: numberOfWorkouts)
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let usersRanked = members.map { user in
            return (user: user, workouts: workouts.filter({ $0.gymRatsUserId == user.id }))
        }.sorted { a, b in
            return a.workouts.count > b.workouts.count
        }
        
        let user = usersRanked[indexPath.row].user
        
        GymRatsApp.coordinator.drawer.closeDrawer(animated: true) { _ in
            let center = GymRatsApp.coordinator.drawer.centerViewController
            let profile = ProfileViewController(user: user, challenge: self.challenge)
            
            if let center = center as? GRNavigationController {
                center.push(profile, animated: true)
            }
        }
    }

}
