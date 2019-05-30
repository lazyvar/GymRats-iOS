//
//  ChallengeViewController.swift
//  GymRats
//
//  Created by Mack on 5/29/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class ChallengeViewController: UIViewController {
    
    var challenge: Challenge!

    @IBOutlet weak var challengeImageView: UserImageView! {
        didSet {
            challengeImageView.load(avatarInfo: challenge)
        }
    }
    
    @IBOutlet weak var challengeTitleLabel: UILabel! {
        didSet {
            challengeTitleLabel.font = .body
            challengeTitleLabel.textColor = .white
            challengeTitleLabel.text = challenge.name
        }
    }
    
    @IBOutlet weak var challengeDetailsLabel: UILabel! {
        didSet {
            challengeDetailsLabel
                .font = .details
            challengeDetailsLabel.textColor = .white
            challengeDetailsLabel.text = challenge.daysLeft
        }
    }
    
    @IBOutlet weak var headerView: UIView! {
        didSet {
            headerView.backgroundColor = .firebrick
        }
    }
    
    lazy var chatItem = UIBarButtonItem (
        image: UIImage(named: "chat")?.withRenderingMode(.alwaysOriginal),
        style: .plain,
        target: self,
        action: #selector(openChat)
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMenuButton()
        setupBackButton()
        
        title = "💪"
        
        navigationItem.rightBarButtonItem = chatItem
    }
    
    @objc func openChat() {
        push(ChatViewController(challenge: challenge))
    }

}

extension ChallengeViewController {
    static func create(for challenge: Challenge) -> ChallengeViewController {
        let challengeViewController = ChallengeViewController.loadFromNib(from: .challenge)
        challengeViewController.challenge = challenge
        
        return challengeViewController
    }
}
