//
//  EnableTeamsViewController.swift
//  GymRats
//
//  Created by mack on 10/7/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

enum EnableTeamsChoice: String, CaseIterable {
  case yup
  case noThanks
  
  var title: String {
    switch self {
    case .yup: return "Yes"
    case .noThanks: return "No, thanks"
    }
  }
}

typealias EnableTeamsSection = SectionModel<Void, EnableTeamsChoice>

class EnableTeamsViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private var newChallenge: NewChallenge

  init(_ newChallenge: NewChallenge) {
    self.newChallenge = newChallenge
    
    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.separatorStyle = .none
      tableView.showsVerticalScrollIndicator = false
      tableView.registerCellNibForClass(ChoiceCell.self)
      tableView.delegate = self
    }
  }

  private let dataSource = RxTableViewSectionedReloadDataSource<EnableTeamsSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    return ChoiceCell.configure(tableView: tableView, indexPath: indexPath, choice: row)
  })

  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Enable teams?"
    view.backgroundColor = .background
    setupBackButton()

    Observable<[EnableTeamsSection]>
      .just([.init(model: (), items: EnableTeamsChoice.allCases)])
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
        case 0: self?.yes()
        case 1: self?.no()
        default: fatalError("Unhandled row.")
        }
      })
      .disposed(by: disposeBag)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  
    Track.screen(.enableTeams)
  }
  
  private func yes() {
    newChallenge.teamsEnabled = true
    push(FirstTeamViewController(newChallenge), animated: true)
  }

  private func no() {
    newChallenge.teamsEnabled = false
    push(CreateChallengeReviewViewController(newChallenge: newChallenge), animated: true)
  }
}
  
extension EnableTeamsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let container = UIView().apply {
      $0.backgroundColor = .clear
      $0.constrainHeight(72)
    }
    
    let text = UILabel().apply {
      $0.text = """
      Make this challenge a team challenge by allowing group members to join together and form squads. Rankings will be determined by team score rather than individual.
      """
      $0.textColor = .primaryText
      $0.font = .body
      $0.numberOfLines = 0
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    container.addSubview(text)
    
    text.topAnchor.constraint(equalTo: container.topAnchor, constant: 0).isActive = true
    text.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 20).isActive = true
    text.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -20).isActive = true
    
    text.sizeToFit()

    return container
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 72
  }
}
