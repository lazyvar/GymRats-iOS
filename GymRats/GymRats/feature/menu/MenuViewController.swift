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
    
    let activeButton: RightAlignedIconButton = {
        let button = RightAlignedIconButton()
        button.setTitle("Active", for: .normal)
        button.setImage(UIImage(named: "activity")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .light)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(.brand, for: .normal)
        button.tintColor = .brand
        
        return button
    }()

    let joinChallenge: RightAlignedIconButton = {
        let button = RightAlignedIconButton()
        button.setTitle("Join", for: .normal)
        button.setImage(UIImage(named: "plus-circle")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .light)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(.fog, for: .normal)
        button.tintColor = .fog

        return button
    }()

    let createChallengeButton: RightAlignedIconButton = {
        let button = RightAlignedIconButton()
        button.setTitle("Start", for: .normal)
        button.setImage(UIImage(named: "play")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .light)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(.fog, for: .normal)
        button.tintColor = .fog

        return button
    }()

    let archivedButton: RightAlignedIconButton = {
        let button = RightAlignedIconButton()
        button.setTitle("Archived", for: .normal)
        button.setImage(UIImage(named: "archive")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .light)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(.fog, for: .normal)
        button.tintColor = .fog

        return button
    }()

    let aboutButton: RightAlignedIconButton = {
        let button = RightAlignedIconButton()
        button.setTitle("About", for: .normal)
        button.setImage(UIImage(named: "info")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .light)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(.fog, for: .normal)
        button.tintColor = .fog

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
            layout.paddingRight = YGValue(self.view.frame.size.width - MenuViewController.menuWidth + 20)
            layout.paddingTop = 100
        }
        
        let imageViewContainer = UIView()
        
        imageViewContainer.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .row
            layout.alignContent = .center
            layout.justifyContent = .flexEnd
        }
        
        userImageView.configureLayout { layout in
            layout.isEnabled = true
            layout.width = YGValue(MenuViewController.menuWidth / 2)
            layout.height = YGValue(MenuViewController.menuWidth / 2)
            layout.margin = 5
        }
        
        activeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 25
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

        userImageView.load(avatarInfo: GymRatsApp.coordinator.currentUser)
        
        imageViewContainer.addSubview(userImageView)

        imageViewContainer.yoga.applyLayout(preservingOrigin: true)
        
        containerView.addSubview(imageViewContainer)
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
                    if !(error is SimpleError) {
                        self?.presentAlert(with: error)
                    }
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
