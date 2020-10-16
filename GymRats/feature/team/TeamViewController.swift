//
//  TeamViewController.swift
//  GymRats
//
//  Created by mack on 10/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

typealias TeamSection = SectionModel<Void, Ranking>

class TeamViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let team: Team
  private let challenge: Challenge
  private let joiningChallenge: Bool

  private var stats: Stats?
  
  init(_ team: Team, _ challenge: Challenge, joiningChallenge: Bool = false) {
    self.team = team
    self.challenge = challenge
    self.joiningChallenge = joiningChallenge
    
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
      tableView.registerCellNibForClass(RankingCell.self)
      tableView.delegate = self
    }
  }
  
  private lazy var dataSource = RxTableViewSectionedReloadDataSource<TeamSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    return RankingCell.configure(tableView: tableView, indexPath: indexPath, ranking: row, scoreBy: self.challenge.scoreBy) {
      self.push(ProfileViewController(account: row.account, challenge: self.challenge))
    }
  })

  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.largeTitleDisplayMode = .always
    title = team.name
    view.backgroundColor = .background
    setupBackButton()
    navigationItem.largeTitleDisplayMode = .always

    sections()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    gymRatsAPI.teamMembership(team)
      .subscribe(onNext: { [weak self] result in
        switch result {
        case .success:
          self?.setRightButtomMoreMenu()
        case .failure:
          self?.setRightButtomJoinButton()
        }
      })
      .disposed(by: disposeBag)
    
    if !joiningChallenge {
      Observable.merge(.just(()), reload).flatMap { _ in gymRatsAPI.teamStats(self.team) }
        .subscribe(onNext:{ [weak self] result in
          self?.stats = result.object
          self?.tableView.reloadData()
        })
        .disposed(by: disposeBag)
    }
  }
  
  private let reload = PublishSubject<Void>()
  
  private func sections() -> Observable<[TeamSection]> {
    return Observable.merge(.just(()), reload)
      .flatMap { gymRatsAPI.teamRankings(self.team) }
      .map { $0.object ?? [] }
      .map { rankings in
        return [TeamSection(model: (), items: rankings)]
      }
  }

  private func setRightButtomMoreMenu() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: .moreHorizontal, style: .plain, target: self, action: #selector(more))
  }
  
  private func setRightButtomJoinButton() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join", style: .done, target: self, action: #selector(join)).apply {
      $0.tintColor = .brand
    }
  }
  
  @objc private func join() {
    showLoadingBar()
    
    gymRatsAPI.joinTeam(team: team)
      .subscribe(onNext: { [weak self] result in
        guard let self = self else { return }
        
        self.hideLoadingBar()
        
        switch result {
        case .success(let team):
          NotificationCenter.default.post(name: .joinedTeam, object: team)
          
          if UserDefaults.standard.bool(forKey: "account-is-onboarding") {
            GymRats.completeOnboarding()
          } else if self.joiningChallenge {
            self.dismissSelf()
          } else {
            self.reload.trigger()
            self.setRightButtomMoreMenu()
          }
        case .failure(let error):
          Alert.presentAlert(error: error)
        }
      })
      .disposed(by: disposeBag)
  }
  
  @objc private func more() {
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
      let editViewController = EditChallengeViewController(challenge: self.challenge)
      
      self.present(editViewController.inNav(), animated: true, completion: nil)
    }

    let deleteAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
      self.leaveTeam()
    }
    
    let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    alertViewController.addAction(editAction)
    alertViewController.addAction(deleteAction)
    alertViewController.addAction(cancelAction)
    
    present(alertViewController, animated: true, completion: nil)
  }
  
  private func leaveTeam() {
    showLoadingBar()
    
    gymRatsAPI.leaveTeam(team)
      .subscribe(onNext: { [weak self] result in
        guard let self = self else { return }

        self.hideLoadingBar()

        switch result {
        case .success:
          NotificationCenter.default.post(name: .joinedTeam, object: nil)
          self.setRightButtomJoinButton()
          self.reload.trigger()
        case .failure(let error):
          Alert.presentAlert(error: error)
        }
      })
      .disposed(by: disposeBag)
  }
}

extension TeamViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let stats = stats, !joiningChallenge else { return nil }

    let container = UIView().apply {
      $0.backgroundColor = .clear
      $0.constrainHeight(50)
    }
    
    let style = NSMutableParagraphStyle()
    style.tabStops = [
      NSTextTab(textAlignment: .left, location: 0.0, options: [:]),
      NSTextTab(textAlignment: .left, location: ((UIScreen.main.bounds.width - 40) / 2 - 20), options: [:]),
      NSTextTab(textAlignment: .right, location: (UIScreen.main.bounds.width - 40), options: [:])
    ]

    let content = """
      \(stats.workouts) workouts\t\(stats.duration) minutes\t\(stats.distance) miles
      \(stats.calories) calories\t\(stats.steps) steps\t\(stats.points) points
      """

    let attributedString = NSMutableAttributedString(string: content, attributes: [:]).apply {
      $0.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: content.count - 1))
    }

    let text = UILabel().apply {
      $0.attributedText = attributedString
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
    return joiningChallenge ? 0 : 50
  }
}
