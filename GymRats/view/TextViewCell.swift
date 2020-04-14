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

class TextViewCell: Cell<String>, CellType {
  @IBOutlet weak var textView: JVFloatLabeledTextView! {
    didSet {
      textView.backgroundColor = .clear
      textView.floatingLabelTextColor = .secondaryText
      textView.floatingLabelActiveTextColor = .brand
      textView.floatingLabelFont = .details
      textView.font = .body
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
    
    textView.placeholder = (self.row as? TextViewRow)?.placeholder
    iconImageView.image = (self.row as? TextViewRow)?.icon
  }
}

extension TextViewCell: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    row.value = textView.text
  }
}

final class TextViewRow: Row<TextViewCell>, RowType {
  var placeholder: String?
  var icon: UIImage?
  
  required public init(tag: String?) {
    super.init(tag: tag)

    validationOptions = .validatesOnChangeAfterBlurred
    cellProvider = CellProvider<TextViewCell>(nibName: "TextViewCell", bundle: Bundle.main)
  }
}
