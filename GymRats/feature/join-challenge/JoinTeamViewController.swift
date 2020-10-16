//
//  JoinTeamViewController.swift
//  GymRats
//
//  Created by mack on 10/8/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

typealias JoinTeamSection = SectionModel<String?, JoinTeamRow>

class JoinTeamViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private var challenge: Challenge
  private var teams: [Team] = []

  init(_ challenge: Challenge) {
    self.challenge = challenge
    
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
      tableView.registerCellNibForClass(RankingCell.self)
      tableView.delegate = self
    }
  }

  private lazy var dataSource = RxTableViewSectionedReloadDataSource<JoinTeamSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    switch row {
      case .createTeam: return ChoiceCell.configure(tableView: tableView, indexPath: indexPath, title: "Create team")
      case .notRightNow: return ChoiceCell.configure(tableView: tableView, indexPath: indexPath, title: "Not right now")
      case .team(let team): return RankingCell.configure(tableView: tableView, indexPath: indexPath, team: team) {
        self.push(TeamViewController(team, self.challenge, joiningChallenge: true))
      }
    }
  })

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Team up"
    view.backgroundColor = .background
    setupBackButton()
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: .close, style: .plain, target: self, action: #selector(closeItUp))

    sections()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self = self else { return }

        self.tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case 0:
          switch indexPath.row {
          case 0:
            self.push(CreateTeamViewController(self.challenge))
          case 1:
            if UserDefaults.standard.bool(forKey: "account-is-onboarding") {
              GymRats.completeOnboarding()
            } else {
              self.dismissSelf()
            }
          default:
            break
          }
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  @objc private func closeItUp() {
    if UserDefaults.standard.bool(forKey: "account-is-onboarding") {
      GymRats.completeOnboarding()
    } else {
      dismissSelf()
    }
  }

  private func sections() -> Observable<[JoinTeamSection]> {
    let choices = Observable<JoinTeamSection>.just(
      JoinTeamSection(model: """
      This challenge is a team challenge. Join an existing team or create a new one and forge your own path.
      """, items: [.createTeam, .notRightNow])
    )
    
    let fetchTeams = gymRatsAPI.fetchTeams(challenge: challenge).share()
    
    fetchTeams.compactMap { $0.error }
      .subscribe(onNext: { error in
        Alert.presentAlert(error: error)
      })
      .disposed(by: disposeBag)
    
    let teams = Observable<[Team]>.merge(.just([]), fetchTeams.compactMap { $0.object })
    
    return Observable.combineLatest(choices, teams)
      .map { choices, teams in
        self.teams = teams

        return [
          choices,
          JoinTeamSection(model: "Choose team to join", items: teams.map { JoinTeamRow.team($0) })
        ]
      }
  }
}
  
extension JoinTeamViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let model = dataSource[section].model

    guard let content = model else { return nil }

    let container = UIView().apply {
      $0.backgroundColor = .clear
      $0.constrainHeight(section == 0 ? 50 : 20)
    }
    
    let text = UILabel().apply {
      $0.text = content
      $0.textColor = .primaryText
      $0.font = section == 0 ? .body : .bodyBold
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
    return section == 0 ? 50 : 35
  }
}
