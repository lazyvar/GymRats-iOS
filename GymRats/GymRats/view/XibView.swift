//
//  XibView.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class XibView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
      
    xibSetup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    xibSetup()
  }
}

private extension XibView {
  func xibSetup() {
    loadNib().inflate(in: self)
  }
}
