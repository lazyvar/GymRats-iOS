//
//  WorkoutViewController.swift
//  GymRats
//
//  Created by mack on 4/8/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

typealias WorkoutSection = SectionModel<Void, WorkoutRow>

class WorkoutViewController: BindableViewController {
  private let viewModel = WorkoutViewModel()
  private let disposeBag = DisposeBag()
  private let workout: Workout
  private let challenge: Challenge?

  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.separatorStyle = .none
      tableView.showsVerticalScrollIndicator = false
      tableView.registerCellNibForClass(WorkoutHeaderCell.self)
      tableView.registerCellNibForClass(CommentTableViewCell.self)
      tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
  }
  
  init(workout: Workout, challenge: Challenge?) {
    self.workout = workout
    self.challenge = challenge
    self.viewModel.configure(workout: workout)

    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private lazy var dataSource = RxTableViewSectionedReloadDataSource<WorkoutSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    switch row {
    case .header(let workout):
      return WorkoutHeaderCell.configure(tableView: tableView, indexPath: indexPath, workout: workout, delegate: self)
    case .comment(let comment):
      return CommentTableViewCell()
    case .newComment:
      return UITableViewCell()
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

    viewModel.output.navigation
      .subscribe(onNext: { [weak self] (navigation, screen) in
        self?.navigate(navigation, to: screen.viewController)
      })
      .disposed(by: disposeBag)

    tableView.rx.itemSelected
      .do(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
      })
      .bind(to: viewModel.input.tappedRow)
      .disposed(by: disposeBag)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.largeTitleDisplayMode = .never
    
    viewModel.input.viewDidLoad.trigger()
  }
}

extension WorkoutViewController: WorkoutHeaderCellDelegate {
  func tappedHeader() {
    push(
      ProfileViewController(account: workout.account, challenge: challenge)
    )
  }
  
  func layoutTableView() {
    tableView.setNeedsLayout()
    tableView.layoutIfNeeded()
    tableView.beginUpdates()
    tableView.endUpdates()
  }
}

extension WorkoutViewController: UITableViewDelegate {
  
}
