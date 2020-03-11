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
  
  // MARK: Views
  
  private lazy var refresher = UIRefreshControl().apply {
    $0.addTarget(self, action: #selector(refreshValueChanged), for: .valueChanged)
  }
  
  private lazy var challengeBannerView = ChallengeBannerView().apply {
    self.configureHeader($0)
  }
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.showsVerticalScrollIndicator = false
      tableView.registerCellNibForClass(WorkoutCell.self)
      tableView.rx.setDelegate(self).disposed(by: disposeBag)
      tableView.addSubview(refresher)
      tableView.tableHeaderView = challengeBannerView
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
  
  // MARK: View lifecycle
  
  private let dataSource = RxTableViewSectionedReloadDataSource<DayWorkouts>(configureCell: WorkoutCell.configure)
  
  override func bindViewModel() {
    viewModel.output.workouts
      .do(onNext: {  [weak self] _ in
        self?.refresher.endRefreshing()
      })
      .map { [DayWorkouts(day: Date(), items: $0)] }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    viewModel.output.error
      .do(onNext: {  [weak self] _ in
        self?.refresher.endRefreshing()
      })
      .debug()
      .flatMap { UIAlertController.present($0) }
      .ignore(disposedBy: disposeBag)
  
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItems = {
      if challenge.isPast {
        return [chatBarButtonItem, menuBarButtonItem]
      } else {
        return [menuBarButtonItem]
      }
    }()
    
    viewModel.input.viewDidLoad.trigger()
  }
  
  // MARK: Button handlers
  
  @objc private func menuTapped() {
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let inviteAction = UIAlertAction(title: "Invite", style: .default) { _ in
      // TODO
      GymRatsApp.coordinator.inviteTo(self.challenge)
    }
    
    let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
      let editViewController = EditChallengeViewController(challenge: self.challenge)
      editViewController.delegate = self
      
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
    
    self.present(alertViewController, animated: true, completion: nil)
  }
  
  @objc private func chatTapped() {
    push(
      ChatViewController(challenge: challenge)
    )
  }
  
  @objc private func refreshValueChanged() {
    viewModel.input.refresh.trigger()
  }
  
  private func leaveChallenge() {
    let alert = UIAlertController(title: "Are you sure you want to leave \(challenge.name)?", message: nil, preferredStyle: .actionSheet)
    let leave = UIAlertAction(title: "Leave", style: .destructive) { _ in
      // TODO: leave challenge / reload home
    }
      
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      
    alert.addAction(leave)
    alert.addAction(cancel)
      
    present(alert, animated: true, completion: nil)
  }
  
  private func configureHeader(_ header: ChallengeBannerView) {
    let skeletonView = UIView()
    skeletonView.isSkeletonable = true
    skeletonView.showAnimatedSkeleton()
    skeletonView.showSkeleton()
    
    header.titleLabel.text = challenge.name
    
    if let pictureUrl = challenge.pictureUrl {
      header.bannerImageView.kf.setImage(with: URL(string: pictureUrl)!, placeholder: skeletonView, options: [.transition(.fade(0.2))])
      header.pictureHeight.constant = 150
    } else {
      header.pictureHeight.constant = 0
    }
    
    // TODO: fetch members and workouts
//    if users.count == 0 {
//        cell.usersLabel.text = "-\nmembers"
//    } else if users.count == 1 {
//        cell.usersLabel.text = "Solo\nchallenge"
//    } else {
//        cell.usersLabel.text = "\(users.count)\nmembers"
//    }
    
//    if workouts.count == 0 {
//        header.activityLabel.text = "-\nworkouts"
//    } else if workouts.count == 1 {
//        header.activityLabel.text = "1\nworkout"
//    } else {
//        header.activityLabel.text = "\(workouts.count)\nworkouts"
//    }

    let daysLeft = challenge.daysLeft.split(separator: " ")
    let new = daysLeft[0]
    let left = daysLeft[daysLeft.startIndex+1..<daysLeft.endIndex]
    let left2 = left.joined(separator: " ")
    let ok = new + "\n" + left2
    
    header.calendarLabel.text = ok
  }
}

// MARK: UITableViewDataSource & UITableViewDelegate
extension ChallengeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let date = dataSource[section].day
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
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNormalMagnitude
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
}

// MARK: EditChallengeDelegate
extension ChallengeViewController: EditChallengeDelegate {
  func challengeEdited(challenge: Challenge) {
    // TODO: reload home/challenge
  }
}
