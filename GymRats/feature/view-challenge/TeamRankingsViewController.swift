//
//  RankingsViewController.swift
//  GymRats
//
//  Created by mack on 8/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class TeamRankingsViewController: BindableViewController {
  private let disposeBag = DisposeBag()
  private let challenge: Challenge
  private lazy var scoreBy = challenge.scoreBy
  private let refresher = PublishSubject<Void>()

  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.showsVerticalScrollIndicator = false
      tableView.separatorStyle = .none
      tableView.allowsSelection = false
      tableView.delegate = self
      tableView.registerCellNibForClass(RankingCell.self)
    }
  }

  init(challenge: Challenge) {
    self.challenge = challenge
    
    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Void, TeamRanking>>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    return RankingCell.configure(tableView: tableView, indexPath: indexPath, teamRanking: row, place: indexPath.row + 1, scoreBy: self.scoreBy) {
      self.push(TeamViewController(row.team, self.challenge))
    }
  })
 
  private lazy var scoreByButton = UIBarButtonItem(title: self.scoreBy.title.capitalized, style: .done, target: self, action: #selector(showAlert))
  
  override func bindViewModel() { }
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    tableView.contentInsetAdjustmentBehavior = .never
    navigationItem.largeTitleDisplayMode = .always
    navigationItem.rightBarButtonItem = scoreByButton
    navigationItem.title = "Team rankings"
    navigationItem.rightBarButtonItem?.tintColor = .brand
    navigationItem.rightBarButtonItem?.setTitleTextAttributes([
      NSAttributedString.Key.font: UIFont.bodyBold
    ], for: .normal)
    navigationItem.rightBarButtonItem?.setTitleTextAttributes([
      NSAttributedString.Key.font: UIFont.bodyBold
    ], for: .selected)
    navigationItem.rightBarButtonItem?.setTitleTextAttributes([
      NSAttributedString.Key.font: UIFont.bodyBold
    ], for: .disabled)

    refresher
      .flatMap {
        return gymRatsAPI.getTeamRankings(challenge: self.challenge, scoreBy: self.scoreBy)
      }
      .do(onNext: { [weak self] _ in
        self?.navigationItem.rightBarButtonItem?.isEnabled = true
        self?.hideLoadingBar()
      })
      .compactMap { $0.object }
      .map { rankings in
        [SectionModel(model: (), items: rankings)]
      }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    refresh()
  }
  
  @objc private func showAlert() {
    let alertViewController = UIAlertController()
    
    let workouts = UIAlertAction(title: "Workouts", style: .default) { _ in
      self.scoreBy = .workouts
      self.refresh()
    }

    let duration = UIAlertAction(title: "Duration", style: .default) { _ in
      self.scoreBy = .duration
      self.refresh()
    }

    let distance = UIAlertAction(title: "Distance", style: .default) { _ in
      self.scoreBy = .distance
      self.refresh()
    }

    let cals = UIAlertAction(title: "Calories", style: .default) { _ in
      self.scoreBy = .calories
      self.refresh()
    }

    let steps = UIAlertAction(title: "Steps", style: .default) { _ in
      self.scoreBy = .steps
      self.refresh()
    }

    let points = UIAlertAction(title: "Points", style: .default) { _ in
      self.scoreBy = .points
      self.refresh()
    }

    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alertViewController.addAction(workouts)
    alertViewController.addAction(duration)
    alertViewController.addAction(distance)
    alertViewController.addAction(cals)
    alertViewController.addAction(steps)
    alertViewController.addAction(points)
    alertViewController.addAction(cancel)
    
    present(alertViewController, animated: true, completion: nil)
  }
  
  private func refresh() {
    showLoadingBar()
    navigationItem.rightBarButtonItem?.isEnabled = false
    navigationItem.rightBarButtonItem?.title = "Sorted by \(scoreBy.title)"
    refresher.trigger()
  }
}

extension TeamRankingsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return .leastNormalMagnitude
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return nil
  }
}
