//
//  MenuViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class MenuViewController: UITableViewController {

    static var menuWidth: CGFloat { return UIScreen.main.bounds.width - 80 }
    
    var activeChallenges: [Challenge] = []
    
    let disposeBag = DisposeBag()
    
    let userImageView = UserImageView()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .body
        label.textAlignment = .center
        label.textColor = .dark
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.gotoCurrentUserProfile))
        tap.numberOfTapsRequired = 1
        
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NormalCell")
        tableView.register(UINib(nibName: "UserProfileMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "UserProfile")
        tableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "ChallengeCell")
        tableView.backgroundColor = .firebrick
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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .firebrick
        
        if section == 2 {
            view.constrainHeight(20)
        } else {
            view.constrainHeight(0)
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 2 else { return 0 }
        
        return 20
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return activeChallenges.count
        case 2:
            return 4
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfile") as! UserProfileMenuTableViewCell

            cell.userImageView.skeletonLoad(avatarInfo: GymRatsApp.coordinator.currentUser)
            cell.usernameLabel.text = GymRatsApp.coordinator.currentUser.fullName

            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeCell") as! MenuTableViewCell

            cell.userImageView.skeletonLoad(avatarInfo: activeChallenges[indexPath.row])
            cell.titleLabel.text = activeChallenges[indexPath.row].name
            
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCell")!

        cell.textLabel?.font = .bodyBold
        cell.backgroundColor = .clear
        cell.imageView?.tintColor = .white
        cell.textLabel?.textColor = .white

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Archived"
            cell.imageView?.image = UIImage(named: "archive")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        case 1:
            cell.textLabel?.text = "Join"
            cell.imageView?.image = UIImage(named: "plus-circle")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        case 2:
            cell.textLabel?.text = "Start"
            cell.imageView?.image = UIImage(named: "play")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        case 3:
            cell.textLabel?.text = "About"
            cell.imageView?.image = UIImage(named: "info")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        default:
            fatalError("Unhandled row")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let profile = ProfileViewController(user: GymRatsApp.coordinator.currentUser, challenge: nil)
            let nav = GRNavigationController(rootViewController: profile)
            
            profile.setupMenuButton()
            profile.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"), style: .plain, target: profile, action: #selector(ProfileViewController.transitionToSettings))
            
            GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
        } else if indexPath.section == 1 {
            let challenge = activeChallenges[indexPath.row]
            
            UserDefaults.standard.set(challenge.id, forKey: "last_opened_challenge")
            
            let challengeViewController = ChallengeViewController.create(for: challenge)
            let nav = GRNavigationController(rootViewController: challengeViewController)
            GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                let archived = ArchivedChallengesTableViewController()
                
                let nav = GRNavigationController(rootViewController: archived)
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
                nav.navigationBar.turnSolidWhiteSlightShadow()
                
                self.present(nav, animated: true, completion: nil)
            case 3:
                let center = AboutViewController()
                let nav = GRNavigationController(rootViewController: center)
                
                GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
            default:
                break
            }

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
