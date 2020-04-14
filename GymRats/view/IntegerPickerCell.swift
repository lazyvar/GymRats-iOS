//
//  IntegerPickerCell.swift
//  GymRats
//
//  Created by mack on 4/14/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import Eureka

class IntegerPickerCell: Cell<Int>, Eureka.TextFieldCell, CellType {
  @IBOutlet weak var shadowTextField: ShadowTextField!

  var textField: UITextField! { return shadowTextField }
  var textFieldRow: IntegerPickerRow? { return row as? IntegerPickerRow }
  
  let picker = UIPickerView()
  
  var numberOfRows: Int { textFieldRow?.numberOfRows ?? 0 }
  
  override func setup() {
    selectionStyle = .none
    backgroundColor = .clear
    shadowTextField.textContentType = textFieldRow?.contentType
    shadowTextField.keyboardType = textFieldRow?.keyboardType ?? .default
    shadowTextField.inputView = picker
    shadowTextField.delegate = self
    picker.delegate = self
    picker.selectRow(row.value ?? 0, inComponent: 0, animated: false)
  }
  
  public override func update() {
    super.update()

    textField?.text = textFieldRow?.displayInt(row.value ?? 0) ?? ""
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
}

extension IntegerPickerCell: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return numberOfRows
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.row.value = row
    update()
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return textFieldRow?.displayInt(row) ?? ""
  }
}

extension IntegerPickerCell: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return false
  }
}

final class IntegerPickerRow: Row<IntegerPickerCell>, RowType, FieldRowConformance, KeyboardReturnHandler {
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
  var numberOfRows: Int = 0
  var displayInt: (Int) -> String = { "\($0)" }

  required public init(tag: String?) {
    super.init(tag: tag)

    validationOptions = .validatesOnChangeAfterBlurred
    cellProvider = CellProvider<IntegerPickerCell>(nibName: "IntegerPickerCell", bundle: Bundle.main)
  }
}
