//
//  HomeViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift

class HomeViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    let retryButton: UIButton = .danger(text: "Retry")
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.text = "You are not participating in any active challenges."
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    let joinChallengeButton: UIButton = .primary(text: "Join Challenge")
    let createChallengeButton: UIButton = .primary(text: "Create Challenge")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .whiteSmoke
        setupMenuButton()
        navigationController?.navigationBar.turnBrandColorSlightShadow()
        
        retryButton.onTouchUpInside { [weak self] in
            self?.fetchAllChallenges()
        }.disposed(by: disposeBag)
        
        joinChallengeButton.onTouchUpInside { [weak self] in
            guard let self = self else { return }
            
            JoinChallenge.presentJoinChallengeModal(on: self)
                .subscribe(onNext: { [weak self] _ in
                    self?.fetchAllChallenges()
                }, onError: { [weak self] error in
                    if !(error is SimpleError) {
                        self?.presentAlert(with: error)
                    }
                }).disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)

        createChallengeButton.onTouchUpInside { [weak self] in
            let createChallengeViewController = CreateChallengeViewController()
            createChallengeViewController.delegate = self
            
            let nav = UINavigationController(rootViewController: createChallengeViewController)
            nav.navigationBar.turnBrandColorSlightShadow()
            
            self?.present(nav, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        fetchAllChallenges()
    }

    func fetchAllChallenges() {
        retryButton.isHidden = true
        HUD.show(.progress)
        
        gymRatsAPI.getAllChallenges()
            .subscribe(onNext: { [weak self] challenges in
                HUD.hide()
                
                let activeChallenges = challenges.getActiveChallenges()
                
                if activeChallenges.isEmpty {
                    self?.showEmptyState()
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
                HUD.hide()
                self?.retryButton.isHidden = false
            }).disposed(by: disposeBag)
    }
    
    func showEmptyState() {
        view.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.justifyContent = .center
            layout.alignContent = .center
            layout.padding = 64
        }
        
        titleLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }
        
        joinChallengeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }
        
        createChallengeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }
        
        view.addSubview(titleLabel)
        view.addSubview(joinChallengeButton)
        view.addSubview(createChallengeButton)
        
        view.yoga.applyLayout(preservingOrigin: true)
    }
    
    func showSingleChallenge(challenge: Challenge) {
        let challengeViewController = ActiveChallengeViewController(challenge: challenge)
        let nav = UINavigationController(rootViewController: challengeViewController)
        nav.navigationBar.turnBrandColorSlightShadow()
        challengeViewController.setupMenuButton()
        
        GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: false, completion: nil)
    }
    
    func showMulitpleChallenges(challenges: [Challenge]) {
        
    }
}

extension HomeViewController: CreateChallengeDelegate {
    
    func challengeCreated(challenge: Challenge) {
        self.fetchAllChallenges()
    }
    
}
