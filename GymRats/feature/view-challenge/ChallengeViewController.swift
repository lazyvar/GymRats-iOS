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
import UIScrollView_InfiniteScroll

struct ChallengeSectionModel: Equatable {
  let date: Date?
  let skeleton: Bool
}

typealias ChallengeSection = SectionModel<ChallengeSectionModel, ChallengeRow>

class ChallengeViewController: BindableViewController {
  
  // MARK: Init
  
  private let challenge: Challenge
  private let viewModel = ChallengeViewModel()
  private let disposeBag = DisposeBag()
  
  private var selectedIndexPath: IndexPath!
  
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
      tableView.registerSkeletonCellNibForClass(WorkoutBigCell.self)
      tableView.registerCellNibForClass(WorkoutBigCell.self)
      tableView.registerSkeletonCellNibForClass(WorkoutListCell.self)
      tableView.registerCellNibForClass(WorkoutListCell.self)
      tableView.registerCellNibForClass(LargeTitlesAreDumbCell.self)
      tableView.registerCellNibForClass(NoWorkoutsCell.self)
      tableView.registerCellNibForClass(ChallengeBannerCell.self)
      tableView.rx.setDelegate(self).disposed(by: disposeBag)
      tableView.infiniteScrollTriggerOffset = 100

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
    }
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

  // MARK: View lifecycle  
  
  private lazy var dataSource = RxTableViewSectionedReloadDataSource<ChallengeSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    switch row {
    case .title(let challenge):
      return LargeTitlesAreDumbCell.configure(tableView: tableView, indexPath: indexPath, challenge: challenge)
    case .banner(let challenge, let challengeInfo):
      return ChallengeBannerCell.configure(tableView: tableView, indexPath: indexPath, challenge: challenge, challengeInfo: challengeInfo)
    case .noWorkouts(let challenge):
      return NoWorkoutsCell.configure(tableView: tableView, indexPath: indexPath, challenge: challenge)
    case .workout(let workout):
      switch FeedStyle.stlye(for: self.challenge) {
      case .list: return WorkoutListCell.configure(tableView: tableView, indexPath: indexPath, workout: workout)
      case .big: return WorkoutBigCell.configure(tableView: tableView, indexPath: indexPath, workout: workout)
      }
    case .💀:
      switch FeedStyle.stlye(for: self.challenge) {
      case .list: return WorkoutListCell.skeleton(tableView: tableView, indexPath: indexPath)
      case .big: return WorkoutBigCell.skeleton(tableView: tableView, indexPath: indexPath)
      }
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
          self?.tableView.refreshControl?.endRefreshing()
        }
      })
      .ignore(disposedBy: disposeBag)
    
    viewModel.output.scrollToTop
      .subscribe(onNext: { [weak self] _ in
        self?.tableView.setContentOffset(.zero, animated: false)
      })
      .disposed(by: disposeBag)
    
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
    
    tableView.rx.itemSelected
      .do(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
        self?.selectedIndexPath = indexPath
      })
      .bind(to: viewModel.input.tappedRow)
      .disposed(by: disposeBag)
    
    viewModel.output.resetNoMore
      .subscribe(onNext: { [weak self] _ in
        self?.shouldShowInfScroll = true
      })
      .disposed(by: disposeBag)
  }
  
  private let refreshControl = UIRefreshControl()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    extendedLayoutIncludesOpaqueBars = true
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
    
    Membership.State.fetch(for: challenge)
    
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    tableView.refreshControl = refreshControl
    
    if let tabBarController = tabBarController, navigationController?.children.first == self {
      let insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarController.tabBar.frame.height, right: 0)
      
      tableView.contentInset = insets
      tableView.scrollIndicatorInsets = insets
    }
    
    navigationItem.largeTitleDisplayMode = .never
        
    viewModel.input.viewDidLoad.trigger()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  
    Track.screen(.challenge)
  }
  
  @objc private func refresh() {
    viewModel.input.refresh.trigger()
    (tabBarController as? ChallengeTabBarController)?.updateChatIcon()
  }
  
  @objc private func menuTapped() {
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let inviteAction = UIAlertAction(title: "Invite", style: .default) { _ in
      ChallengeFlow.invite(to: self.challenge)
    }

    let share = UIAlertAction(title: "Share", style: .default) { _ in
      self.presentForClose(ShareChallengeViewController(challenge: self.challenge))
    }

    let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
      let editViewController = EditChallengeViewController(challenge: self.challenge)

      self.present(editViewController.inNav(), animated: true, completion: nil)
    }

    let changeBanner = UIAlertAction(title: "Change banner", style: .default) { _ in
      self.presentInNav(ChangeBannerViewController(challenge: self.challenge))
    }

    let deleteAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
      self.leaveChallenge()
    }

    let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    alertViewController.addAction(inviteAction)
    alertViewController.addAction(share)
    
    if Membership.State.owner(of: challenge) {
      alertViewController.addAction(editAction)
      alertViewController.addAction(changeBanner)
    }
    
    alertViewController.addAction(deleteAction)
    alertViewController.addAction(cancelAction)
    
    present(alertViewController, animated: true, completion: nil)
  }
  
  @objc private func statsTapped() {
    push(
      ChallengeDetailsViewController(challenge: challenge)
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
            self?.chatBarButtonItem.image = .chat
          } else {
            self?.chatBarButtonItem.image = UIImage.chatUnread.withRenderingMode(.alwaysOriginal)
          }
        })
        .disposed(by: disposeBag)
    }
  }
  
  @objc private func tappedChangeFeedStyle() {
    FeedStyle.toggleStyle(for: challenge)
    tableView.reloadData()
    feedStyleButton.setImage(FeedStyle.stlye(for: challenge).image, for: .normal)
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
  
  private lazy var feedStyleButton = UIButton().apply {
    $0.setImage(FeedStyle.stlye(for: self.challenge).image, for: .normal)
    $0.tintColor = .primaryText
    $0.translatesAutoresizingMaskIntoConstraints = false
  }
}

