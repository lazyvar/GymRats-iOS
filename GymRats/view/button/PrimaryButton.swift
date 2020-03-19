//
//  PrimaryButton.swift
//  GymRats
//
//  Created by mack on 3/16/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class PrimaryButton: UIButton {
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
    setTitleColor(UIColor.white, for: .normal)
    setTitleColor(UIColor.white.darker, for: .highlighted)
    setBackgroundImage(.init(color: .brand), for: .normal)
    setBackgroundImage(.init(color: UIColor.brand.darker), for: .highlighted)
  }
}
