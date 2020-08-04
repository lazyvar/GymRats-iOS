//
//  UpcomingChallengeViewController.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift

enum UpcomingChallengeRow {
  case banner(Challenge)
  case account(Account)
  case invite(Challenge)
}

typealias UpcomingChallengeSection = SectionModel<String, UpcomingChallengeRow>

class UpcomingChallengeViewController: BindableViewController {
  private let viewModel = UpcomingChallengeViewModel()
  private let disposeBag = DisposeBag()
  private let challenge: Challenge
  
  init(challenge: Challenge) {
    self.challenge = challenge
    self.viewModel.configure(challenge: challenge)

    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @IBOutlet private weak var collectionView: UICollectionView! {
    didSet {
      collectionView.alwaysBounceVertical = true
      collectionView.bounces = true
      collectionView.backgroundColor = .background
      collectionView.registerCellNibForClass(AccountCell.self)
      collectionView.registerCellNibForClass(InviteCell.self)
      collectionView.refreshControl = UIRefreshControl()
      collectionView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
      collectionView.setCollectionViewLayout(UpcomingChallengeFlowLayout(challenge: challenge), animated: false)
      collectionView.register(UINib(nibName: "UpcomingChallengeHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "UpcomingChallengeHeaderView")
      collectionView.delegate = self
    }
  }

  private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<UpcomingChallengeSection>(configureCell: { _, collectionView, indexPath, row -> UICollectionViewCell in
    switch row {
    case .account(let account): return AccountCell.configure(collectionView: collectionView, indexPath: indexPath, account: account)
    case .banner(let challenge): return UICollectionViewCell()
    case .invite(let challenge): return InviteCell.configure(collectionView: collectionView, indexPath: indexPath)
    }
  }, configureSupplementaryView: { _, collectionView, _, indexPath in
    let view = collectionView.dequeueReusableSupplementaryView(
      ofKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: "UpcomingChallengeHeaderView",
      for: indexPath
    ) as! UpcomingChallengeHeaderView
    
    view.configure(self.challenge)
    
    return view
  })
  
  private lazy var chatBarButtonItem = UIBarButtonItem (
    image: .chat,
    style: .plain,
    target: self,
    action: #selector(openChat)
  )

  private lazy var moreBarButtonItem = UIBarButtonItem(
    image: .moreHorizontal,
    style: .plain,
    target: self,
    action: #selector(moreTapped)
  )
  
  override func bindViewModel() {
    viewModel.output.error
      .do(onNext: { _ in self.hideLoadingBar() })
      .do(onNext: { _ in self.collectionView.refreshControl?.endRefreshing() })
      .flatMap { UIAlertController.present($0) }
      .ignore(disposedBy: disposeBag)

    viewModel.output.navigation
      .subscribe(onNext: { [weak self] (navigation, screen) in
        self?.navigate(navigation, to: screen.viewController)
      })
      .disposed(by: disposeBag)

    viewModel.output.sections
      .do(onNext: { _ in self.hideLoadingBar() })
      .do(onNext: { _ in self.collectionView.refreshControl?.endRefreshing() })
      .bind(to: collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    extendedLayoutIncludesOpaqueBars = true
    title = challenge.name
    navigationItem.rightBarButtonItems = [moreBarButtonItem, chatBarButtonItem]
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(refreshChatIcon),
      name: .appEnteredForeground,
      object: nil
    )

    setupMenuButton()
    
    Membership.State.fetch(for: challenge)
    
    viewModel.input.viewDidLoad.trigger()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    refreshChatIcon()
  }
  
  @objc private func openChat() {
    push(ChatViewController(challenge: challenge))
  }

  @objc private func refresh() {
    refreshChatIcon()
    
    viewModel.input.refresh.trigger()
  }

  @objc private func refreshChatIcon() {
    gymRatsAPI.getChatNotificationCount(for: challenge)
      .subscribe(onNext: { [weak self] result in
        let count = result.object?.count ?? 0
        
        if count == .zero {
          self?.chatBarButtonItem.image = .chat
        } else {
          self?.chatBarButtonItem.image = UIImage.chatUnread.withRenderingMode(.alwaysOriginal)
        }
      })
      .disposed(by: disposeBag)
  }

  @objc private func moreTapped() {
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let inviteAction = UIAlertAction(title: "Invite", style: .default) { _ in
      ChallengeFlow.invite(to: self.challenge)
    }
    
    let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
      let editViewController = EditChallengeViewController(challenge: self.challenge)
      
      self.present(editViewController.inNav(), animated: true, completion: nil)
    }
    
    let changeBanner = UIAlertAction(title: "Change banner", style: .default) { _ in
      self.presentInNav(ChangeBannerViewController(challenge: self.challenge))
    }
    
    let deleteAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
      ChallengeFlow.leave(self.challenge)
    }
    
    let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    alertViewController.addAction(inviteAction)
    
    if Membership.State.owner(of: challenge) {
      alertViewController.addAction(editAction)
      alertViewController.addAction(changeBanner)
    }
    
    alertViewController.addAction(deleteAction)
    alertViewController.addAction(cancelAction)
    
    present(alertViewController, animated: true, completion: nil)
  }
}

extension UpcomingChallengeViewController: UICollectionViewDelegate {  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
      
    viewModel.input.selectedItem.onNext(indexPath)
  }
}
