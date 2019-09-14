//
//  UpcomingChallengeViewController.swift
//  GymRats
//
//  Created by Mack on 6/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class UpcomingChallengeViewController: UICollectionViewController, Special {

    let challenge: Challenge
    var users: [User] = []
    
    private let disposeBag = DisposeBag()
    
    lazy var chatItem = UIBarButtonItem (
        image: UIImage(named: "chat")?.withRenderingMode(.alwaysTemplate),
        style: .plain,
        target: self,
        action: #selector(openChat)
    )

    init(challenge: Challenge) {
        self.challenge = challenge
        
        super.init(collectionViewLayout: .init())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chatItem.tintColor = .lightGray
        let dummyView = UIView(frame: CGRect(x: 0, y: -view.frame.height, width: view.frame.width, height: view.frame.height))
        dummyView.backgroundColor = .firebrick
        
        collectionView.addSubview(dummyView)
        
        view.backgroundColor = .white
        collectionView.backgroundColor = .white

        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 10
        let width = (view.frame.width - 40) / 3
        
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 230)
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.bounces = true
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceVertical = true
        
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(fetchUsers), for: .valueChanged)

        collectionView.register(UINib(nibName: "UpcomingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingCell")
        collectionView.register(UINib(nibName: "UpcomingChallengeCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.addSubview(refreshControl)

        setupMenuButton()
        setupBackButton()

        navigationItem.rightBarButtonItem = chatItem
        
        fetchUsers()
    }
    
    @objc func fetchUsers() {
        showLoadingBar()
        refreshControl.beginRefreshing()
        
        gymRatsAPI.getUsers(for: challenge)
            .subscribe { event in
                self.hideLoadingBar()
                self.refreshControl.endRefreshing()
                
                switch event {
                case .next(let users):
                    self.users = users
                    self.collectionView.reloadData()
                default: break
                }
        }.disposed(by: disposeBag)
    }

    private func showAlert() {
        let alert = UIAlertController(title: "Are you sure you want to leave \(challenge.name)?", message: nil, preferredStyle: .actionSheet)
        let leave = UIAlertAction(title: "Leave", style: .destructive) { _ in
            self.showLoadingBar()
            gymRatsAPI.leaveChallenge(self.challenge)
                .subscribe({ e in
                    self.hideLoadingBar()
                    switch e {
                    case .next:
                        if let nav = GymRatsApp.coordinator.drawer.centerViewController as? UINavigationController {
                            // MACK
                            if let home = nav.children.first as? HomeViewController {
                                home.fetchAllChallenges()
                                
                                GymRatsApp.coordinator.drawer.closeDrawer(animated: true, completion: nil)
                            } else {
                                let center = HomeViewController()
                                let nav = GRNavigationController(rootViewController: center)
                                
                                GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
                            }
                        }
                    case .error(let error):
                        self.presentAlert(with: error)
                    case .completed:
                        break
                    }
                }).disposed(by: self.disposeBag)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(leave)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func openChat() {
        push(ChatViewController(challenge: challenge))
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpcomingCell", for: indexPath) as! UpcomingCollectionViewCell
        let user = users[indexPath.row]
        
        cell.user = user
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { fatalError("Unexpected element kind") }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! UpcomingChallengeCollectionReusableView
        view.challenge = challenge
        
        if users.count == 1 {
            view.memberLabel.text = "\(users.count) member"
        } else {
            view.memberLabel.text = "\(users.count) members"
        }
        
        view.leaveChallenge.onTouchUpInside { [weak self] in
            self?.showAlert()
        }.disposed(by: disposeBag)

        return view
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
