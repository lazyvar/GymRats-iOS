//
//  CompletedChallengeViewController.swift
//  GymRats
//
//  Created by mack on 7/31/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class CompletedChallengeViewController: BindableViewController {
  private let viewModel = CompletedChallengeViewModel()
  private let disposeBag = DisposeBag()
  private let challenge: Challenge

  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.showsVerticalScrollIndicator = false
      tableView.separatorStyle = .none
    }
  }
  
  init(challenge: Challenge){
    self.challenge = challenge
    self.viewModel.configure(challenge: challenge)

    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private var dataSource = RxTableViewSectionedReloadDataSource<CompletedChallengeSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    return UITableViewCell()
  })

  override func viewDidLoad() {
    super.viewDidLoad()
  
    setupForHome()
  
    viewModel.input.viewDidLoad.trigger()
  }
  
  override func bindViewModel() {
    viewModel.output.sections
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
}
