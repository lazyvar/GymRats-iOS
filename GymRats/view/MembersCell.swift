//
//  MembersCell.swift
//  GymRats
//
//  Created by mack on 8/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class MembersCell: UITableViewCell {
  private var accounts: [Account] = []
  private var press: ((Account) -> Void)?
  private var challenge: Challenge!
  
  var showInviteAtEnd: Bool = false
  
  @IBOutlet private weak var collectionView: UICollectionView! {
    didSet {
      collectionView.dataSource = self
      collectionView.delegate = self
      collectionView.registerCellNibForClass(MemberCell.self)
      collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionView")
      collectionView.bounces = true
      collectionView.alwaysBounceHorizontal = true
      collectionView.isUserInteractionEnabled = true
      collectionView.backgroundColor = .background
      collectionView.showsVerticalScrollIndicator = false
      collectionView.showsHorizontalScrollIndicator = false
      collectionView.setCollectionViewLayout(UICollectionViewFlowLayout().apply {
        $0.scrollDirection = .horizontal
      }, animated: false)
    }
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, challenge: Challenge, accounts: [Account], press: @escaping (Account) -> Void) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: MembersCell.self, for: indexPath).apply { cell in
      cell.accounts = accounts
      cell.press = press
      cell.challenge = challenge
      cell.showInviteAtEnd = challenge.startDate.serverDateIsToday
    }
  }
}

extension MembersCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    
    if showInviteAtEnd {
      if indexPath.row == accounts.count {
        ChallengeFlow.invite(to: challenge)
      } else {
        press?(accounts[indexPath.row])
      }
    } else {
      press?(accounts[indexPath.row])
    }
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if showInviteAtEnd {
      return accounts.count + 1
    } else {
      return accounts.count
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if showInviteAtEnd {
      if indexPath.row == accounts.count {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionView", for: indexPath).apply { cell in
          let imageView = UIImageView()
          imageView.contentMode = .center
          imageView.backgroundColor = .brand
          imageView.layer.cornerRadius = 25
          imageView.clipsToBounds = true
          imageView.tintColor = .white
          imageView.image = .plus
          imageView.translatesAutoresizingMaskIntoConstraints = false
          
          cell.addSubview(imageView)

          imageView.fill(in: cell, top: 5, bottom: -5, left: 5, right: -5)
        }
      } else {
        return MemberCell.configure(collectionView: collectionView, indexPath: indexPath, account: accounts[indexPath.row])
      }
    } else {
      return MemberCell.configure(collectionView: collectionView, indexPath: indexPath, account: accounts[indexPath.row])
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 60, height: 60)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return .init(top: 0, left: 15, bottom: 5, right: 15)
  }
}
