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
        title = "Home"
        setupMenuButton()
        
        retryButton.onTouchUpInside { [weak self] in
            self?.fetchAllGroups()
        }.disposed(by: disposeBag)
        
        joinChallengeButton.onTouchUpInside { [weak self] in
            guard let self = self else { return }
            
            JoinChallenge.presentJoinChallengeModal(on: self)
                .subscribe(onNext: { [weak self] group in
                    self?.fetchAllGroups()
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
            
            self?.present(nav, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        fetchAllGroups()
    }

    func fetchAllGroups() {
        retryButton.isHidden = true
        HUD.show(.progress)
        
        gymRatsAPI.getAllGroups()
            .subscribe(onNext: { [weak self] groups in
                HUD.hide()
                
                let activeGroups = groups.getActiveGroups()
                
                if activeGroups.isEmpty {
                    self?.showEmptyState()
                } else {
                    if activeGroups.count > 1 {
                        // memeber of multiple active groups
                        self?.showMulitpleChallenges(groups: activeGroups)
                    } else {
                        // member on single active group
                        self?.showSingleChallenge(group: activeGroups[0])
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
    
    func showSingleChallenge(group: Group) {
        
    }
    
    func showMulitpleChallenges(groups: [Group]) {
        
    }
}

extension HomeViewController: CreateChallengeDelegate {
    
    func challengeCreated(group: Group) {
        self.fetchAllGroups()
    }
    
}
