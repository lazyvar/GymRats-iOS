//
//  HealthAppPermissionsViewController.swift
//  GymRats
//
//  Created by mack on 5/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class HealthAppPermissionsViewController: UIViewController {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.textColor = .primaryText
      titleLabel.font = .h4Bold
    }
  }
  
  @IBOutlet private weak var bodyLabel: UILabel! {
    didSet {
      bodyLabel.textColor = .primaryText
      bodyLabel.font = .body
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .background
  }
  
  @IBAction private func closeButtonPressed(_ sender: Any) {
    self.dismissSelf()
  }
}
