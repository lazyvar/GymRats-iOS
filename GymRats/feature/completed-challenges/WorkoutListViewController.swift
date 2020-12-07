//
//  WorkoutListViewController.swift
//  GymRats
//
//  Created by mack on 8/8/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class WorkoutListViewController: BindableViewController {
  private let challenge: Challenge
  private let viewModel = WorkoutListViewModel()
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

  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.showsVerticalScrollIndicator = false
      tableView.registerSkeletonCellNibForClass(WorkoutListCell.self)
      tableView.registerCellNibForClass(WorkoutListCell.self)
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
  
  private lazy var dataSource = RxTableViewSectionedReloadDataSource<ChallengeSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    switch row {
    case .title(let challenge):
      return LargeTitlesAreDumbCell.configure(tableView: tableView, indexPath: indexPath, challenge: challenge)
    case .banner(let challenge, let challengeInfo):
      return ChallengeBannerCell.configure(tableView: tableView, indexPath: indexPath, challenge: challenge, challengeInfo: challengeInfo)
    case .noWorkouts(let challenge):
      return NoWorkoutsCell.configure(tableView: tableView, indexPath: indexPath)
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

  override func viewDidLoad() {
    super.viewDidLoad()
   
    navigationItem.largeTitleDisplayMode = .never
        
    viewModel.input.viewDidLoad.trigger()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  
    Track.screen(.workoutList)
  }
  
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
}

// MARK: UITableViewDataSource & UITableViewDelegate
extension WorkoutListViewController: UITableViewDelegate {
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

extension WorkoutListViewController {
  var selectedWorkoutListCell: WorkoutListCell? {
    guard let indexPath = selectedIndexPath else { return nil }
    
    return tableView.cellForRow(at: indexPath) as? WorkoutListCell
  }
  
  var selectedImageViewFrame: CGRect {
    guard let selectedWorkoutListCell = selectedWorkoutListCell else { return .zero }
    
    return selectedWorkoutListCell.workoutImageView.superview?.convert(selectedWorkoutListCell.workoutImageView.frame, to: nil) ?? .zero
  }
  
  var selectedWorkoutPhotoURL: URL? {
    return selectedWorkoutListCell?.workoutImageView.kf.webURL
  }
  
  func transitionWillStart(push: Bool) {
    if push {
      UIView.animate(withDuration: 0.3) {
        self.tableView.alpha = 0
      }
    }
  }
  
  func transitionDidEnd(push: Bool) {
    if push {
      self.tableView.alpha = 1
    }
  }
}
