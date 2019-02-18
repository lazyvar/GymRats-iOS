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

class MenuViewController: UITableViewController {

    static let menuWidth: CGFloat = 180
    
    let disposeBag = DisposeBag()
    
    let userImageView = UserImageView()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .body
        label.textAlignment = .center
        label.textColor = .brand
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let containerView = UIView()
        
        containerView.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.justifyContent = .flexStart
            layout.alignContent = .flexStart
            layout.width = YGValue(MenuViewController.menuWidth)
            layout.paddingTop = 60
            layout.padding = 10
            layout.paddingBottom = 24
        }
        
        userImageView.load(avatarInfo: GymRatsApp.coordinator.currentUser)
        
        userImageView.configureLayout { layout in
            layout.isEnabled = true
            layout.width = 80
            layout.height = 80
            layout.margin = 5
        }
        
        let imageViewContainer = UIView()
        
        imageViewContainer.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .row
            layout.alignContent = .center
            layout.justifyContent = .center
        }
        
        usernameLabel.text = GymRatsApp.coordinator.currentUser.fullName
        
        usernameLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 5
        }
        
        imageViewContainer.addSubview(userImageView)
        
        imageViewContainer.yoga.applyLayout(preservingOrigin: true)
        
        containerView.addSubview(imageViewContainer)
        containerView.addSubview(usernameLabel)
        
        containerView.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: .flexibleHeight)

        tableView.tableHeaderView = containerView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.gotoCurrentUserProfile))
        tap.numberOfTapsRequired = 1
        
        userImageView.addGestureRecognizer(tap)
        
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
        tableView.backgroundColor = .whiteSmoke
    }
    
    @objc func gotoCurrentUserProfile() {
        let profile = ProfileViewController(user: GymRatsApp.coordinator.currentUser, challenge: nil)
        let nav = GRNavigationController(rootViewController: profile)
    
        profile.setupMenuButton()
        profile.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"), style: .plain, target: profile, action: #selector(ProfileViewController.transitionToSettings))
        
        GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
    }
    
}

extension MenuViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell")!
        
        cell.textLabel?.font = .body
        cell.backgroundColor = .whiteSmoke
        cell.imageView?.tintColor = .brand
        cell.textLabel?.textColor = .brand

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Active"
            cell.imageView?.image = UIImage(named: "activity")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        case 1:
            cell.textLabel?.text = "Join"
            cell.imageView?.image = UIImage(named: "plus-circle")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        case 2:
            cell.textLabel?.text = "Start"
            cell.imageView?.image = UIImage(named: "play")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        case 3:
            cell.textLabel?.text = "About"
            cell.imageView?.image = UIImage(named: "archive")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        default:
            fatalError("Unhandled row")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let center = HomeViewController()
            let nav = GRNavigationController(rootViewController: center)
            
            GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
        case 1:
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
        case 2:
            let createChallengeViewController = CreateChallengeViewController()
            createChallengeViewController.delegate = self
            
            let nav = GRNavigationController(rootViewController: createChallengeViewController)
            nav.navigationBar.turnBrandColorSlightShadow()
            
            self.present(nav, animated: true, completion: nil)
        default:
            break
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
                let nav = GRNavigationController(rootViewController: center)
                
                GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
            }
        }
    }
    
}
