//
//  SpookyView.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class SpookyView: UIView {
  private var shadowLayer: CAShapeLayer!

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

      addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
      
      layer.insertSublayer(shadowLayer, at: 0)
    }
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "bounds" {
      self.shadowLayer?.path = UIBezierPath(roundedRect: bounds, cornerRadius: 4).cgPath
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }
}
