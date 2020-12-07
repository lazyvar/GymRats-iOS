//
//  WorkoutTitleTextFieldCell.swift
//  GymRats
//
//  Created by mack on 12/7/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import Eureka

class WorkoutTitleTextFieldCell: Cell<String>, Eureka.TextFieldCell, CellType {
  @IBOutlet private weak var titleTextField: UITextField!
  
  var textField: UITextField! { return titleTextField }
  
  override func setup() {
    selectionStyle = .none
    textField.font = .body
    textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
  }
  
  override func update() {
    textField.text = row.value
  }
  
  @objc func editingChanged() {
    row.value = textField.text
  }
}

final class WorkoutTitleTextFieldRow: Row<WorkoutTitleTextFieldCell>, RowType, FieldRowConformance, KeyboardReturnHandler {
  var titlePercentage: CGFloat?
  var placeholderColor: UIColor?
  var keyboardReturnType: KeyboardReturnTypeConfiguration?
  var formatter: Formatter?
  var useFormatterDuringInput: Bool = false
  var useFormatterOnDidBeginEditing: Bool?
  
  var placeholder: String?
  var icon: UIImage?
  var secure: Bool = false
  var contentType: UITextContentType?
  var keyboardType: UIKeyboardType?
  
  required public init(tag: String?) {
    super.init(tag: tag)

    validationOptions = .validatesOnChangeAfterBlurred
    cellProvider = CellProvider<WorkoutTitleTextFieldCell>(nibName: "WorkoutTitleTextFieldCell", bundle: Bundle.main)
  }
}

