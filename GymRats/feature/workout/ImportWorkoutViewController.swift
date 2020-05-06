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

typealias ImportWorkoutSection = SectionModel<Void, ImportWorkoutRow>

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
      tableView.registerCellNibForClass(HealthAppWorkoutCell.self)
      tableView.separatorStyle = .none
    }
  }
  
  private lazy var dataSource = RxTableViewSectionedReloadDataSource<ImportWorkoutSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    switch row {
    case .workout(let workout):
      return HealthAppWorkoutCell.configure(tableView: tableView, indexPath: indexPath, workout: workout)
    case .noWorkouts:
      return UITableViewCell().apply {
        $0.textLabel?.text = "There are no workouts to import. Add some workouts to the Health App and they will show here."
        $0.backgroundColor = .clear
        $0.textLabel?.numberOfLines = 0
      }
    }
  })

  override func bindViewModel() {
    viewModel.output.sections
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    viewModel.output.selectedWorkout
      .subscribe(onNext: { [weak self] workout in
        guard let self = self else { return }
        
        self.delegate?.importWorkoutViewController(self, imported: workout)
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
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: .close, style: .plain, target: self, action: #selector(dismissSelf))
    title = "Import workout"
    
    viewModel.input.viewDidLoad.trigger()
  }
}