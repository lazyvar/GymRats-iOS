//
//  Styles.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

func roundedStyle(cornerRadius: CGFloat = 4) -> ((UIView) -> UIView) {
    return { view in
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = cornerRadius
        
        return view
    }
}

func baseButtonStyle() -> (UIButton) -> (UIButton) {
    return { button in
        _ = roundedStyle()(button)
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        return button
    }
}

extension UIButton {
    
    static func primary(text: String) -> UIButton {
        var button = UIButton()
        button.setTitle(text, for: .normal)
        button = baseButtonStyle()(button)
        button.backgroundColor = .brand
        
        return button
    }
    
    static func secondary(text: String) -> UIButton {
        var button = UIButton()
        button.setTitle(text, for: .normal)
        button.setTitleColor(.fog, for: .normal)
        button.setTitleColor(.whiteSmoke, for: .highlighted)
        button.setBackgroundImage(.whiteSmoke, for: .normal)
        button.setBackgroundImage(.fog, for: .highlighted)
        button = baseButtonStyle()(button)

        return button
    }

}

