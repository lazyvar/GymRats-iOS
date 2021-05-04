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
  case warning
  case challengeInfo(Challenge)
  case rat(Account)
  case teams([Team])
  case invite(Challenge)
}

typealias UpcomingChallengeSection = SectionModel<String?, UpcomingChallengeRow>

class UpcomingChallengeViewController: BindableViewController {
  private let viewModel: UpcomingChallengeViewModel
  private let disposeBag = DisposeBag()
  private let challenge: Challenge
  
  init(challenge: Challenge) {
    self.viewModel = UpcomingChallengeViewModel(challenge: challenge)
    self.challenge = challenge

    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.alwaysBounceVertical = true
      tableView.bounces = true
      tableView.backgroundColor = .background
      tableView.separatorStyle = .none
      tableView.refreshControl = UIRefreshControl()
      tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
      tableView.registerCellNibForClass(UpcomingChallengeCell.self)
      tableView.registerCellNibForClass(InviteToChallengeCell.self)
      tableView.registerCellNibForClass(UpcomingRatCell.self)
      tableView.registerCellNibForClass(UpcomingChallengeWarningCell.self)
      tableView.registerCellNibForClass(RankingCell.self)
      tableView.registerCellNibForClass(MembersCell.self)
      tableView.registerCellNibForClass(ChoiceCell.self)
      tableView.delegate = self
    }
  }

  private lazy var dataSource = RxTableViewSectionedReloadDataSource<UpcomingChallengeSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    switch row {
    case .teams(let teams):
      return MembersCell.configure(
        tableView: tableView,
        indexPath: indexPath,
        challenge: self.challenge,
        avatars: teams,
        showInviteAtEnd: true,
        onAdd: {
          self.presentForClose(CreateTeamViewController(self.challenge))
        },
        press: { avatar in
          guard let team = avatar as? Team else { return }
          
          self.push(TeamViewController(team, self.challenge, joiningChallenge: true))
        }
      )
    case .warning: return UpcomingChallengeWarningCell.configure(tableView: tableView, indexPath: indexPath)
    case .rat(let account): return UpcomingRatCell.configure(tableView: tableView, indexPath: indexPath, rat: account)
    case .challengeInfo(let challenge): return UpcomingChallengeCell.configure(tableView: tableView, indexPath: indexPath, challenge: challenge)
    case .invite(let challenge): return InviteToChallengeCell.configure(tableView: tableView, indexPath: indexPath, challenge: challenge)
    }
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
      .do(onNext: { _ in self.tableView.refreshControl?.endRefreshing() })
      .flatMap { UIAlertController.present($0) }
      .ignore(disposedBy: disposeBag)

    viewModel.output.loading
      .subscribe { e in
        if case .next(let loading) = e {
          if loading {
            self.showLoadingBar()
          } else {
            self.hideLoadingBar()
          }
        }
      }
      .disposed(by: disposeBag)
    
    viewModel.output.navigation
      .subscribe(onNext: { [weak self] (navigation, screen) in
        self?.navigate(navigation, to: screen.viewController)
      })
      .disposed(by: disposeBag)

    viewModel.output.sections
      .do(onNext: { _ in self.tableView.refreshControl?.endRefreshing() })
      .bind(to: tableView.rx.items(dataSource: dataSource))
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  
    Track.screen(.upcomingChallenge)
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

extension UpcomingChallengeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let title = dataSource[section].model else { return nil }
    
    let label = UILabel()
    label.backgroundColor = .clear
    label.font = .proRoundedBold(size: 16)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = title

    let headerView = UIView()
    headerView.addSubview(label)
    headerView.backgroundColor = .clear
    
    label.verticallyCenter(in: headerView)
    label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard dataSource[section].model != nil else { return .zero }

    return 25
  }
}
