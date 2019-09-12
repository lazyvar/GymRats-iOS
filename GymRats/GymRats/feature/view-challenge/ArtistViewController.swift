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
import Kingfisher

class ArtistViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let challenge: Challenge
    
    var userWorkouts: [UserWorkout] = []
    var users: [User] = []
    var workouts: [Workout] = []
    var useMe: [Date] = []
    
    lazy var tableView: UITableView! = {
        let tb = UITableView(frame: .zero, style: .grouped)
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.delegate = self
        tb.dataSource = self
        tb.backgroundColor = .white
        
        view.addSubview(tb)
    
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: tb, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tb, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tb, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tb, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        ])

        return tb
    }()
    
    init(challenge: Challenge) {
        self.challenge = challenge
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        tableView.separatorStyle = .none
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.view.backgroundColor = UIColor.white
        navigationItem.largeTitleDisplayMode = .never
        
        refresher.addTarget(self, action: #selector(fetchUserWorkouts), for: .valueChanged)
        tableView.addSubview(refresher)
        
        let more = UIImage(named: "more-vertical")?.withRenderingMode(.alwaysTemplate)
        let menu = UIBarButtonItem(image: more, landscapeImagePhone: nil, style: .plain, target: nil, action: nil)
        menu.tintColor = .lightGray
        
        var rightItems = [menu]
        
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UINib(nibName: "GoatCell", bundle: nil), forCellReuseIdentifier: "goat")
        tableView.register(UINib(nibName: "TwerkoutCell", bundle: nil), forCellReuseIdentifier: "twer")
        tableView.register(UINib(nibName: "LeaderboardCell", bundle: nil), forCellReuseIdentifier: "ld")

        fetchUserWorkouts()
        setupBackButton()

        if challenge.isPast {
            rightItems.append(UIBarButtonItem(image: UIImage(named: "chat-gray"), style: .plain, target: self, action: #selector(openChat)))
        } else {
            // setupMenuButton()
        }
        
        navigationItem.rightBarButtonItems = rightItems
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("WorkoutDeleted"), object: nil, queue: nil) { notification in
            self.fetchUserWorkouts()
        }
    }
    
    @objc func openChat() {
        push(ChatViewController(challenge: challenge), animated: true)
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
            
            self.useMe = self.challenge.daysWithWorkouts(workouts: workouts)
            
            UserDefaults.standard.set(users.count, forKey: "\(self.challenge.id)_user_count")
            
            self.hideLoadingBar()
            self.refresher.endRefreshing()

            UIView.transition(with: self.tableView,
                              duration: 0.222,
                              options: .transitionCrossDissolve,
                              animations: { self.tableView.reloadData() })
        }, onError: { _ in
            self.refresher.endRefreshing()
            self.hideLoadingBar()
        }).disposed(by: disposeBag)
    }
    
    func userWorkouts(for date: Date) -> [UserWorkout] {
        let workoutsForToday = self.workouts.workouts(on: date)
        
        return users.flatMap({ (user: User) -> [UserWorkout] in
            let workouts = workoutsForToday.filter { $0.gymRatsUserId == user.id }
            
            if workouts.isEmpty {
                return [UserWorkout(user: user, workout: nil)]
            } else {
                return workouts.map { UserWorkout(user: user, workout: $0) }
            }
        }).sorted(by: { a, b in
            if let aWorkout = a.workout, let bWorkout = b.workout {
                return aWorkout.createdAt > bWorkout.createdAt
            } else if a.workout != nil {
                return true
            } else if b.workout != nil  {
                return false
            } else {
                return a.user.fullName < b.user.fullName
            }
        })
    }
    
    private func detailsLabelText(user: User) -> NSAttributedString {
        let details = NSMutableAttributedString()
        
        if let profilePic = user.profilePictureUrl, let image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: profilePic) ?? KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: profilePic) {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: 14, height: 14)
            imageView.layer.cornerRadius = 7
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            
            let image = imageView.imageFromContext()
            
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: -3, width: 14, height: 14)
            
            details.append(NSAttributedString(attachment: attachment))
            details.append(NSAttributedString(string: " "))
        }
        
        details.append(NSAttributedString(string: "\(user.fullName)"))
        
        return details
    }
    
}

extension ArtistViewController: UITableViewDelegate, UITableViewDataSource {
    
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section > 0 else { return 0 }
        
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if users.isEmpty && indexPath.section > 0 {
            return 0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0 else { return nil }
        
        let label = UILabel()
        label.frame = CGRect(x: 20, y: 0, width: view.frame.width, height: 30)
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.backgroundColor = .white
        
        switch section {
        case 1:
            if isSoloChallenge {
                label.text = "Workouts"
            } else {
                label.text = "Leaderboard"
            }
        default:
            if !isSoloChallenge && section == 2 {
                label.text = "Workouts"
            } else {
                let date = useMe[section-fluffCount]
                
                label.font = .systemFont(ofSize: 16, weight: .bold)
                label.text = date.toFormat("EEEE, MMM d")
            }
        }
        
        let headerView = UIView()
        headerView.addSubview(label)
        
        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isSoloChallenge {
            guard indexPath.section > 1 else { return }
        } else {
            guard indexPath.section > 2 else { return }
        }
        
        let date = useMe[indexPath.section-fluffCount]
        let workouts = self.userWorkouts(for: date).filter { $0.workout != nil }
        let workout = workouts[indexPath.row].workout!
        let user = users.first(where: { $0.id == workout.gymRatsUserId })!
        
        self.push(WorkoutViewController(user: user, workout: workout, challenge: challenge))
    }