// MARK: UITableViewDataSource & UITableViewDelegate
extension ChallengeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let model = dataSource[section].model

    guard let date = model.date else { return nil }
    
    let label = UILabel()
    label.backgroundColor = .clear
    label.font = .proRoundedBold(size: 14)
    label.translatesAutoresizingMaskIntoConstraints = false
    
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
    
    label.verticallyCenter(in: headerView)
    label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
    
    if model.skeleton {
      headerView.isSkeletonable = true
      label.isSkeletonable = true
      label.linesCornerRadius = 2
      label.showAnimatedSkeleton()
    }
    
    if section == 1 && false {
      headerView.addSubview(feedStyleButton)
      
      feedStyleButton.addTarget(self, action: #selector(self.tappedChangeFeedStyle), for: .touchUpInside)
      feedStyleButton.verticallyCenter(in: headerView)
      feedStyleButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0 - 20).isActive = true
      feedStyleButton.constrainWidth(15)
      feedStyleButton.constrainHeight(15)
      feedStyleButton.imageView?.contentMode = .scaleAspectFit
      
      let tap = UITapGestureRecognizer(target: self, action: #selector(tappedChangeFeedStyle))
      let ghostArea = UIView().apply {
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(tap)
        $0.translatesAutoresizingMaskIntoConstraints = false
      }
  
      headerView.addSubview(ghostArea)
      
      ghostArea.verticallyCenter(in: headerView)
      ghostArea.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
      ghostArea.constrainWidth(80)
      ghostArea.constrainHeight(30)
    }
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let model = dataSource[section].model

    guard model.date != nil else { return .zero }

    return 25
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNormalMagnitude
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
}

extension ChallengeViewController {
  var selectedWorkoutListCell: WorkoutListCell? {
    guard let indexPath = selectedIndexPath else { return nil }
    
    return tableView.cellForRow(at: indexPath) as? WorkoutListCell
  }
  
  var selectedImageView: UIImageView? {
    guard let selectedWorkoutListCell = selectedWorkoutListCell else { return nil }

    return selectedWorkoutListCell.workoutImageView
  }
  
  var selectedImageViewFrame: CGRect {
    guard let selectedWorkoutListCell = selectedWorkoutListCell else { return .zero }
    
    return selectedWorkoutListCell.workoutImageView.superview?.convert(selectedWorkoutListCell.workoutImageView.frame, to: nil) ?? .zero
  }
  
  var selectedWorkoutPhotoURL: URL? {
    return selectedWorkoutListCell?.workoutImageView.kf.webURL
  }
  
  func transitionWillStart(push: Bool) {
    selectedImageView?.alpha = 0
    
    if push {
      UIView.animate(withDuration: 0.3) {
        self.tableView.alpha = 0
      }
    }
  }
  
  func transitionDidEnd(push: Bool) {
    selectedImageView?.alpha = 1

    if push {
      self.tableView.alpha = 1
    }
  }
}
