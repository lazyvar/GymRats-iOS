//
//  UpcomingChallengeViewController.swift
//  GymRats
//
//  Created by Mack on 6/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class UpcomingChallengeViewController: UICollectionViewController {

    let challenge: Challenge
    var users: [User] = []
    
    private let disposeBag = DisposeBag()
    
    lazy var chatItem = UIBarButtonItem (
        image: UIImage(named: "chat")?.withRenderingMode(.alwaysOriginal),
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
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 188)
        
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
        
        return view
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
