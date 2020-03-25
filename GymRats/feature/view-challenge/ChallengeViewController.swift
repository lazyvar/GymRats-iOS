//
//  ChallengeViewController.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import CRRefresh
import UIScrollView_InfiniteScroll

typealias ChallengeSection = SectionModel<Date?, ChallengeRow>

class ChallengeViewController: BindableViewController {
  
  // MARK: Init
  
  private let challenge: Challenge
  private let viewModel = ChallengeViewModel()
  private let disposeBag = DisposeBag()

  init(challenge: Challenge) {
    self.challenge = challenge
    self.viewModel.configure(challenge: challenge)
    
    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private var shouldShowInfScroll = true
  
  // MARK: Views

  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.showsVerticalScrollIndicator = false
      tableView.registerCellNibForClass(WorkoutCell.self)
      tableView.registerCellNibForClass(NoWorkoutsCell.self)
      tableView.registerCellNibForClass(ChallengeBannerCell.self)
      tableView.rx.setDelegate(self).disposed(by: disposeBag)
      tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
        self?.viewModel.input.refresh.trigger()
        (self?.tabBarController as? ChallengeTabBarController)?.updateChatIcon()
      }
      tableView.infiniteScrollIndicatorStyle = {
        if #available(iOS 12.0, *) {
          if traitCollection.userInterfaceStyle == .dark {
            return .white
          } else {
            return .gray
          }
        } else {
          return .gray
        }
      }()
      tableView.addInfiniteScroll { [weak self] _ in
        self?.viewModel.input.infiniteScrollTriggered.trigger()
      }
      tableView.setShouldShowInfiniteScrollHandler { [weak self] _ -> Bool in
        return self?.shouldShowInfScroll ?? false
      }
      tableView.infiniteScrollTriggerOffset = 300
      tableView.rx.itemSelected
        .do(onNext: { [weak self] indexPath in
          self?.tableView.deselectRow(at: indexPath, animated: true)
        })
        .bind(to: viewModel.input.tappedRow)
        .disposed(by: disposeBag)
    }
  }
  
  private lazy var chatBarButtonItem = UIBarButtonItem (
    image: .chatGray,
    style: .plain,
    target: self,
    action: #selector(chatTapped)
  )

  private lazy var menuBarButtonItem = UIBarButtonItem(
    image: .moreVertical,
    style: .plain,
    target: self,
    action: #selector(menuTapped)
  ).apply { $0.tintColor = .lightGray }

  private lazy var statsBarButtonItem = UIBarButtonItem(
    image: .standings,
    style: .plain,
    target: self,
    action: #selector(statsTapped)
  ).apply { $0.tintColor = .lightGray }

  // MARK: View lifecycle
  
  private let members = BehaviorSubject<[Account]>(value: [])
  
  private let dataSource = RxTableViewSectionedReloadDataSource<ChallengeSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    switch row {
    case .banner(let challenge, let challengeInfo):
      return ChallengeBannerCell.configure(tableView: tableView, indexPath: indexPath, challenge: challenge, challengeInfo: challengeInfo)
    case .workout(let workout):
      return WorkoutCell.configure(tableView: tableView, indexPath: indexPath, workout: workout)
    case .noWorkouts(let challenge, let onLogWorkout):
      return NoWorkoutsCell.configure(tableView: tableView, indexPath: indexPath, challenge: challenge, onLogWorkout: onLogWorkout)
    }
  })
  
  override func bindViewModel() {
    viewModel.output.sections
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    viewModel.output.error
      .debug()
      .flatMap { UIAlertController.present($0) }
      .ignore(disposedBy: disposeBag)
    
    viewModel.output.loading
      .do(onNext: { [weak self] loading in
        loading ? self?.showLoadingBar() : self?.hideLoadingBar()
        
        if !loading {
          self?.tableView.cr.endHeaderRefresh()
        }
      })
      .ignore(disposedBy: disposeBag)
    
    viewModel.output.doneLoadingMore
      .subscribe(onNext: { [weak self] count in
        self?.tableView.finishInfiniteScroll()

        if let count = count, count == 0 {
          self?.shouldShowInfScroll = false
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.output.navigation
      .subscribe(onNext: { [weak self] (navigation, screen) in
        self?.navigate(navigation, to: screen.viewController)
      })
      .disposed(by: disposeBag)
    
    viewModel.output.resetNoMore
      .subscribe(onNext: { [weak self] _ in
        self?.shouldShowInfScroll = true
      })
      .disposed(by: disposeBag)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItems = {
      if challenge.isPast {
        return [menuBarButtonItem, chatBarButtonItem, statsBarButtonItem]
      } else {
        return [menuBarButtonItem]
      }
    }()
    
    if !challenge.isPast {
      setupMenuButton()
    }
    
    viewModel.input.viewDidLoad.trigger()
  }
  
  @objc private func menuTapped() {
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let inviteAction = UIAlertAction(title: "Invite", style: .default) { _ in
      ChallengeFlow.invite(to: self.challenge)
    }
    
    let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
      let editViewController = EditChallengeViewController(challenge: self.challenge)
      
      self.present(editViewController.inNav(), animated: true, completion: nil)
    }
    
    let deleteAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
      self.leaveChallenge()
    }
    
    let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    alertViewController.addAction(inviteAction)
    alertViewController.addAction(editAction)
    alertViewController.addAction(deleteAction)
    alertViewController.addAction(cancelAction)
    
    present(alertViewController, animated: true, completion: nil)
  }
  
  @objc private func statsTapped() {
    push(
      ChallengeStatsViewController(challenge: challenge)
    )
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if challenge.isActive {
      (tabBarController as? ChallengeTabBarController)?.updateChatIcon()
    } else {
      gymRatsAPI.getChatNotificationCount(for: challenge)
        .subscribe(onNext: { [weak self] result in
          let count = result.object?.count ?? 0
          
          if count == .zero {
            self?.chatBarButtonItem.image = .chatGray
          } else {
            self?.chatBarButtonItem.image = UIImage.chatUnreadGray.withRenderingMode(.alwaysOriginal)
          }
        })
        .disposed(by: disposeBag)
    }
  }
  
  @objc private func chatTapped() {
    push(
      ChatViewController(challenge: challenge)
    )
  }
  
  @IBAction private func tappedLogFirstWorkout(_ sender: Any) {
    WorkoutFlow.logWorkout()
  }
  
  private func leaveChallenge() {
    ChallengeFlow.leave(challenge)
  }
}

// MARK: UITableViewDataSource & UITableViewDelegate
extension ChallengeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let date = dataSource[section].model else { return nil }
    
    let label = UILabel()
    label.frame = CGRect(x: 15, y: 0, width: view.frame.width, height: 30)
    label.backgroundColor = .clear
    label.font = .proRoundedBold(size: 16)

    if date.serverDateIsToday {
      label.text = "Today"
    } else if date.serverDateIsYesterday {
      label.text = "Yesterday"
    } else {
      label.text = date.toFormat("EEEE, MMM d")
    }
    
    let headerView = UIView()
    headerView.addSubview(label)
    headerView.backgroundColor = .clear
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard dataSource[section].model != nil else { return .zero }

    return 30
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNormalMagnitude
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
}
