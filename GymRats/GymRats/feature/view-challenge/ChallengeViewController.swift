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
    
    @IBOutlet weak var headerView: UIView! {
        didSet {
            headerView.backgroundColor = .firebrick
        }
    }
    
    lazy var pageboyViewController: PageboyViewController = {
        let pageboyViewController = PageboyViewController()
        pageboyViewController.dataSource = self
        pageboyViewController.delegate = self

        return pageboyViewController
    }()
    
    @IBOutlet weak var sliderContainer: UIView! {
        didSet {
            addChild(pageboyViewController)
            sliderContainer.addSubview(pageboyViewController.view)
            pageboyViewController.didMove(toParent: self)
        }
    }
    
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

        setupMenuButton()
        setupBackButton()
        
        title = "💪"
        
        navigationItem.rightBarButtonItem = chatItem
        fetchUserWorkouts()
    }
    
    @objc func openChat() {
        push(ChatViewController(challenge: challenge))
    }

    @objc func fetchUserWorkouts() {
        let users = gymRatsAPI.getUsers(for: challenge)
        let workouts = gymRatsAPI.getWorkouts(for: challenge)
        
        showLoadingBar()
        
        Observable.zip(users, workouts).subscribe(onNext: { zipped in
            let (users, workouts) = zipped
            
            self.users = users
            self.workouts = workouts
            
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

extension ChallengeViewController: PageboyViewControllerDelegate {
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, willScrollToPageAt index: PageboyViewController.PageIndex, direction: PageboyViewController.NavigationDirection, animated: Bool) {
        
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollTo position: CGPoint, direction: PageboyViewController.NavigationDirection, animated: Bool) {
        
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollToPageAt index: PageboyViewController.PageIndex, direction: PageboyViewController.NavigationDirection, animated: Bool) {

        guard let vc = pageboyViewController.currentViewController as? ChallengeDayViewController else { return }
        
        vc.loadData()
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, didReloadWith currentViewController: UIViewController, currentPageIndex: PageboyViewController.PageIndex) {
        print("WHAT")
    }
    
    
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
        let userWorkouts = self.userWorkouts(for: date)
        let challengeDayViewController = ChallengeDayViewController(date: date, userWorkouts: userWorkouts, challenge: challenge)
        
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
