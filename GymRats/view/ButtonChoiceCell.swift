//
//  ButtonChoiceCell.swift
//  GymRats
//
//  Created by mack on 10/7/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import Eureka

class ButtonChoiceCell: Cell<UIImage>, CellType {
  @IBOutlet private weak var bigLabel: UILabel! {
    didSet {
      bigLabel.font = .h4Bold
      bigLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var smallLabel: UILabel! {
    didSet {
      smallLabel.font = .body
      smallLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var chevron: UIImageView! {
    didSet { chevron.tintColor = .primaryText }
  }
  
  @IBOutlet private weak var avatarImageView: UIImageView! {
    didSet {
      avatarImageView.contentMode = .scaleAspectFill
      avatarImageView.layer.cornerRadius = 18
    }
  }
  
  @IBOutlet weak var heightConstraint: NSLayoutConstraint!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    backgroundColor = .clear
    selectionStyle = .none
  }
  
  open override func update() {
    makeOneLine()
    bigLabel.text = row.title
    
    let value: UIImage? = row.value
    
    avatarImageView.image = value
    avatarImageView.isHidden = value == nil
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    animatePress(true)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
  
    (row as? ButtonChoiceRow)?.onSelect?()
    animatePress(false)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    
    animatePress(false)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    bigLabel.font = .h4Bold
    heightConstraint.constant = 80
  }
  
  private func makeOneLine() {
    bigLabel.font = .h4
    heightConstraint.constant = 60
    smallLabel.isHidden = true
  }
}

final class ButtonChoiceRow: Row<ButtonChoiceCell>, RowType {
  var onSelect: (() -> Void)?

  required public init(tag: String?) {
    super.init(tag: tag)

    cellProvider = CellProvider<ButtonChoiceCell>(nibName: "ButtonChoiceCell", bundle: Bundle.main)
  }
}
