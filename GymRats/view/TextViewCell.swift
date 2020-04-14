//
//  TextViewCell.swift
//  GymRats
//
//  Created by mack on 4/13/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import Eureka

class TextViewCell: Cell<String>, CellType, AreaCell {
  var textView: UITextView! { return floatTextView }
  
  @IBOutlet weak var floatTextView: JVFloatLabeledTextView! {
    didSet {
      floatTextView.backgroundColor = .clear
      floatTextView.floatingLabelTextColor = .secondaryText
      floatTextView.floatingLabelActiveTextColor = .brand
      floatTextView.floatingLabelFont = .details
      floatTextView.font = .body
      floatTextView.delegate = self
    }
  }
  
  @IBOutlet weak var iconImageView: UIImageView! {
    didSet {
      iconImageView.tintColor = .secondaryText
    }
  }
  
  override func setup() {
    selectionStyle = .none
    textView.delegate = self
  }

  public override func update() {
    super.update()
    
    floatTextView.placeholder = (self.row as? TextViewRow)?.placeholder
    iconImageView.image = (self.row as? TextViewRow)?.icon
  }
  
  open override func cellCanBecomeFirstResponder() -> Bool {
    return !row.isDisabled && floatTextView?.canBecomeFirstResponder == true
  }

  open override func cellBecomeFirstResponder(withDirection: Direction) -> Bool {
    return floatTextView?.becomeFirstResponder() ?? false
  }

  open override func cellResignFirstResponder() -> Bool {
    return floatTextView?.resignFirstResponder() ?? true
  }
  
  @objc private func textChanged() {
    row.value = floatTextView?.text
  }
}

extension TextViewCell: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    formViewController()?.beginEditing(of: self)
    formViewController()?.textInputDidBeginEditing(textView, cell: self)
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    formViewController()?.endEditing(of: self)
    formViewController()?.textInputDidEndEditing(textView, cell: self)
    textChanged()
  }
  
  func textViewDidChange(_ textView: UITextView) {
    textChanged()
  }

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    return formViewController()?.textInput(textView, shouldChangeCharactersInRange: range, replacementString: text, cell: self) ?? true
  }

  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    return formViewController()?.textInputShouldBeginEditing(textView, cell: self) ?? true
  }

  func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    return formViewController()?.textInputShouldEndEditing(textView, cell: self) ?? true
  }
}

final class TextViewRow: Row<TextViewCell>, RowType, FieldRowConformance, KeyboardReturnHandler {
  var titlePercentage: CGFloat?
  var placeholderColor: UIColor?
  var keyboardReturnType: KeyboardReturnTypeConfiguration?
  var formatter: Formatter?
  var useFormatterDuringInput: Bool = false
  var useFormatterOnDidBeginEditing: Bool?
  
  var placeholder: String?
  var icon: UIImage?
  
  required public init(tag: String?) {
    super.init(tag: tag)

    validationOptions = .validatesOnChangeAfterBlurred
    cellProvider = CellProvider<TextViewCell>(nibName: "TextViewCell", bundle: Bundle.main)
  }
}
