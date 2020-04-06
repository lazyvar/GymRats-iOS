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
  }
  
  public override func update() {
    super.update()
    
    textField?.placeholder = textFieldRow?.placeholder
    textField?.text = row.value
    textField?.isSecureTextEntry = textFieldRow?.secure ?? false
    
    if let icon = textFieldRow?.icon {
      textField?.leftView = UIImageView(image: icon)
    }
    
    if textFieldRow?.secure ?? false {
      // ...
    }
  }
}

final class TextFieldRow: Row<TextFieldCell>, RowType {
  var placeholder: String?
  var icon: UIImage?
  var secure: Bool = false
  
  required public init(tag: String?) {
    super.init(tag: tag)

    cellProvider = CellProvider<TextFieldCell>(nibName: "TextFieldCell", bundle: Bundle.main)
  }
}
