//
//  HowItWorksViewController.swift
//  GymRats
//
//  Created by mack on 4/7/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class HowItWorksViewController: UIViewController {

  @IBOutlet weak var content: UILabel! {
    didSet {
      content.textColor = .primaryText
      content.font = .body
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "How it works"

    view.backgroundColor = .background
    
    setupBackButton()
  }
  
  @IBAction func gotIt(_ sender: Any) {
    push(
      TodaysGoalViewController()
    )
  }
}
