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

    let disposeBag = DisposeBag()
    
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
        
        setupForHome()
        
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
            nav.navigationBar.turnBrandColorSlightShadow()
            
            self?.present(nav, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        fetchAllChallenges()
    }

    func fetchAllChallenges() {
        retryButton.isHidden = true
        showLoadingBar()
        
        gymRatsAPI.getAllChallenges()
            .subscribe(onNext: { [weak self] challenges in
                self?.hideLoadingBar()
                
                let activeChallenges = challenges.getActiveChallenges()
                
                if activeChallenges.isEmpty {
                    self?.showEmptyState(challenges: challenges)
                } else {
                    if activeChallenges.count > 1 {
                        // memeber of multiple active challenges
                        self?.showMulitpleChallenges(challenges: activeChallenges)
                    } else {
                        // member on single active challenge
                        self?.showSingleChallenge(challenge: activeChallenges[0])
                    }
                }
            }, onError: { [weak self] error in
                // TODO
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
    
    func showSingleChallenge(challenge: Challenge) {
        let challengeViewController = ActiveChallengeViewController(challenge: challenge)
        let nav = GRNavigationController(rootViewController: challengeViewController)
        nav.navigationBar.turnBrandColorSlightShadow()
        challengeViewController.setupForHome()
        
        GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
    }
    
    func showMulitpleChallenges(challenges: [Challenge]) {
        let challengesViewController = MultipleActiveChallengesViewController(challenges: challenges)
        let nav = GRNavigationController(rootViewController: challengesViewController)
        nav.navigationBar.turnBrandColorSlightShadow()
        challengesViewController.setupForHome()
        
        GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
    }
}

extension HomeViewController: CreateChallengeDelegate {
    
    func challengeCreated(challenge: Challenge) {
        self.fetchAllChallenges()
    }
    
}
