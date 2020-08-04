//
//  ChallengeDetailsViewController.swift
//  GymRats
//
//  Created by mack on 8/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class ChallengeDetailsViewController: BindableViewController {
  private let disposeBag = DisposeBag()
  private let viewModel = ChallengeDetailsViewModel()
  private let challenge: Challenge
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.showsVerticalScrollIndicator = false
      tableView.separatorStyle = .none
      tableView.allowsSelection = false
      tableView.rx.setDelegate(self).disposed(by: disposeBag)
      tableView.registerCellNibForClass(ChallengeBannerImageCell.self)
      tableView.registerCellNibForClass(ChallengeCompleteDescriptionCell.self)
      tableView.registerCellNibForClass(ShareChallengeButtonCell.self)
      tableView.registerCellNibForClass(NewChallengeButtonCell.self)
      tableView.registerCellNibForClass(RankingCell.self)
    }
  }
  
  init(challenge: Challenge) {
    self.challenge = challenge
    self.viewModel.configure(challenge: challenge)

    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private lazy var dataSource = RxTableViewSectionedReloadDataSource<ChallengeDetailsSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    switch row {
    case .header(let challenge):
      return UITableViewCell()
    case .members(let members):
      return UITableViewCell()
    case .fullLeaderboard:
      return UITableViewCell()
    case .ranking(let ranking):
      return UITableViewCell()
    case .groupStats:
      return UITableViewCell()
    }
  })

  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewModel.input.viewDidLoad.trigger()
  }
  
  override func bindViewModel() {
    viewModel.output.sections
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
}

extension ChallengeDetailsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let model = dataSource[section].model

    guard let header = model else { return nil }
    
    let label = UILabel()
    label.backgroundColor = .clear
    label.font = .h4
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = header

    let headerView = UIView()
    headerView.addSubview(label)
    headerView.backgroundColor = .clear
    
    label.verticallyCenter(in: headerView)
    label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let model = dataSource[section].model

    guard model != nil else { return .zero }

    return 35
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNormalMagnitude
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
}
