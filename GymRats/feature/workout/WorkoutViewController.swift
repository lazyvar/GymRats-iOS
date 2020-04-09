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
import RxKeyboard

typealias WorkoutSection = AnimatableSectionModel<Nothing, WorkoutRow>

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

  private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<WorkoutSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    switch row {
    case .image(url: let url):
      return ImageViewCell.configure(tableView: tableView, indexPath: indexPath, imageURL: url)
    case .account(let workout):
      return WorkoutAccountCell.configure(tableView: tableView, indexPath: indexPath, workout: workout)
    case .details(let workout):
      return WorkoutDetailsCell.configure(tableView: tableView, indexPath: indexPath, workout: workout)
    case .comment(let comment, let onMenuTap):
      return CommentCell.configure(tableView: tableView, indexPath: indexPath, comment: comment, onMenuTap: onMenuTap)
    case .newComment(let onSubmit):
      return NewCommentCell.configure(tableView: tableView, indexPath: indexPath, account: GymRats.currentAccount, onSubmit: onSubmit)
    }
  })
  
  override func bindViewModel() {
    viewModel.output.sections
      .do(onNext: { _ in self.hideLoadingBar() })
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)

    viewModel.output.error
      .do(onNext: { _ in self.hideLoadingBar() })
      .flatMap { UIAlertController.present($0) }
      .ignore(disposedBy: disposeBag)

    viewModel.output.navigation
      .subscribe(onNext: { [weak self] (navigation, screen) in
        self?.navigate(navigation, to: screen.viewController)
      })
      .disposed(by: disposeBag)

    viewModel.output.presentCommentAlert
      .subscribe { [weak self] e in
        if let comment = e.element {
          self?.showCommentMenu(comment)
        }
      }
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .do(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
      })
      .bind(to: viewModel.input.tappedRow)
      .disposed(by: disposeBag)
    
    RxKeyboard.instance.visibleHeight
      .drive(onNext: { [tableView] keyboardVisibleHeight in
        tableView?.contentInset.bottom = keyboardVisibleHeight + 30
      })
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
    
    let tapToHideKeyboard = UITapGestureRecognizer()
    tapToHideKeyboard.numberOfTapsRequired = 1
    tapToHideKeyboard.addTarget(self, action: #selector(hideKeyboard))
    tapToHideKeyboard.cancelsTouchesInView = false
    
    view.addGestureRecognizer(tapToHideKeyboard)

    navigationItem.rightBarButtonItem = UIBarButtonItem (
      image: .moreVertical,
      style: .plain,
      target: self,
      action: #selector(showWorkoutMenu)
    )
    
    viewModel.input.viewDidLoad.trigger()
  }

  @objc private func hideKeyboard() {
    view.endEditing(true)
  }
  
  private func showCommentMenu(_ comment: Comment) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let delete = UIAlertAction(title: "Delete comment", style: .destructive) { [weak self] _ in
      let areYouSureAlert = UIAlertController(title: "Are you sure?", message: "This will permanently remove the comment.", preferredStyle: .alert)
      
      let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
        guard let self = self else { return }
        
        self.showLoadingBar()
        self.viewModel.input.tappedDeleteComment.onNext(comment)
      }
      
      let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      
      areYouSureAlert.addAction(delete)
      areYouSureAlert.addAction(cancel)
      
      self?.present(areYouSureAlert, animated: true, completion: nil)
    }
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alert.addAction(delete)
    alert.addAction(cancel)
    
    self.present(alert, animated: true, completion: nil)
  }
  
  @objc private func showWorkoutMenu() {
    let deleteAction = UIAlertAction(title: "Remove workout", style: .destructive) { _ in
      let areYouSureAlert = UIAlertController(title: "Are you sure?", message: "You will not be able to recover a workout once it has been removed.", preferredStyle: .alert)
      
      let deleteAction = UIAlertAction(title: "Remove", style: .destructive) { _ in
          self.showLoadingBar()
        
          gymRatsAPI.deleteWorkout(self.workout)
            .subscribe(onNext: { [weak self] result in
              guard let self = self else { return }
              
              self.hideLoadingBar()
              
              switch result {
              case .success:
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: .workoutDeleted, object: self.workout)
              case .failure(let error):
                self.presentAlert(with: error)
              }
            })
            .disposed(by: self.disposeBag)
        }
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      
      areYouSureAlert.addAction(deleteAction)
      areYouSureAlert.addAction(cancelAction)
      
      self.present(areYouSureAlert, animated: true, completion: nil)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alertViewController.addAction(deleteAction)
    alertViewController.addAction(cancelAction)

    self.present(alertViewController, animated: true, completion: nil)
  }
}

extension WorkoutViewController: UITableViewDelegate {
  
}
