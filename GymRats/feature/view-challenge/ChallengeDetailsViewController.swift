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
      tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
      tableView.rx.setDelegate(self).disposed(by: disposeBag)
      tableView.registerCellNibForClass(FullLeaderboardCell.self)
      tableView.registerCellNibForClass(LargeTitlesAreDumbCell.self)
      tableView.registerCellNibForClass(ChallengeDetailsHeader.self)
      tableView.registerCellNibForClass(RankingCell.self)
      tableView.registerCellNibForClass(MembersCell.self)
      tableView.registerCellNibForClass(GroupStatCell.self)
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
    case .title(let challenge):
      return LargeTitlesAreDumbCell.configure(tableView: tableView, indexPath: indexPath, challenge: challenge)
    case .header(let challenge):
      return ChallengeDetailsHeader.configure(tableView: tableView, indexPath: indexPath, challenge: challenge)
    case .members(let members):
      return MembersCell.configure(
        tableView: tableView,
        indexPath: indexPath,
        challenge: self.challenge,
        avatars: members,
        showInviteAtEnd: self.challenge.startDate.serverDateIsToday,
        onAdd: {
          ChallengeFlow.invite(to: self.challenge)
        },
        press: { avatar in
          guard let account = avatar as? Account else { return }
          
          self.push(ProfileViewController(account: account, challenge: self.challenge))
        }
      )
    case .fullIndividualLeaderboard:
      return FullLeaderboardCell.configure(tableView: tableView, indexPath: indexPath) {
        self.push(RankingsViewController(challenge: self.challenge))
      }
    case .fullTeamLeaderboard:
      return FullLeaderboardCell.configure(tableView: tableView, indexPath: indexPath) {
        // TODO
      }
    case .ranking(let ranking, let place, let scoreBy):
      return RankingCell.configure(tableView: tableView, indexPath: indexPath, ranking: ranking, place: place, scoreBy: scoreBy) {
        self.push(ProfileViewController(account: ranking.account, challenge: self.challenge))
      }
    case .groupStats(let avatar, let image, let top, let bottom, let right):
      return GroupStatCell.configure(tableView: tableView, indexPath: indexPath, avatar: avatar, image: image, topLabel: top, bottomLabel: bottom, rightLabel: right)
    case .teams(let teams):
      return MembersCell.configure(
        tableView: tableView,
        indexPath: indexPath,
        challenge: self.challenge,
        avatars: teams,
        showInviteAtEnd: true,
        onAdd: {
          self.presentForClose(CreateTeamViewController(self.challenge))
        },
        press: { avatar in
          guard let team = avatar as? Team else { return }
          
          self.push(TeamViewController(team, self.challenge))
        }
      )
    case .teamRanking(let teamRanking, let place, let scoreBy):
      return RankingCell.configure(tableView: tableView, indexPath: indexPath, teamRanking: teamRanking, place: place, scoreBy: scoreBy) {
        self.push(TeamViewController(teamRanking.team, self.challenge))
      }
    }
  })

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.largeTitleDisplayMode = .never
    
    viewModel.input.viewDidLoad.trigger()
  }
  
  override func bindViewModel() {
    viewModel.output.sections
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    viewModel.output.loading
      .subscribe(onNext: { loading in
        if loading {
          self.showLoadingBar()
        } else {
          self.hideLoadingBar()
        }
      })
      .disposed(by: disposeBag)
  }
}

extension ChallengeDetailsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let model = dataSource[section].model

    guard let header = model else { return nil }
    
    let label = UILabel()
    label.backgroundColor = .clear
    label.font = .h4Bold
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
