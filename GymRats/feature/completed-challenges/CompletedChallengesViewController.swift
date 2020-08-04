//
//  CompletedChallengesViewController.swift
//  GymRats
//
//  Created by Mack on 6/1/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import GradientLoadingBar

class CompletedChallengesViewController: UITableViewController {

    var challenges: [Challenge] = []
    
    let disposeBag = DisposeBag()
    let refresher = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        tableView.separatorStyle = .none
        
        navigationItem.title = "Completed"
        
        setupMenuButton()
        setupBackButton()
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "UserWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "ChallengeCell")
        
        refresher.addTarget(self, action: #selector(fetchAllChallenges), for: .valueChanged)
        
        tableView.addSubview(refresher)

        fetchAllChallenges()
    }
    
    @objc func fetchAllChallenges() {
      showLoadingBar()
      
      Challenge.State.all.fetch()
        .subscribe(onNext: { [weak self] result in
          self?.hideLoadingBar()
          self?.refresher.endRefreshing()

          switch result {
          case .success(let challenges):
            self?.challenges = challenges.getPastChallenges()
            self?.tableView.reloadData()
          case .failure(let error):
            self?.presentAlert(with: error)
          }
        })
        .disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      if challenges.isEmpty {
        let cell = UITableViewCell()
        cell.textLabel?.text = "No challenges completed yet."
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        
        return cell
      }
      
      let challenge = challenges[indexPath.row]
      let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeCell") as! UserWorkoutTableViewCell
      
      cell.backgroundColor = .clear
      cell.challenge = challenge
      
      let thing = cell.detailsLabel.text?.split(separator: " ") ?? []
      let word = thing[thing.startIndex+1..<thing.endIndex].joined(separator: " ")
      
      cell.detailsLabel.text = word
      
      return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
      return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if challenges.isEmpty {
        return 1
      } else {
        return challenges.count
      }
    }
    
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard let challenge = challenges[safe: indexPath.row] else { return }
    
    push(CompletedChallengeViewController(challenge: challenge))
  }
}