    var isSoloChallenge: Bool {
        return users.count == 1
    }
    
    var fluffCount: Int {
        if isSoloChallenge {
            return 2
        } else {
            return 3
        }
    }
    
    var noWorkouts: Bool {
        return workouts.isEmpty && !users.isEmpty
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fluffCount + useMe.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSoloChallenge {
            switch section {
            case 0:
                return 1
            case 1:
                if noWorkouts {
                    return 1
                } else {
                    return 0
                }
            default:
                let date = useMe[section-fluffCount]
                return self.userWorkouts(for: date).filter { $0.workout != nil }.count
            }
        } else {
            switch section {
            case 0:
                return 1
            case 1:
                return 1
            case 2:
                if noWorkouts {
                    return 1
                } else {
                    return 0
                }
            default:
                let date = useMe[section-fluffCount]
                return self.userWorkouts(for: date).filter { $0.workout != nil }.count
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        
        if isSoloChallenge {
            switch section {
            case 0:
                return goatCell(tableView)
            case 1:
                if noWorkouts {
                    return noWorkoutsCell()
                } else {
                    return UITableViewCell()
                }
            default:
                let date = useMe[section-fluffCount]
                return twerkoutCell(tableView, date: date, row: indexPath.row)
            }
        } else {
            switch section {
            case 0:
                return goatCell(tableView)
            case 1:
                return leaderboardCell(tableView)
            case 2:
                if noWorkouts {
                    return noWorkoutsCell()
                } else {
                    return UITableViewCell()
                }
            default:
                let date = useMe[section-fluffCount]
                return twerkoutCell(tableView, date: date, row: indexPath.row)
            }
        }
    }
    
    func noWorkoutsCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "  None posted yet. "
        cell.selectionStyle = .none
        
        return cell
    }

    func goatCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goat") as! GoatCell
        
        let skeletonView = UIView()
        skeletonView.isSkeletonable = true
        skeletonView.showAnimatedSkeleton()
        skeletonView.showSkeleton()
        
        cell.titleLabel.text = challenge.name
        cell.picture.kf.setImage(with: URL(string: challenge.pictureUrl!)!, placeholder: skeletonView, options: [.transition(.fade(0.2))])
        cell.selectionStyle = .none
        
        if users.count == 0 {
            cell.usersLabel.text = "-\nmembers"
        } else if users.count == 1 {
            cell.usersLabel.text = "Solo\nchallenge"
        } else {
            cell.usersLabel.text = "\(users.count)\nmembers"
        }
        
        if workouts.count == 0 {
            cell.activityLabel.text = "-\nworkouts"
        } else if workouts.count == 1 {
            cell.activityLabel.text = "1\nworkout"
        } else {
            cell.activityLabel.text = "\(workouts.count)\nworkouts"
        }
        
        let daysLeft = challenge.daysLeft.split(separator: " ")
        let new = daysLeft[0]
        let left = daysLeft[daysLeft.startIndex+1..<daysLeft.endIndex]
        let left2 = left.joined(separator: " ")
        let ok = new + "\n" + left2
        
        cell.calLabel.text = ok
        
        return cell
    }
    
    func leaderboardCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ld") as! LeaderboardCell
        cell.onTap = { user in
            self.push(ProfileViewController(user: user, challenge: self.challenge), animated: true)
        }
        cell.selectionStyle = .none
        cell.workouts = workouts
        cell.users = users.sorted(by: { a, b -> Bool in
            let workoutsA = self.workouts.filter { $0.gymRatsUserId == a.id }.count
            let workoutsB = self.workouts.filter { $0.gymRatsUserId == b.id }.count
            
            return workoutsA > workoutsB
        })
        
        return cell
    }
    
    func twerkoutCell(_ tableView: UITableView, date: Date, row: Int) -> UITableViewCell {
        let workouts = userWorkouts(for: date).filter { $0.workout != nil }
        let cell = tableView.dequeueReusableCell(withIdentifier: "twer") as! TwerkoutCell
        let workout = workouts[row].workout!
        let user = users.first(where: { $0.id == workout.gymRatsUserId })!
        
        cell.selectionStyle = .default
        cell.twerk.kf.setImage(with: URL(string: workout.photoUrl ?? ""), options: [.transition(.fade(0.2))])
        cell.tit.text = workout.title
        cell.det.isHidden = workout.description == nil
        cell.det.text = workout.description
        cell.little.attributedText = detailsLabelText(user: user)
        cell.lil.text = "\(workout.createdAt.challengeTime)"
        
        return cell
    }

}

extension UIView: Placeholder { }
