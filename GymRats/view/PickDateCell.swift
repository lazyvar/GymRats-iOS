//
//  PickDateCell.swift
//  GymRats
//
//  Created by mack on 4/14/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import Eureka

class PickDateCell: Cell<Date>, Eureka.TextFieldCell, CellType {
  @IBOutlet weak var shadowTextField: ShadowTextField!

  var textField: UITextField! { return shadowTextField }
  var textFieldRow: PickDateRow? { return row as? PickDateRow }
  
  let datePicker = UIDatePicker()
  
  override func setup() {
    selectionStyle = .none
    backgroundColor = .clear
    shadowTextField.textContentType = textFieldRow?.contentType
    shadowTextField.keyboardType = textFieldRow?.keyboardType ?? .default
    shadowTextField.inputView = datePicker
    shadowTextField.delegate = self
    datePicker.datePickerMode = .date
    datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    datePicker.date = row.value ?? Date()
    datePicker.timeZone = .current
  }
  
  public override func update() {
    super.update()
    
    datePicker.date = row.value ?? Date()
    datePicker.minimumDate = textFieldRow?.startDate
    datePicker.maximumDate = textFieldRow?.endDate

    textField?.text = datePicker.date.in(region: .current).toFormat("EEEE, MMMM d, yyyy")
    textField?.placeholder = textFieldRow?.placeholder
    textField?.textContentType = textFieldRow?.contentType
    textField?.keyboardType = textFieldRow?.keyboardType ?? .default
    textField?.clearButtonMode = .never
    
    if let icon = textFieldRow?.icon {
      textField?.leftViewMode = .always
      textField?.leftView = UIImageView(image: icon).apply {
        $0.tintColor = .secondaryText
      }
    }
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
  
  @objc func dateChanged() {
    self.row.value = datePicker.date
    update()
  }
}

extension PickDateCell: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return false
  }
}

final class PickDateRow: Row<PickDateCell>, RowType, FieldRowConformance, KeyboardReturnHandler {
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
  var startDate: Date?
  var endDate: Date?
  
  required public init(tag: String?) {
    super.init(tag: tag)

    validationOptions = .validatesOnChangeAfterBlurred
    cellProvider = CellProvider<PickDateCell>(nibName: "PickDateCell", bundle: Bundle.main)
  }
}
