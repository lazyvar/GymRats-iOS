//
//  HeaderTwoLabel.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class HeaderTwoLabel: UILabel {
  init() {
    super.init(frame: .zero)
    
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)

    setup()
  }
  
  private func setup() {
    font = .h2
  }
}
