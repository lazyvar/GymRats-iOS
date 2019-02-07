//
//  Styles.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

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
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
        button.setBackgroundImage(.brand, for: .normal)
        button.setBackgroundImage(.brand, for: .highlighted)
        button.setTitleColor(.whiteSmoke, for: .disabled)
        button.setBackgroundImage(.charcoal, for: .disabled)
        
        return button
    }
    
    static func secondary(text: String) -> UIButton {
        var button = UIButton()
        button.setTitle(text, for: .normal)
        button.setTitleColor(.charcoal, for: .normal)
        button.setTitleColor(.whiteSmoke, for: .highlighted)
        button.setBackgroundImage(.whiteSmoke, for: .normal)
        button.setBackgroundImage(.charcoal, for: .highlighted)
        button = baseButtonStyle()(button)
        
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

extension SkyFloatingLabelTextField {
    
    static func standardTextField(placeholder: String) -> SkyFloatingLabelTextField {
        let textField = SkyFloatingLabelTextField()
        textField.errorColor = .firebrick
        textField.placeholder = placeholder
        textField.titleColor = .brand
        textField.selectedLineColor = .brand
        textField.lineErrorColor = .brand
        textField.selectedTitleColor = .brand
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.font = .body
        textField.titleFont = .bold
        
        return textField
    }
    
}

extension UIFont {
    static let body = UIFont(name: "Lato-Regular", size: 16)!
    static let details = UIFont(name: "Lato-Regular", size: 13)!
    static let h1 = UIFont(name: "Lato-Reguler", size: 28)!
    static let h2 = UIFont(name: "Lato-Regular", size: 24)!
    static let h3 = UIFont(name: "Lato-Regular", size: 20)!
    static let h4 = UIFont(name: "Lato-Regular", size: 18)!
    static let bold = UIFont(name: "Lato-Bold", size: 16)!
}
