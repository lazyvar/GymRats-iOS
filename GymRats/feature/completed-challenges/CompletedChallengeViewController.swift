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

class CompletedChallengeViewController: BindableViewController, UITableViewDelegate {
  var popUp = false
  var itIsAParty = false
  
  private let viewModel = CompletedChallengeViewModel()
  private let disposeBag = DisposeBag()
  private let challenge: Challenge

  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.showsVerticalScrollIndicator = false
      tableView.separatorStyle = .none
      tableView.allowsSelection = false
      tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
      tableView.rx.setDelegate(self).disposed(by: disposeBag)
      tableView.registerCellNibForClass(CompletedChallengeBannerDescriptonCell.self)
      tableView.registerCellNibForClass(LargeTitlesAreDumbCell.self)
      tableView.registerCellNibForClass(ChallengeCompleteDescriptionCell.self)
      tableView.registerCellNibForClass(ShareChallengeButtonCell.self)
      tableView.registerCellNibForClass(NewChallengeButtonCell.self)
      tableView.registerCellNibForClass(RankingCell.self)
    }
  }
  
  init(challenge: Challenge) {
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
  
  private lazy var dataSource = RxTableViewSectionedReloadDataSource<CompletedChallengeSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    switch row {
    case .title(let challenge):
      return LargeTitlesAreDumbCell.configure(tableView: tableView, indexPath: indexPath, challenge: challenge)
    case .description(let banner, let desc):
      if let banner = banner {
        return CompletedChallengeBannerDescriptonCell.configure(tableView: tableView, indexPath: indexPath, banner: banner, description: desc)
      } else {
        return ChallengeCompleteDescriptionCell.configure(tableView: tableView, indexPath: indexPath, description: desc)
      }
    case .share(let challenge):
      return ShareChallengeButtonCell.configure(tableView: tableView, indexPath: indexPath) {
        let share = ShareChallengeViewController(challenge: challenge)
        
        self.push(share)
      }
    case .ranking(let ranking, let place, let scoreBy):
      return RankingCell.configure(tableView: tableView, indexPath: indexPath, ranking: ranking, place: place, scoreBy: scoreBy) {
        self.push(ProfileViewController(account: ranking.account, challenge: self.challenge))
      }
    }
  })

  override func viewDidLoad() {
    super.viewDidLoad()
  
    if popUp {
      navigationItem.leftBarButtonItem = .close(target: self)
    } else {
      navigationItem.rightBarButtonItems = [chatBarButtonItem, statsBarButtonItem]
    }
    
    navigationItem.largeTitleDisplayMode = .never
    
    if itIsAParty { dance() }

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
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let model = dataSource[section].model

    guard let header = model else { return nil }
    
    let label = UILabel()
    label.backgroundColor = .clear
    label.font = .bodyBold
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = header

    let headerView = UIView()
    headerView.addSubview(label)
    headerView.backgroundColor = .clear
    
    label.verticallyCenter(in: headerView)
    label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let model = dataSource[section].model

    guard model != nil else { return .zero }

    return 35
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNormalMagnitude
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }

  private func dance() {
    let confettiView = SwiftConfettiView(frame: view.bounds).apply {
      $0.startConfetti()
      $0.isUserInteractionEnabled = false
      UIApplication.shared.keyWindow!.addSubview($0)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
      UIView.animate(withDuration: 0.2, animations: {
        confettiView.alpha = 0
      }) { _ in
        confettiView.removeFromSuperview()
      }
    }
  }
  
  @objc private func chatTapped() {
    push(ChatViewController(challenge: challenge))
  }
  
  @objc private func statsTapped() {
    push(ChallengeDetailsViewController(challenge: challenge))
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
