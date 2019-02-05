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
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        return button
    }
}

extension UIButton {
    
    static func primary(text: String) -> UIButton {
        var button = UIButton()
        button.setTitle(text, for: .normal)
        button = baseButtonStyle()(button)
        button.setTitleColor(.whiteSmoke, for: .normal)
        button.setTitleColor(.fog, for: .highlighted)
        button.setBackgroundImage(.brand, for: .normal)
        button.setBackgroundImage(.brand, for: .highlighted)
        button.setTitleColor(.whiteSmoke, for: .disabled)
        button.setBackgroundImage(.fog, for: .disabled)
        
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

    static func danger(text: String) -> UIButton {
        var button = UIButton()
        button.setTitle(text, for: .normal)
        button.setTitleColor(.fog, for: .normal)
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
        
        return textField
    }
    
}
