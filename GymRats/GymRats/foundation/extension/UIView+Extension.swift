//
//  UIView+Extension.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @discardableResult func constrainWidth(_ width: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint (
            item: self,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute, multiplier: 1, constant: width)
    }
    
    @discardableResult func constrainHeight(_ height: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
    }
    
}
