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
        case 0: self?.push(ClassicChallengeViewController(), animated: true)
        case 1: self?.push(CreateChallengeViewController(), animated: true)
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
      $0.constrainHeight(50)
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

    text.topAnchor.constraint(equalTo: container.topAnchor, constant: 0).isActive = true
    text.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 20).isActive = true
    text.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -20).isActive = true
    
    text.sizeToFit()
    
    return container
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 60
  }
}
