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
        
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFProRounded-Bold", size: 30)!]
        
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        tableView.separatorStyle = .none
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.view.backgroundColor = UIColor.white
        
        view.backgroundColor = .white
        navigationItem.title = "Completed"
        
        setupMenuButton()
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
                
                let past = challenges.getPastChallenges()
                self?.challenges = past
                
                self?.tableView.reloadData()
            }, onError: { [weak self] error in
                self?.refresher.endRefreshing()
                self?.hideLoadingBar()
                self?.retryButton.isHidden = false
            }).disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if challenges.isEmpty {
            let cell = UITableViewCell()
            cell.textLabel?.text = "No challenges completed yet."
            cell.selectionStyle = .none
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeCell") as! UserWorkoutTableViewCell
        let challenge = challenges[indexPath.row]
        
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
        if challenges.count == 0 {
           return 1
        } else {
            return challenges.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if challenges.count == 0 { return }
        
        let challenge = challenges[indexPath.row]
        
        push(ArtistViewController(challenge: challenge))
    }
    
}
