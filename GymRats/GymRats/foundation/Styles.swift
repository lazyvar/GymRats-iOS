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
        button.titleLabel?.font = .h4
        
        return button
    }
}

extension UIButton {
    
    static func primary(text: String) -> UIButton {
        var button = UIButton()
        button.setTitle(text, for: .normal)
        button = baseButtonStyle()(button)
        button.setTitleColor(.whiteSmoke, for: .normal)
        button.setTitleColor(.charcoal, for: .highlighted)
        button.setBackgroundImage(.primary, for: .normal)
        button.setBackgroundImage(.primary, for: .highlighted)
        button.setTitleColor(.whiteSmoke, for: .disabled)
        button.setBackgroundImage(.charcoal, for: .disabled)
        
        return button
    }
    
    static func secondary(text: String) -> UIButton {
        var button = UIButton()
        button = baseButtonStyle()(button)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.fog, for: .normal)
        button.setTitleColor(.whiteSmoke, for: .highlighted)
        button.setBackgroundImage(UIImage(color: .white), for: .normal)
        button.setBackgroundImage(.fog, for: .highlighted)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.fog.withAlphaComponent(0.5).cgColor
        
        return button
    }

    static func danger(text: String) -> UIButton {
        var button = UIButton()
        button.setTitle(text, for: .normal)
        button.setTitleColor(.charcoal, for: .normal)
        button.setTitleColor(.whiteSmoke, for: .highlighted)
        button.setBackgroundImage(.firebrick, for: .normal)
        button = baseButtonStyle()(button)
        
        return button
    }

}

extension UIFont {
    static let body = UIFont(name: "Lato-Regular", size: 14)!
    static let details = UIFont(name: "Lato-Regular", size: 12)!
    static let detailsBold = UIFont(name: "Lato-Bold", size: 12)!
    static let bigAndBlack = UIFont(name: "Lato-Bold", size: 16)!
    static let h1 = UIFont(name: "Lato-Regular", size: 28)!
    static let h2 = UIFont(name: "Lato-Regular", size: 24)!
    static let h3 = UIFont(name: "Lato-Regular", size: 20)!
    static let h4 = UIFont(name: "Lato-Regular", size: 18)!
    static let bold = UIFont(name: "Lato-Bold", size: 14)!
}
