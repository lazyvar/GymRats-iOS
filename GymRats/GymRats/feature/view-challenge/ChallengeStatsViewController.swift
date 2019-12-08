//
//  ChallengeStatsViewController.swift
//  GymRats
//
//  Created by mack on 12/7/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class ChallengeStatsViewController: UITableViewController {
    
    let challenge: Challenge
    let users: [User]
    let workouts: [Workout]
    
    init(challenge: Challenge, users: [User], workouts: [Workout]) {
        self.challenge = challenge
        self.users = users
        self.workouts = workouts
        
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "DateProgressCell", bundle: nil), forCellReuseIdentifier: "date")
        tableView.register(UINib(nibName: "StatsBabyCell", bundle: nil), forCellReuseIdentifier: "baby")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .background
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(UIViewController.dismissSelf))
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return users.count
        default:
            fatalError("Whooop!")
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.frame = CGRect(x: 15, y: 0, width: view.frame.width - 30, height: 30)
        label.font = .proRoundedBold(size: 28)
        label.backgroundColor = .clear
        
        switch section {
        case 0:
            label.text = "Stats"
        case 1:
            label.text = "Rats"
        default:
            fatalError("5 minutes")
        }
        
        let headerView = UIView()
        headerView.addSubview(label)
        headerView.backgroundColor = .clear
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return dateCell(tableView: tableView)
            case 1:
                return statsCell()
            default:
                fatalError("WOW")
            }
        case 1:
            return userCell(row: indexPath.row)
        default:
            fatalError("Stop")
        }
    }
    
    func dateCell(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "date") as! DateProgressCell
        cell.doTheThing(challenge: challenge)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func statsCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "baby") as! StatsBabyCell
        cell.wow(challenge, workouts, users)
        
        return cell
    }
    
    func userCell(row: Int) -> UITableViewCell {
        return UITableViewCell()
    }
}
