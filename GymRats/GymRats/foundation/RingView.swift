//
//  RingView.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class RingView: UIView {
    
    var ringColor: UIColor
    let ringWidth: CGFloat
    
    init(frame: CGRect, ringWidth: CGFloat = 4, ringColor: UIColor = .white) {
        self.ringWidth = ringWidth
        self.ringColor = ringColor
        
        super.init(frame: frame)
        
        backgroundColor = .clear
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.clear.setFill()
        ringColor.setStroke()
        
        let rectInset = rect.insetBy(dx: rect.width * 0.15 / 2, dy: rect.height * 0.15 / 2)
        
        let path = UIBezierPath(ovalIn: rectInset)
        path.lineWidth = ringWidth
        
        path.fill()
        path.stroke()
    }
    
}
