//
//  ChooseChallengeModeViewController.swift
//  GymRats
//
//  Created by mack on 4/13/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

typealias ChallengeModeSection = SectionModel<Void, ChallengeMode>

class ChooseChallengeModeViewController: BindableViewController {
  private let disposeBag = DisposeBag()

  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.separatorStyle = .none
      tableView.showsVerticalScrollIndicator = false
      tableView.registerCellNibForClass(ChoiceCell.self)
      tableView.delegate = self
    }
  }

  private let dataSource = RxTableViewSectionedReloadDataSource<ChallengeModeSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    return ChoiceCell.configure(tableView: tableView, indexPath: indexPath, mode: row)
  })

  override func viewDidLoad() {
    super.viewDidLoad()
    
    if presentingViewController != nil {
      navigationItem.leftBarButtonItem = UIBarButtonItem(image: .close, style: .plain, target: self, action: #selector(dismissSelf))
    }
    
    title = "Choose mode"
  }

  override func bindViewModel() {
    Observable<[ChallengeModeSection]>
      .just([.init(model: (), items: ChallengeMode.allCases)])
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0: self?.push(JoinChallengeViewController())
        case 1: self?.push(JoinChallengeViewController())
        default: fatalError("Unhandled row.")
        }
      })
      .disposed(by: disposeBag)
  }
}

extension ChooseChallengeModeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let container = UIView().apply {
      $0.backgroundColor = .clear
      $0.constrainHeight(75)
    }
    
    let text = UILabel().apply {
      $0.text = """
      Pick your challenge mode. Classic is a 30 day challenge where the winner is determined by most total workouts.
      """
      $0.textColor = .primaryText
      $0.font = .body
      $0.numberOfLines = 0
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    container.addSubview(text)
    
    text.fill(in: container, top: 5, bottom: -5, left: 20, right: -20)
    
    return container
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 75
  }
}
