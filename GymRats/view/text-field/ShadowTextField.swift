//
//  ShadowTextField.swift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class ShadowTextField: JVFloatLabeledTextField {
  private var shadowLayer: CAShapeLayer!
  
  init() {
    super.init(frame: .zero)
    
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)

    setup()
  }
  
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return super.textRect(forBounds: bounds).insetBy(dx: 10, dy: 6)
  }

  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return super.editingRect(forBounds: bounds).insetBy(dx: 10, dy: 6)
  }

  override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.rightViewRect(forBounds: bounds)
    rect.origin.x -= 10
    rect.origin.y -= 7
    
    return rect
  }

  override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.leftViewRect(forBounds: bounds)
    rect.origin.x += 10
    rect.origin.y -= 7

    return rect
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

  private func setup() {
    font = .body
    floatingLabelYPadding = 9
    floatingLabelTextColor = .secondaryText
    floatingLabelActiveTextColor = .brand
    floatingLabelFont = .details
    clearButtonMode = .whileEditing
    layer.borderWidth = 0
    borderStyle = .none
    backgroundColor = .clear
  }
}
