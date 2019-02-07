//
//  RightAlignedconButton.swift
//  GymRats
//
//  Created by Mack Hasz on 2/6/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

@IBDesignable
class RightAlignedIconButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        semanticContentAttribute = .forceRightToLeft
        contentHorizontalAlignment = .right
        
        let availableSpace = bounds.inset(by: contentEdgeInsets)
        let availableWidth = availableSpace.width - imageEdgeInsets.left - (imageView?.frame.width ?? 0) - (titleLabel?.frame.width ?? 0)
        
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: availableWidth / 2 - 10)
    }

}
