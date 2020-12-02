//
//  ButtonChoiceCell.swift
//  GymRats
//
//  Created by mack on 10/7/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import Eureka
import Kingfisher

class ButtonChoiceCell: Cell<Either<UIImage, String>>, CellType {
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
  
  @IBOutlet weak var cellHeightConstraint: NSLayoutConstraint!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    backgroundColor = .clear
    selectionStyle = .none
  }
  
  open override func update() {
    makeOneLine()
    bigLabel.text = row.title
    
    let value: Either<UIImage, String>? = row.value
    
    avatarImageView.isHidden = value == nil

    if let value = value {
      switch value {
      case .left(let image):
        avatarImageView.image = image
      case .right(let url):
        guard let url = URL(string: url) else { return }
        avatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
      }
    }
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
    cellHeightConstraint.constant = 80
  }
  
  private func makeOneLine() {
    bigLabel.font = .h4
    cellHeightConstraint.constant = 60
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
