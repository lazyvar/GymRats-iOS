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
  
  private let disposeBag = DisposeBag()
  private let refresher = UIRefreshControl()

  @IBOutlet private weak var tableView: UITableView!
  
  override func bindViewModel() {
    // ...
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // PRELOAD MAPS
        
    // refresher.addTarget(self, action: #selector(fetchUserWorkouts), for: .valueChanged)
    tableView.addSubview(refresher)
    
    // set up nav
    
    tableView.showsVerticalScrollIndicator = false
    tableView.register(UINib(nibName: "GoatCell", bundle: nil), forCellReuseIdentifier: "goat")
    tableView.register(UINib(nibName: "TwerkoutCell", bundle: nil), forCellReuseIdentifier: "twer")
    tableView.register(UINib(nibName: "LeaderboardCell", bundle: nil), forCellReuseIdentifier: "ld")
  }
}

extension ChallengeViewController: UITableViewDelegate {
  
}

extension ChallengeViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
}
