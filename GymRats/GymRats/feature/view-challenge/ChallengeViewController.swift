//
//  ChallengeViewController.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChallengeViewController: BindableViewController {
  
  // MARK: Init
  
  private let challenge: Challenge
  private let viewModel = ChallengeViewModel()
  private let disposeBag = DisposeBag()

  init(challenge: Challenge) {
    self.challenge = challenge
    
    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Views
  
  private lazy var refresher = UIRefreshControl().apply {
    $0.addTarget(self, action: #selector(refreshValueChanged), for: .valueChanged)
  }
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.showsVerticalScrollIndicator = false
      tableView.registerCellNibForClass(ChallengeBannerCell.self)
      tableView.registerCellNibForClass(WorkoutCell.self)

      tableView.addSubview(refresher)
    }
  }

  private lazy var chatBarButtonItem = UIBarButtonItem (
    image: .chatGray,
    style: .plain,
    target: self,
    action: #selector(chatTapped)
  )
  
  private lazy var menuBarButtonItem = UIBarButtonItem(
    image: .moreVertical,
    style: .plain,
    target: self,
    action: #selector(menuTapped)
  ).apply { $0.tintColor = .lightGray }
  
  // MARK: View lifecycle
  
  override func bindViewModel() {
    // ...
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItems = {
      if challenge.isPast {
        return [chatBarButtonItem, menuBarButtonItem]
      } else {
        return [menuBarButtonItem]
      }
    }()
  }
  
  // MARK: Button handlers
  
  @objc private func menuTapped() {
    
  }
  
  @objc private func chatTapped() {
    
  }
  
  @objc private func refreshValueChanged() {
    
  }
}

// MARK: UITableViewDataSource & UITableViewDelegate
extension ChallengeViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
}
