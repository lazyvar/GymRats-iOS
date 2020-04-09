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
import Kingfisher

typealias WorkoutSection = SectionModel<Void, WorkoutRow>

class WorkoutViewController: BindableViewController {
  private let viewModel = WorkoutViewModel()
  private let disposeBag = DisposeBag()
  private let workout: Workout
  private let challenge: Challenge?

  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .clear
      tableView.separatorColor = .divider
      tableView.separatorInset = .zero
      tableView.clipsToBounds = false
      tableView.showsVerticalScrollIndicator = false
      tableView.registerCellNibForClass(WorkoutDetailsCell.self)
      tableView.registerCellNibForClass(ImageViewCell.self)
      tableView.registerCellNibForClass(WorkoutAccountCell.self)
      tableView.registerCellNibForClass(CommentCell.self)
      tableView.registerCellNibForClass(NewCommentCell.self)
      tableView.rx.setDelegate(self).disposed(by: disposeBag)
      tableView.tableFooterView = UIView()
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
    case .image(url: let url):
      return ImageViewCell.configure(tableView: tableView, indexPath: indexPath, imageURL: url)
    case .account(let workout):
      return WorkoutAccountCell.configure(tableView: tableView, indexPath: indexPath, workout: workout)
    case .details(let workout):
      return WorkoutDetailsCell.configure(tableView: tableView, indexPath: indexPath, workout: workout)
    case .comment(let comment):
      return CommentCell.configure(tableView: tableView, indexPath: indexPath, comment: comment)
    case .newComment(let onSubmit):
      return NewCommentCell.configure(tableView: tableView, indexPath: indexPath, account: GymRats.currentAccount, onSubmit: onSubmit)
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
        
    let spookyView = SpookyView().apply {
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.isUserInteractionEnabled = false
    }
    
    view.insertSubview(spookyView, at: 0)
    
    let top = NSLayoutConstraint(
      item: spookyView,
      attribute: .top,
      relatedBy: .equal,
      toItem: tableView,
      attribute: .top,
      multiplier: 1,
      constant: 0
    )
    
    view.addConstraint(top)
    
    spookyView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
    spookyView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true
    
    let height = spookyView.constrainHeight(400)
    
    tableView.rx.contentOffset
      .map { -1 * $0.y }
      .bind(to: top.rx.constant)
      .disposed(by: disposeBag)

    tableView.rx.observe(CGSize.self, "contentSize")
      .map { $0?.height ?? 0 }
      .bind(to: height.rx.constant)
      .disposed(by: disposeBag)
    
    navigationItem.largeTitleDisplayMode = .never
    
    viewModel.input.viewDidLoad.trigger()
  }
}

extension WorkoutViewController: UITableViewDelegate {
  
}
