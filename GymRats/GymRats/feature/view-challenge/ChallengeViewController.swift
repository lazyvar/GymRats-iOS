//
//  ChallengeViewController.swift
//  GymRats
//
//  Created by Mack on 5/29/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import Pageboy
import RxSwift
import RxCocoa

struct UserWorkout {
    let user: User
    let workout: Workout?
}

class ChallengeViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    var challenge: Challenge!
    
    @IBOutlet weak var challengeImageView: UserImageView! {
        didSet {
            challengeImageView.load(avatarInfo: challenge)
        }
    }
    
    @IBOutlet weak var challengeTitleLabel: UILabel! {
        didSet {
            challengeTitleLabel.font = .body
            challengeTitleLabel.textColor = .white
            challengeTitleLabel.text = challenge.name
        }
    }
    
    @IBOutlet weak var challengeDetailsLabel: UILabel! {
        didSet {
            challengeDetailsLabel
                .font = .details
            challengeDetailsLabel.textColor = .white
            challengeDetailsLabel.text = challenge.daysLeft
        }
    }
    
    @IBOutlet weak var logWorkoutButton: UIButton! {
        didSet {
            logWorkoutButton.layer.shadowColor = UIColor.black.cgColor
            logWorkoutButton.layer.shadowRadius = 3
            logWorkoutButton.layer.shadowOpacity = 0.3
            logWorkoutButton.layer.cornerRadius = 32
            logWorkoutButton.layer.shadowOffset = CGSize(width: 0, height: 0)
            logWorkoutButton.rx.tap
                .subscribe(onNext: { _ in
                    let newWorkoutViewController = NewWorkoutViewController()
                    newWorkoutViewController.delegate = self
                    
                    self.push(newWorkoutViewController)
                })
                .disposed(by: disposeBag)
        }
    }
    
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView! {
        didSet {
            headerView.backgroundColor = .firebrick
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(presentChallengeInfo))
            
            headerView.addGestureRecognizer(tap)
        }
    }
    
    var pageboyViewController: PageboyViewController {
        return children.first as! PageboyViewController
    }
    
    private var cachedDayViewControllers: [Int: ChallengeDayViewController] = [:]
    
    lazy var chatItem = UIBarButtonItem (
        image: UIImage(named: "chat")?.withRenderingMode(.alwaysOriginal),
        style: .plain,
        target: self,
        action: #selector(openChat)
    )

    var users: [User] = []
    var workouts: [Workout] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageboyViewController.delegate = self
        pageboyViewController.dataSource = self
        pageboyViewController.reloadData()
        
        if challenge.isActive {
            setupMenuButton()
        }
        
        setupBackButton()
        navigationItem.rightBarButtonItem = chatItem
        fetchUserWorkouts()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("WorkoutDeleted"), object: nil, queue: nil) { notification in
            self.cachedDayViewControllers.removeAll()
            self.fetchUserWorkouts()
        }
    }
    
    @objc func openChat() {
        push(ChatViewController(challenge: challenge))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshChatIcon()
    }
    
    @objc func presentChallengeInfo() {
        let challengeInfo = ChallengeInfoViewController(challenge: challenge, workouts: workouts, users: users)
        let drawer = GymRatsApp.coordinator.drawer
        
        drawer?.rightDrawerViewController = challengeInfo
        drawer?.open(.right, animated: true, completion: nil)
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
            self.pageboyViewController.reloadData()
        }, onError: { error in
            // TODO
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

}

extension ChallengeViewController: ChallengeDayViewControllerDelegate {
 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        DispatchQueue.main.async {
            self.headerViewTopConstraint.constant = (-scrollView.contentOffset.y) - 68
        }
    }
    
}

extension ChallengeViewController: NewWorkoutDelegate {
    
    func workoutCreated(workouts: [Workout]) {
        self.cachedDayViewControllers.removeAll()
        self.fetchUserWorkouts()
    }
    
}

extension ChallengeViewController: PageboyViewControllerDelegate {
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollToPageAt index: PageboyViewController.PageIndex, direction: PageboyViewController.NavigationDirection, animated: Bool) {
        guard let vc = pageboyViewController.currentViewController as? ChallengeDayViewController else { return }
        
        if !users.isEmpty {
            vc.loadData()
        }
    }

    func pageboyViewController(_ pageboyViewController: PageboyViewController, didReloadWith currentViewController: UIViewController, currentPageIndex: PageboyViewController.PageIndex) { }
    func pageboyViewController(_ pageboyViewController: PageboyViewController, willScrollToPageAt index: PageboyViewController.PageIndex, direction: PageboyViewController.NavigationDirection, animated: Bool) { }
    func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollTo position: CGPoint, direction: PageboyViewController.NavigationDirection, animated: Bool) { }
}

extension ChallengeViewController: PageboyViewControllerDataSource {
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return challenge.days.count
    }
    
    func viewController (
        for pageboyViewController: PageboyViewController,
        at index: PageboyViewController.PageIndex
    ) -> UIViewController? {
        let date = challenge.days[index]
        var userWorkouts = self.userWorkouts(for: date)
        
        if users.isEmpty {
            var cachedUserCount = UserDefaults.standard.integer(forKey: "\(challenge.id)_user_count")
            if cachedUserCount == 0 { cachedUserCount = 5 }
            
            let dummyUsers = (1...cachedUserCount).map { _ in
                return User(id: 0, email: "", fullName: String.genRandom(minLength: 5, maxLength: 20), profilePictureUrl: nil, token: nil)
            }
            
            userWorkouts = dummyUsers.map { user in
                let workout = Workout(id: 0, gymRatsUserId: 0, challengeId: 0, title: String.genRandom(minLength: 5, maxLength: 20), description: nil, photoUrl: nil, createdAt: Date(), googlePlaceId: nil)
                
                return UserWorkout(user: user, workout: workout)
            }
        }
        
        if let viewController = cachedDayViewControllers[index] {
            viewController.userWorkouts = userWorkouts
            viewController.allWorkouts = workouts
            
            return viewController
        }
        
        let challengeDayViewController = ChallengeDayViewController(date: date, userWorkouts: userWorkouts, allWorkouts: workouts, challenge: challenge)
        challengeDayViewController.delegate = self
        challengeDayViewController.showSkeletonView()
        
        if index == challenge.days.endIndex - 1 && !users.isEmpty {
            challengeDayViewController.loadData()
        }

        cachedDayViewControllers[index] = challengeDayViewController
        
        return challengeDayViewController
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .last
    }

}

extension ChallengeViewController {
    static func create(for challenge: Challenge) -> ChallengeViewController {
        let challengeViewController = ChallengeViewController.loadFromNib(from: .challenge)
        challengeViewController.challenge = challenge
        
        return challengeViewController
    }
}

extension String {
    
    static func genRandom(minLength: Int, maxLength: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        
        return String((minLength..<maxLength).map{ _ in letters.randomElement()! })
    }
    
}
