//
//  HomeViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import GradientLoadingBar

class HomeViewController: UIViewController {

    var challenges: [Challenge] = []
    
    let disposeBag = DisposeBag()
    let refresher = UIRefreshControl()
    let retryButton: UIButton = .danger(text: "Retry")
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .h2
        label.text = "You are not participating in any active challenges."
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()

    let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .body
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()

    let joinChallengeButton: UIButton = .secondary(text: "Join Challenge")
    let createChallengeButton: UIButton = .secondary(text: "Start Challenge")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupBackButton()
        setupMenuButton()
        
        refresher.addTarget(self, action: #selector(fetchAllChallenges), for: .valueChanged)
        
        retryButton.onTouchUpInside { [weak self] in
            self?.fetchAllChallenges()
        }.disposed(by: disposeBag)
        
        joinChallengeButton.onTouchUpInside { [weak self] in
            guard let self = self else { return }
            
            JoinChallenge.presentJoinChallengeModal(on: self)
                .subscribe(onNext: { [weak self] _ in
                    self?.fetchAllChallenges()
            }, onError: { [weak self] error in
                self?.presentAlert(with: error)
            }).disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)

        createChallengeButton.onTouchUpInside { [weak self] in
            let createChallengeViewController = CreateChallengeViewController()
            createChallengeViewController.delegate = self
            
            let nav = GRNavigationController(rootViewController: createChallengeViewController)
            nav.navigationBar.turnSolidWhiteSlightShadow()
            
            self?.present(nav, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        fetchAllChallenges()
    }

    @objc func fetchAllChallenges() {
        retryButton.isHidden = true
        showLoadingBar()
        
        gymRatsAPI.getAllChallenges()
            .subscribe(onNext: { [weak self] challenges in
                self?.hideLoadingBar()
                self?.refresher.endRefreshing()
                
                let activeChallenges = challenges.getActiveAndUpcomingChallenges()
                
                GymRatsApp.coordinator.menu.activeChallenges = activeChallenges
                GymRatsApp.coordinator.menu.tableView.reloadData()

                if activeChallenges.isEmpty {
                    self?.showEmptyState(challenges: challenges)
                } else {
                    let challengeId = UserDefaults.standard.integer(forKey: "last_opened_challenge")
                    let challenge: Challenge
                    
                    if challengeId != 0 {
                        challenge = activeChallenges.first(where: { $0.id == challengeId }) ?? activeChallenges[0]
                    } else {
                        challenge = activeChallenges[0]
                    }

                    GymRatsApp.coordinator.centerActiveOrUpcomingChallenge(challenge)
                }
                
                if let notif = GymRatsApp.coordinator.coldStartNotification {
                    GymRatsApp.coordinator.handleNotification(userInfo: notif)
                    GymRatsApp.coordinator.coldStartNotification = nil
                }
            }, onError: { [weak self] error in
                self?.refresher.endRefreshing()
                self?.hideLoadingBar()
                self?.retryButton.isHidden = false
            }).disposed(by: disposeBag)
    }
    
    func showEmptyState(challenges: [Challenge]) {
        navigationItem.rightBarButtonItem = nil
        
        view.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.justifyContent = .flexStart
            layout.alignContent = .center
            layout.padding = 50
            layout.paddingTop = 60
        }
        
        titleLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }
        
        view.addSubview(titleLabel)

        let upcomingChallengeCount = challenges.getUpcomingChallenges().count
        
        if upcomingChallengeCount > 0 {
            if upcomingChallengeCount == 1 {
                detailsLabel.text = "You have 1 upcoming challenge."
            } else {
                detailsLabel.text = "You have \(upcomingChallengeCount) upcoming challenges."
            }
            
            detailsLabel.configureLayout { layout in
                layout.isEnabled = true
                layout.marginTop = 15
            }
            
            view.addSubview(detailsLabel)
        }
        
        joinChallengeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }
        
        view.addSubview(joinChallengeButton)
        
        createChallengeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }
        
        view.addSubview(createChallengeButton)
        
        view.yoga.applyLayout(preservingOrigin: true)
    }

}

extension HomeViewController: CreateChallengeDelegate {
    
    func challengeCreated(challenge: Challenge) {
        self.fetchAllChallenges()
    }
    
}
