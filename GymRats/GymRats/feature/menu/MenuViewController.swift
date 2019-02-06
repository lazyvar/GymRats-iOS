//
//  MenuViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import YogaKit

class MenuViewController: UIViewController {

    static let menuWidth: CGFloat = 180
    
    let disposeBag = DisposeBag()
    
    let activeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Active", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .light)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(.brand, for: .normal)
        
        return button
    }()

    let joinChallenge: UIButton = {
        let button = UIButton()
        button.setTitle("Join", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .light)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(.brand, for: .normal)
        
        return button
    }()

    let createChallengeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .light)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(.brand, for: .normal)
        
        return button
    }()

    let archivedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Archived", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .light)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(.brand, for: .normal)
        
        return button
    }()

    let aboutButton: UIButton = {
        let button = UIButton()
        button.setTitle("About", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .light)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(.brand, for: .normal)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .whiteSmoke
        view.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.justifyContent = .center
            layout.alignContent = .center
            layout.paddingRight = YGValue(self.view.frame.size.width - MenuViewController.menuWidth + 32)
        }
        
        activeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }

        joinChallenge.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }

        createChallengeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }

        archivedButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }

        aboutButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }

        view.addSubview(activeButton)
        view.addSubview(joinChallenge)
        view.addSubview(createChallengeButton)
        view.addSubview(archivedButton)
        view.addSubview(aboutButton)
        
        view.yoga.applyLayout(preservingOrigin: true)
        
        joinChallenge.onTouchUpInside { [weak self] in
            guard let self = self else { return }
            
            JoinChallenge.presentJoinChallengeModal(on: self)
                .subscribe(onNext: { _ in
                    if let nav = GymRatsApp.coordinator.drawer.centerViewController as? UINavigationController {
                        if let home = nav.children.first as? HomeViewController {
                            home.fetchAllChallenges()
                            
                            GymRatsApp.coordinator.drawer.closeDrawer(animated: true, completion: nil)
                        } else {
                            let center = HomeViewController()
                            let nav = UINavigationController(rootViewController: center)

                            GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
                        }
                    }
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
        
        activeButton.onTouchUpInside {
            let center = HomeViewController()
            let nav = UINavigationController(rootViewController: center)
            
            GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
        }
    }
    
}

extension MenuViewController: CreateChallengeDelegate {
    
    func challengeCreated(challenge: Challenge) {
        if let nav = GymRatsApp.coordinator.drawer.centerViewController as? UINavigationController {
            if let home = nav.children.first as? HomeViewController {
                home.fetchAllChallenges()
                
                GymRatsApp.coordinator.drawer.closeDrawer(animated: true, completion: nil)
            } else {
                let center = HomeViewController()
                let nav = UINavigationController(rootViewController: center)
                
                GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
            }
        }
    }
    
}
