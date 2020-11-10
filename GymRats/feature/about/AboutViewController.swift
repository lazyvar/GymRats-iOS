//
//  AboutViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 3/3/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SafariServices

class AboutViewController: UIViewController {
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let text = """
    What's up rats!
    
    This app's goal is to act as a social motivator for fitness and health. Whether for a personal or group challenge, it is important to track workouts and hold yourself accountable. I hope you're finding it useful!

    The app's source code is open and freely available to view and do with what you like. New features are added roughly on a monthly basis. You can view the progress of ongoing work by taking a look at active milestones, the list of open issues, or the kanban board.

    If you have any ideas or suggestions on how to improve the app, please feel free to email me. I also love app store reviews, both positive and negative, so any feedback you have goes a long way.
    
    Happy ratting,

    Mack Hasz
    CPO (Chief Protein Officer)
    """
    let label = TTTAttributedLabel(frame: CGRect(x: 20, y: 5, width: self.view.frame.width-40, height: 500))
    let viewRange = (text as NSString).range(of: "view")
    let gitlabProject = URL(string: "https://gitlab.com/gym-rats")!
    let issuesRange = (text as NSString).range(of: "issues")
    let issues = URL(string: "https://gitlab.com/groups/gym-rats/-/issues")!
    let milestoneRange = (text as NSString).range(of: "milestones")
    let milestones = URL(string: "https://gitlab.com/groups/gym-rats/-/milestones")!
    let boardRange = (text as NSString).range(of: "kanban board")
    let board = URL(string: "https://gitlab.com/groups/gym-rats/-/boards")!
    let emailRange = (text as NSString).range(of: "email")
    let email = URL(string: "mailto:suggestion@gymrats.app")!
    let appStoreReviewRange = (text as NSString).range(of: "app store reviews")
    let appStoreReview = URL(string: "https://itunes.apple.com/app/id1453444814?action=write-review")!

    label.font = .body
    label.textAlignment = .left
    label.textColor = .primaryText
    label.lineSpacing = 2
    label.numberOfLines = 0
    label.isUserInteractionEnabled = true
    label.delegate = self
    label.text = text

    label.activeLinkAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.brand,
    ]
    
    label.linkAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.brand.darker,
    ]

    label.addLink(to: gitlabProject, with: viewRange)
    label.addLink(to: issues, with: issuesRange)
    label.addLink(to: milestones, with: milestoneRange)
    label.addLink(to: board, with: boardRange)
    label.addLink(to: email, with: emailRange)
    label.addLink(to: appStoreReview, with: appStoreReviewRange)

    label.sizeToFit()

    view.isUserInteractionEnabled = true
    view.backgroundColor = .background
    view.addSubview(label)
    
    title = "About"

    setupMenuButton()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  
    Track.screen(.about)
  }
}

extension AboutViewController: TTTAttributedLabelDelegate {
  func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    if url.absoluteString.contains("mailto:") || url.absoluteString.contains("itunes.apple.com") {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
      let ok = SFSafariViewController(url: url)
    
      self.present(ok, animated: true, completion: nil)
    }
  }
}
