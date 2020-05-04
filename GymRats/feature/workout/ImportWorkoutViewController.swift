//
//  ImportWorkoutViewController.swift
//  GymRats
//
//  Created by mack on 5/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import HealthKit
import RxSwift
import RxDataSources
import UIScrollView_InfiniteScroll

typealias ImportWorkoutSection = SectionModel<Void, HKWorkout>

protocol ImportWorkoutViewControllerDelegate: class {
  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, imported workout: HKWorkout)
}

class ImportWorkoutViewController: BindableViewController {
  weak var delegate: ImportWorkoutViewControllerDelegate?
  
  private let disposeBag = DisposeBag()
  private let viewModel = ImportWorkoutViewModel()
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.showsVerticalScrollIndicator = false
      tableView.registerSkeletonCellNibForClass(WorkoutBigCell.self)
      tableView.registerCellNibForClass(WorkoutBigCell.self)
      tableView.registerSkeletonCellNibForClass(WorkoutListCell.self)
      tableView.registerCellNibForClass(WorkoutListCell.self)
      tableView.registerCellNibForClass(NoWorkoutsCell.self)
      tableView.registerCellNibForClass(ChallengeBannerCell.self)
      tableView.infiniteScrollTriggerOffset = 500

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
      
//      tableView.addInfiniteScroll { [weak self] _ in
//        self?.viewModel.input.infiniteScrollTriggered.trigger()
//      }
//      
//      tableView.setShouldShowInfiniteScrollHandler { [weak self] _ -> Bool in
//        return self?.shouldShowInfScroll ?? false
//      }
    }
  }
  
  private lazy var dataSource = RxTableViewSectionedReloadDataSource<ImportWorkoutSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    return UITableViewCell()
  })

  override func bindViewModel() {
    viewModel.output.sections
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    viewModel.output.error
      .debug()
      .flatMap { UIAlertController.present($0) }
      .ignore(disposedBy: disposeBag)
    
    tableView.rx.itemSelected
      .do(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
      })
      .bind(to: viewModel.input.tappedRow)
      .disposed(by: disposeBag)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
}
