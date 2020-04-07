//
//  TodaysGoalViewController.swift
//  GymRats
//
//  Created by mack on 4/7/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift

typealias Goal = (title: String, description: String)
typealias GoalSection = SectionModel<Void, Goal>

class TodaysGoalViewController: BindableViewController {
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.separatorStyle = .none
      tableView.showsVerticalScrollIndicator = false
      tableView.registerCellNibForClass(ChoiceCell.self)
    }
  }
    
  private let disposeBag = DisposeBag()
  
  private let dataSource = RxTableViewSectionedReloadDataSource<GoalSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    return ChoiceCell.configure(tableView: tableView, indexPath: indexPath, goal: row)
  })

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "What's the goal today?"
  }
  
  override func bindViewModel() {
    Observable<[GoalSection]>
      .just([.init(model: (), items: [
        (title: "Start a challenge", description: "Let's do this!"),
        (title: "Join a challenge", description: "Get in there."),
        (title: "Nothing", description: "I'm just here to poke around."),
      ])])
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0: return
        case 1: return
        case 2: GymRats.completeOnboarding()
        default: fatalError("Unhandled row.")
        }
      })
      .disposed(by: disposeBag)
  }
}
