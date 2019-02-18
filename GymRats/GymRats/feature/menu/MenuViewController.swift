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
    
    let userImageView = UserImageView()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .body
        label.textAlignment = .center
        label.textColor = .charcoal
        
        return label
    }()
    
    let activeButton: LeftAlignedIconButton = {
        let button = LeftAlignedIconButton()
        button.setTitle("Active", for: .normal)
        button.setImage(UIImage(named: "activity")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        button.titleLabel?.font = .h4
        button.setTitleColor(.brand, for: .normal)
        button.tintColor = .brand
        
        return button
    }()

    let joinChallenge: LeftAlignedIconButton = {
        let button = LeftAlignedIconButton()
        button.setTitle("Join", for: .normal)
        button.setImage(UIImage(named: "plus-circle")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        button.titleLabel?.font = .h4
        button.setTitleColor(.charcoal, for: .normal)
        button.tintColor = .charcoal

        return button
    }()

    let createChallengeButton: LeftAlignedIconButton = {
        let button = LeftAlignedIconButton()
        button.setTitle("Start", for: .normal)
        button.setImage(UIImage(named: "play")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        button.titleLabel?.font = .h4
        button.setTitleColor(.charcoal, for: .normal)
        button.tintColor = .charcoal
        
        return button
    }()

    let archivedButton: LeftAlignedIconButton = {
        let button = LeftAlignedIconButton()
        button.setTitle("Archived", for: .normal)
        button.setImage(UIImage(named: "archive")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        button.titleLabel?.font = .h4
        button.setTitleColor(.charcoal, for: .normal)
        button.tintColor = .charcoal

        return button
    }()

    let aboutButton: LeftAlignedIconButton = {
        let button = LeftAlignedIconButton()
        button.setTitle("About", for: .normal)
        button.setImage(UIImage(named: "info")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        button.titleLabel?.font = .h4
        button.setTitleColor(.charcoal, for: .normal)
        button.tintColor = .charcoal
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let containerView = UIView()
        containerView.frame = view.frame
        containerView.backgroundColor = .white

        containerView.backgroundColor = .whiteSmoke
        containerView.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.justifyContent = .flexStart
            layout.alignContent = .flexStart
            layout.width = YGValue(MenuViewController.menuWidth)
            layout.paddingTop = 80
        }
        
        let imageViewContainer = UIView()
        
        imageViewContainer.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .row
            layout.alignContent = .center
            layout.justifyContent = .center
        }
        
        userImageView.configureLayout { layout in
            layout.isEnabled = true
            layout.width = YGValue(MenuViewController.menuWidth / 2)
            layout.height = YGValue(MenuViewController.menuWidth / 2)
            layout.margin = 5
        }
        
        usernameLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 5
        }
        
        activeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 35
            layout.marginLeft = 20
        }

        joinChallenge.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
            layout.marginLeft = 20
        }

        createChallengeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
            layout.marginLeft = 20
        }

        archivedButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
            layout.marginLeft = 20
        }

        aboutButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
            layout.marginLeft = 20
        }

        usernameLabel.text = GymRatsApp.coordinator.currentUser.fullName
        userImageView.load(avatarInfo: GymRatsApp.coordinator.currentUser)
        
        imageViewContainer.addSubview(userImageView)

        imageViewContainer.yoga.applyLayout(preservingOrigin: true)
        
        containerView.addSubview(imageViewContainer)
        containerView.addSubview(usernameLabel)
        containerView.addSubview(activeButton)
        containerView.addSubview(joinChallenge)
        containerView.addSubview(createChallengeButton)
        containerView.addSubview(archivedButton)
        containerView.addSubview(aboutButton)
        
        containerView.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: .flexibleHeight)
        containerView.makeScrolly(in: view)

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
                            let nav = GRNavigationController(rootViewController: center)

                            GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
                        }
                    }
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
        
        activeButton.onTouchUpInside {
            let center = HomeViewController()
            let nav = GRNavigationController(rootViewController: center)
            
            GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
        }.disposed(by: disposeBag)
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.gotoCurrentUserProfile))
        tap.numberOfTapsRequired = 1
        
        userImageView.addGestureRecognizer(tap)
    }
    
    @objc func gotoCurrentUserProfile() {
        let profile = ProfileViewController(user: GymRatsApp.coordinator.currentUser, challenge: nil)
        let nav = GRNavigationController(rootViewController: profile)
    
        profile.setupMenuButton()
        profile.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"), style: .plain, target: profile, action: #selector(ProfileViewController.transitionToSettings))
        
        GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
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
                let nav = GRNavigationController(rootViewController: center)
                
                GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
            }
        }
    }
    
}
