//
//  CompletedChallengeViewController.swift
//  GymRats
//
//  Created by mack on 7/31/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import SwiftConfettiView

class CompletedChallengeViewController: BindableViewController {
  private let viewModel = CompletedChallengeViewModel()
  private let disposeBag = DisposeBag()
  private let challenge: Challenge

  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.showsVerticalScrollIndicator = false
      tableView.separatorStyle = .none
      tableView.registerCellNibForClass(ChallengeBannerImageCell.self)
    }
  }
  
  init(challenge: Challenge){
    self.challenge = challenge
    self.viewModel.configure(challenge: challenge)

    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private lazy var chatBarButtonItem = UIBarButtonItem (
    image: .chat,
    style: .plain,
    target: self,
    action: #selector(chatTapped)
  )

  private lazy var menuBarButtonItem = UIBarButtonItem(
    image: .moreHorizontal,
    style: .plain,
    target: self,
    action: #selector(menuTapped)
  )

  private lazy var statsBarButtonItem = UIBarButtonItem(
    image: .award,
    style: .plain,
    target: self,
    action: #selector(statsTapped)
  )
  
  private var dataSource = RxTableViewSectionedReloadDataSource<CompletedChallengeSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    switch row {
    case .banner(let url):
      return ChallengeBannerImageCell.configure(tableView: tableView, indexPath: indexPath, imageURL: url)
    default: return UITableViewCell().apply { $0.backgroundColor = .niceBlue }
    }
  })

  override func viewDidLoad() {
    super.viewDidLoad()
  
    setupMenuButton()
    
    navigationItem.title = self.challenge.name
    navigationItem.largeTitleDisplayMode = .always
    navigationItem.rightBarButtonItems = [menuBarButtonItem, chatBarButtonItem, statsBarButtonItem]
    
    let confettiView = SwiftConfettiView(frame: view.bounds).apply {
      $0.startConfetti()
      view.addSubview($0)
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
      confettiView.stopConfetti()
      confettiView.removeFromSuperview()
    }
    
    viewModel.input.viewDidLoad.trigger()
  }
  
  override func bindViewModel() {
    viewModel.output.sections
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

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
  
  @objc private func chatTapped() {
    push(ChatViewController(challenge: challenge))
  }
  
  @objc private func statsTapped() {
    push(ChallengeStatsViewController(challenge: challenge))
  }
  
  @objc private func menuTapped() {
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
      let editViewController = EditChallengeViewController(challenge: self.challenge)
      
      self.present(editViewController.inNav(), animated: true, completion: nil)
    }

    let deleteAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
      ChallengeFlow.leave(self.challenge)
    }
    
    let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    if Membership.State.owner(of: challenge) {
      alertViewController.addAction(editAction)
    }
    
    alertViewController.addAction(deleteAction)
    alertViewController.addAction(cancelAction)
    
    present(alertViewController, animated: true, completion: nil)
  }
}
