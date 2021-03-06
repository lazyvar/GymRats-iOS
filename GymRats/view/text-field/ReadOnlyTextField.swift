//
//  ReadOnlyTextField.swift
//  GymRats
//
//  Created by mack on 1/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class ReadOnlyTextField: UITextField {

    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) || action == #selector(selectAll(_:)) || action == #selector(paste(_:)) {
            return false
        }
        
        return true
    }
}

class NoTouchingTextField: UITextField {
  override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var textRect = super.rightViewRect(forBounds: bounds)
    textRect.origin.x -= 8
    
    return textRect
  }
  
  override func caretRect(for position: UITextPosition) -> CGRect {
    return .zero
  }
  
  override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
    return []
  }
  
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return false
  }
}
