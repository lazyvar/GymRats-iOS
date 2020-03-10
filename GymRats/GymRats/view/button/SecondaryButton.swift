//
//  UIButton.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class SecondaryButton: UIButton {
  init() {
    super.init(frame: .zero)
    
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)

    setup()
  }
  
  private func setup() {
    clipsToBounds = true
    layer.masksToBounds = true
    layer.cornerRadius = 4
    layer.borderWidth = 0
    contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    titleLabel?.font = .h4
    setTitleColor(UIColor.primaryText, for: .normal)
    setTitleColor(UIColor.primaryText.darker, for: .highlighted)
    setBackgroundImage(.init(color: .foreground), for: .normal)
    setBackgroundImage(.init(color: UIColor.foreground.darker), for: .highlighted)
  }
}
