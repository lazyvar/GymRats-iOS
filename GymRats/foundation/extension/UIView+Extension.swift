//
//  UIView+Extension.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension UIView {

  /// Loads instance from nib with the same name.
  func loadNib() -> UIView {
    let bundle = Bundle(for: type(of: self))
    let nibName = type(of: self).description().components(separatedBy: ".").last!
    let nib = UINib(nibName: nibName, bundle: bundle)
    
    return nib.instantiate(withOwner: self, options: nil).first as! UIView
  }

    func center(in view: UIView, x: CGFloat = 0, y: CGFloat = 0) {
        horizontallyCenter(in: view, x: x)
        verticallyCenter(in: view, y: y)
    }
    
    func fill(in view: UIView, top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) {
      self.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
      self.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
      self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
      self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
  
    /// Fills the view to all the anchors of the parent view.
    func inflate(in parent: UIView) {
      translatesAutoresizingMaskIntoConstraints = false
      parent.addSubview(self)

      NSLayoutConstraint.activate(
        [
          leadingAnchor.constraint(equalTo: parent.leadingAnchor),
          trailingAnchor.constraint(equalTo: parent.trailingAnchor),
          topAnchor.constraint(equalTo: parent.topAnchor),
          bottomAnchor.constraint(equalTo: parent.bottomAnchor),
        ]
      )
    }
  
    @discardableResult func horizontallyCenter(in view: UIView, x: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint (
            item: self,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1,
            constant: x
        )

        view.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult func verticallyCenter(in view: UIView, y: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint (
            item: self,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerY,
            multiplier: 1,
            constant: y
        )
        
        view.addConstraint(constraint)

        return constraint
    }
    
    @discardableResult func constrainWidth(_ width: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint (
            item: self,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute, multiplier: 1, constant: width
        )
        
        constraint.isActive = true
        
        return constraint
    }
    
  @discardableResult func constrainHeight(_ height: CGFloat) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint (
      item: self,
      attribute: .height,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: height
    )
    
    constraint.isActive = true
    
    return constraint
  }
    
  func addDivider() {
    let divider = UIView()
    divider.backgroundColor = .hex("#D8D8D8")
    divider.layer.opacity = 0.85

    addSubview(divider)
    
    addConstraintsWithFormat(format: "H:|[v0]|", views: divider)
    addConstraintsWithFormat(format: "V:[v0(0.45)]|", views: divider)
  }
    
  func allSubviews() -> [UIView] {
    return subviews + subviews.flatMap { $0.allSubviews() }
  }
  
  func animatePress(_ press: Bool) {
    UIView.animate(
      withDuration: 0.15,
      delay: 0,
      options: .curveEaseOut,
      animations: {
        self.transform = press ? .init(scaleX: 0.95, y: 0.95) : .identity
      },
      completion: nil
    )
  }
}
