//
//  NewChallengeButtonCell.swift
//  GymRats
//
//  Created by mack on 7/31/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class NewChallengeButtonCell: UITableViewCell {
  private var press: (() -> Void)?
  
  @IBAction private func pressMe(_ sender: Any) {
    press?()
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, press: @escaping () -> Void) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: NewChallengeButtonCell.self, for: indexPath).apply {
      $0.press = press
    }
  }
}
