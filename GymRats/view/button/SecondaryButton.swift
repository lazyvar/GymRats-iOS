//
//  UIButton.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class SecondaryButton: UIButton {
  private var shadowLayer: CAShapeLayer!
  
  init() {
    super.init(frame: .zero)
    
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)

    setup()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()

    if shadowLayer == nil {
      shadowLayer = CAShapeLayer()
      shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 4).cgPath
      shadowLayer.fillColor = UIColor.foreground.cgColor

      shadowLayer.shadowColor = UIColor.shadow.cgColor
      shadowLayer.shadowPath = shadowLayer.path
      shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
      shadowLayer.shadowOpacity = 1
      shadowLayer.shadowRadius = 2

      layer.insertSublayer(shadowLayer, at: 0)
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    shadowLayer?.fillColor = UIColor.foreground.darker.cgColor
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    shadowLayer?.fillColor = UIColor.foreground.cgColor
  }
  
  private func setup() {
    layer.borderWidth = 0
    contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    titleLabel?.font = .h4
    setTitleColor(UIColor.primaryText, for: .normal)
    setTitleColor(UIColor.primaryText.darker, for: .highlighted)
  }
}
