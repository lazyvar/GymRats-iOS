//
//  TextFieldCell.swift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import Eureka

class TextFieldCell: Cell<String>, Eureka.TextFieldCell, CellType {
  @IBOutlet weak var shadowTextField: ShadowTextField!

  var textField: UITextField! { return shadowTextField }
  var textFieldRow: TextFieldRow? { return row as? TextFieldRow }
  
  override func setup() {
    selectionStyle = .none
    backgroundColor = .clear
    shadowTextField.delegate = self
    shadowTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
  }
  
  public override func update() {
    super.update()
    
    textField?.placeholder = textFieldRow?.placeholder
    textField?.text = row.value
    textField?.isSecureTextEntry = (textFieldRow?.secure ?? false) && secureState
    
    if let icon = textFieldRow?.icon {
      textField?.leftViewMode = .always
      textField?.leftView = UIImageView(image: icon).apply {
        $0.tintColor = .secondaryText
      }
    }
    
    if textFieldRow?.secure ?? false {
      let image: UIImage
      
      if secureState {
        image = .eyeOn
      } else {
        image = .eyeOff
      }
      
      let tap = UITapGestureRecognizer(target: self, action: #selector(tappedEye))
      
      textField?.rightViewMode = .whileEditing
      textField?.rightView = UIImageView(image: image).apply {
        $0.tintColor = .primaryText
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
      }
    }
  }
  
  private var secureState = true
  
  @objc private func tappedEye() {
    secureState.toggle()
    update()
  }
  
  open override func cellCanBecomeFirstResponder() -> Bool {
    return !row.isDisabled && textField?.canBecomeFirstResponder == true
  }

  open override func cellBecomeFirstResponder(withDirection: Direction) -> Bool {
    return textField?.becomeFirstResponder() ?? false
  }

  open override func cellResignFirstResponder() -> Bool {
    return textField?.resignFirstResponder() ?? true
  }
  
  @objc private func textChanged() {
    row.value = shadowTextField?.text
  }
}

extension TextFieldCell: UITextFieldDelegate {
  open func textFieldDidBeginEditing(_ textField: UITextField) {
    formViewController()?.beginEditing(of: self)
    formViewController()?.textInputDidBeginEditing(textField, cell: self)
  }

  open func textFieldDidEndEditing(_ textField: UITextField) {
    formViewController()?.endEditing(of: self)
    formViewController()?.textInputDidEndEditing(textField, cell: self)
    textChanged()
  }

  open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
  }

  open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return formViewController()?.textInput(textField, shouldChangeCharactersInRange:range, replacementString:string, cell: self) ?? true
  }

  open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
  }

  open func textFieldShouldClear(_ textField: UITextField) -> Bool {
    return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
  }

  open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
  }
}

final class TextFieldRow: Row<TextFieldCell>, RowType {
  var placeholder: String?
  var icon: UIImage?
  var secure: Bool = false
  
  required public init(tag: String?) {
    super.init(tag: tag)

    validationOptions = .validatesOnChangeAfterBlurred
    cellProvider = CellProvider<TextFieldCell>(nibName: "TextFieldCell", bundle: Bundle.main)
  }
}
