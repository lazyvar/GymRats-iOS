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
  
  @IBOutlet private weak var spooky: SpookyView! {
    didSet {
      spooky.spookyColor = .brand
    }
  }
  
  @IBOutlet private weak var label: UILabel! {
    didSet {
      label.font = .h4Bold
      label.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var play: UIImageView! {
    didSet {
      play.tintColor = .primaryText
    }
  }
  
  @IBOutlet private weak var chevron: UIImageView! {
    didSet {
      chevron.tintColor = .primaryText
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    animatePress(true)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    animatePress(false)
    press?()
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    
    animatePress(false)
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, press: @escaping () -> Void) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: NewChallengeButtonCell.self, for: indexPath).apply {
      $0.press = press
    }
  }
}
