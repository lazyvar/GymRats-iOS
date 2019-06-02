//
//  ArchivedChallengesTableViewController.swift
//  GymRats
//
//  Created by Mack on 6/1/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import GradientLoadingBar

class ArchivedChallengesTableViewController: UITableViewController {

    var challenges: [Challenge] = []
    
    let disposeBag = DisposeBag()
    let refresher = UIRefreshControl()
    let retryButton: UIButton = .danger(text: "Retry")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        title = "Past Challenges"
        
        setupBackButton()
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "UserWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "ChallengeCell")
        
        refresher.addTarget(self, action: #selector(fetchAllChallenges), for: .valueChanged)
        
        tableView.addSubview(refresher)
        
        retryButton.onTouchUpInside { [weak self] in
            self?.fetchAllChallenges()
        }.disposed(by: disposeBag)
        
        fetchAllChallenges()
    }
    
    @objc func fetchAllChallenges() {
        retryButton.isHidden = true
        showLoadingBar()
        
        gymRatsAPI.getAllChallenges()
            .subscribe(onNext: { [weak self] challenges in
                self?.hideLoadingBar()
                self?.refresher.endRefreshing()
                
                let inactive = challenges.getInActiveChallenges()
                self?.challenges = inactive
                
                if inactive.isEmpty {
                    // TODO
                } else {
                    self?.tableView.reloadData()
                }
            }, onError: { [weak self] error in
                self?.refresher.endRefreshing()
                self?.hideLoadingBar()
                self?.retryButton.isHidden = false
            }).disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeCell") as! UserWorkoutTableViewCell
        let challenge = challenges[indexPath.row]
        
        cell.challenge = challenge
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challenges.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let challenge = challenges[indexPath.row]
        
        push(ChallengeViewController.create(for: challenge))
    }
    
}

extension ArchivedChallengesTableViewController: CreateChallengeDelegate {
    
    func challengeCreated(challenge: Challenge) {
        self.fetchAllChallenges()
    }
    
}

