//
//  UpcomingChallengeViewController.swift
//  GymRats
//
//  Created by Mack on 6/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import MessageUI

class UpcomingChallengeViewController: UICollectionViewController {

    let challenge: Challenge
    var users: [Account] = []
    
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
        dummyView.backgroundColor = .brand
        
        collectionView.addSubview(dummyView)
        
        view.backgroundColor = .background
        collectionView.backgroundColor = .background

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
        
//        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(fetchUsers), for: .valueChanged)

        collectionView.register(UINib(nibName: "UpcomingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingCell")
        collectionView.register(UINib(nibName: "UpcomingChallengeCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.addSubview(refreshControl)

        setupMenuButton()
        setupBackButton()

        let add = UIImage(named: "user-plus")!.withRenderingMode(.alwaysTemplate)
        let edit = UIImage(named: "edit")!.withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(image: add, style: .plain, target: self, action: #selector(addFriend))
        let editButton = UIBarButtonItem(image: edit, style: .plain, target: self, action: #selector(editChallenge))
        
        navigationItem.rightBarButtonItems = [chatItem, editButton, button]
        
        fetchUsers()
    }
    
    func refreshChatIcon() {
      gymRatsAPI.getChatNotificationCount(for: challenge)
        .subscribe(onNext: { [weak self] result in
          let count = result.object?.count ?? 0
          
          if count == .zero {
            self?.chatItem.image = .chatGray
          } else {
            self?.chatItem.image = UIImage.chatUnreadGray.withRenderingMode(.alwaysOriginal)
          }
        })
        .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      refreshChatIcon()
    }

    @objc func editChallenge() {
      let editViewController = EditChallengeViewController(challenge: self.challenge)
      
      self.present(editViewController.inNav(), animated: true, completion: nil)
    }
    
  @objc func addFriend() {
    ChallengeFlow.invite(to: challenge)
  }
    
  @objc func fetchUsers() {
      showLoadingBar()
      refreshControl.beginRefreshing()
      
    gymRatsAPI.getMembers(for: challenge)
      .subscribe(onNext: { result in
        self.hideLoadingBar()
        self.refreshControl.endRefreshing()
      
        switch result {
        case .success(let members):
          self.users = members
          self.collectionView.reloadData()
        case .failure(let error):
          self.presentAlert(with: error)
        }
      })
    .disposed(by: disposeBag)
  }

  @objc private func showAlert() {
    ChallengeFlow.leave(challenge)
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
      
      view.leaveChallenge.addTarget(self, action: #selector(showAlert), for: .touchUpInside)

      return view
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension UpcomingChallengeViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismissSelf()
    }
}
