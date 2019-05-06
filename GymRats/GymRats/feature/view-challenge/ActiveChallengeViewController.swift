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
import YogaKit
import SwiftDate
import EasyNotificationBadge

struct UserWorkout {
    let user: User
    let workout: Workout?
}

class ActiveChallengeViewController: UITableViewController {

    let disposeBag = DisposeBag()
    let challenge: Challenge
    let refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        return refreshControl
    }()

    var users: [User] = []
    var workouts: [Workout] = []

    var currentDate: BehaviorRelay<Date> = BehaviorRelay<Date>(value: Date())
    
    var userWorkoutsForCurrentDate: [UserWorkout] = []
    
    let goBackInTimeButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "left-arrow"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        return button
    }()

    let goForwardInTimeButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "right-arrow"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        return button
    }()
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var newWorkoutItem = UIBarButtonItem (
        image: UIImage(named: "kettle-bell"),
        style: .plain,
        target: self,
        action: #selector(presentNewWorkoutViewController)
    )
    
    lazy var chatItem = UIBarButtonItem (
        image: UIImage(named: "chat")?.withRenderingMode(.alwaysOriginal),
        style: .plain,
        target: self,
        action: #selector(openChat)
    )

    var tableViewAnimation: UITableView.RowAnimation = .fade
    
    init(challenge: Challenge) {
        self.challenge = challenge
        
        super.init(nibName: nil, bundle: nil)
        
        // ActiveChallengeViewController.timeZone = challenge.timeZone
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackButton()
        
        navigationItem.rightBarButtonItems = [newWorkoutItem, chatItem]
        
        let bg = UIView(frame: CGRect(x: 0, y: -1000, width: self.tableView.frame.width, height: 1000))
        bg.backgroundColor = .eeeeee
        
        tableView.addSubview(bg)
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "UserWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "UserWorkoutCell")

        refresher.addTarget(self, action: #selector(fetchUserWorkouts), for: .valueChanged)
        
        tableView.addSubview(refresher)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("WorkoutDeleted"), object: nil, queue: nil) { notification in
            self.fetchUserWorkouts()
        }
        
        let imageView = UserImageView()
        imageView.load(avatarInfo: challenge)
        imageView.constrainWidth(34)
        imageView.constrainHeight(34)

        navigationItem.titleView = imageView

        let container = UIView()
        
        let headerView = UIView()
        headerView.backgroundColor = .eeeeee
        
        headerView.configureLayout { layout in
            layout.isEnabled = true
            layout.padding = 10
            layout.alignContent = .center
            layout.justifyContent = .center
            layout.flexDirection = .column
            layout.width = YGValue(self.tableView.frame.width)
        }
        
        let challengeName = UILabel()
        challengeName.font = .body
        challengeName.textAlignment = .center
        challengeName.text = challenge.name
        challengeName.textColor = .dark
        
        challengeName.configureLayout { layout in
            layout.isEnabled = true
        }
        
        let difference = Date().getInterval(toDate: challenge.endDate, component: .day)
        
        let daysLeft = UILabel()
        daysLeft.font = .details
        daysLeft.textAlignment = .center
        daysLeft.textColor = .dark

        if difference == 0 {
            daysLeft.text =  "Last day"
        } else {
            daysLeft.text =  "\(difference) days remaining"
        }
        
        daysLeft.configureLayout { layout in
            layout.isEnabled = true
        }
        
        headerView.addSubview(challengeName)
        headerView.addSubview(daysLeft)
        
        headerView.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: .flexibleHeight)

        let tap = UITapGestureRecognizer(target: self, action: #selector(presentChallengeInfo))
        tap.numberOfTapsRequired = 1
        
        headerView.addGestureRecognizer(tap)
        headerView.isUserInteractionEnabled = true
        
        let chevronImage = UIImage(named: "chevron-right")!.withRenderingMode(.alwaysTemplate)
        let chevronImageView = UIImageView(image: chevronImage)
        chevronImageView.tintColor = .dark
        chevronImageView.contentMode = .center
        
        headerView.addSubview(chevronImageView)
        
        headerView.addConstraintsWithFormat(format: "H:[v0]-10-|", views: chevronImageView)
        headerView.addConstraintsWithFormat(format: "V:|[v0]|", views: chevronImageView)

        container.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.width = YGValue(self.tableView.frame.width)
        }
    
        let dateContainer = UIView()
        
        dateContainer.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .row
            layout.width = YGValue(self.tableView.frame.width)
            layout.padding = 10
        }

        goBackInTimeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.flexShrink = 1
        }

        dayLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.flexGrow = 1
        }

        goForwardInTimeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.flexShrink = 1
        }

        dateContainer.addSubview(goBackInTimeButton)
        dateContainer.addSubview(dayLabel)
        dateContainer.addSubview(goForwardInTimeButton)
        dateContainer.addDivider()
        
        dateContainer.yoga.applyLayout(preservingOrigin: true)
        
        container.addSubview(headerView)
        container.addSubview(dateContainer)

        container.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: .flexibleHeight)

        tableView.tableHeaderView = container
        
        goBackInTimeButton.onTouchUpInside { [weak self] in
            guard let self = self else { return }
            
            self.tableViewAnimation = .right
            self.currentDate.accept(self.currentDate.value - 1.days)
        }.disposed(by: disposeBag)
        
        goForwardInTimeButton.onTouchUpInside { [weak self] in
            guard let self = self else { return }
            
            self.tableViewAnimation = .left
            self.currentDate.accept(self.currentDate.value + 1.days)
        }.disposed(by: disposeBag)

        currentDate
            .asObservable()
            .map { $0.isToday }
            .bind(to: goForwardInTimeButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        currentDate
            .asObservable()
            .map {
                if $0.isToday {
                    return "Today"
                } else {
                    return $0.toFormat("MMM d")
                }
            }
            .bind(to: dayLabel.rx.text)
            .disposed(by: disposeBag)
        
        currentDate
            .asObservable()
            .subscribe { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .next:
                    self.updateUserWorkoutsForCurrentDate()
                    self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: self.tableViewAnimation)
                case .error:
                    // TODO
                    break
                default:
                    break
                }
            }.disposed(by: disposeBag)
        
        currentDate.accept(Date())
        
        fetchUserWorkouts()
    }
    
    @objc func fetchUserWorkouts() {
        let users = gymRatsAPI.getUsers(for: challenge)
        let workouts = gymRatsAPI.getWorkouts(for: challenge)
        
        showLoadingBar()
        
        Observable.zip(users, workouts).subscribe(onNext: { zipped in
            let (users, workouts) = zipped
            
            self.users = users
            self.workouts = workouts
            
            self.updateUserWorkoutsForCurrentDate()
            
            self.hideLoadingBar()
            self.refresher.endRefreshing()
            self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .fade)
        }, onError: { error in
            // TODO
            self.hideLoadingBar()
            self.refresher.endRefreshing()
        }).disposed(by: disposeBag)
    }

    @objc func presentChallengeInfo() {
        let challengeInfo = ChallengeInfoViewController(challenge: challenge, workouts: workouts, users: users)
        let drawer = GymRatsApp.coordinator.drawer
        
        drawer?.rightDrawerViewController = challengeInfo
        drawer?.open(.right, animated: true, completion: nil)
    }
    
    @objc func openChat() {
        push(ChatViewController(challenge: challenge))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshChatIcon()
    }
    
    func refreshChatIcon() {
        gymRatsAPI.getUnreadChats(for: challenge)
            .subscribe { event in
                switch event {
                case .next(let chats):
                    if chats.isEmpty {
                        self.chatItem.image = UIImage(named: "chat")
                    } else {
                        self.chatItem.image = UIImage(named: "chat-unread")?.withRenderingMode(.alwaysOriginal)
                    }
                default: break
                }
            }.disposed(by: disposeBag)
    }
    
    func updateUserWorkoutsForCurrentDate() {
        let workoutsForToday = self.workouts.workouts(on: self.currentDate.value)
        
        self.userWorkoutsForCurrentDate = users.flatMap({ (user: User) -> [UserWorkout] in
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserWorkoutCell") as! UserWorkoutTableViewCell
        let userWorkout = userWorkoutsForCurrentDate[indexPath.row]
        
        cell.userWorkout = userWorkout
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
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
            let workoutViewController = WorkoutViewController(user: userWorkout.user, workout: workout, challenge: challenge)
            
            push(workoutViewController)
        } else {
            let profileViewController = ProfileViewController(user: userWorkout.user, challenge: challenge)
            
            push(profileViewController)
        }
    }
    
}
