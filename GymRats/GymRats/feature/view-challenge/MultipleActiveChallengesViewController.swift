//
//  MultipleActiveChallengesViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/6/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class MultipleActiveChallengesViewController: UITableViewController {
    
    let disposeBag = DisposeBag()
    let challenges: [Challenge]
    let refresher = UIRefreshControl()
    
    init(challenges: [Challenge]) {
        self.challenges = challenges
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupForHome()
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "UserWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "ChallengeCell")
        
        refresher.addTarget(self, action: #selector(reload), for: .valueChanged)
        
        tableView.addSubview(refresher)
        
        reload()
    }
    
    @objc func reload() {
        // refresher.beginRefreshing()
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
        
        push(ActiveChallengeViewController(challenge: challenge))
    }

}
