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
  
  override func setup() {
    selectionStyle = .none
    backgroundColor = .clear
  }
}

final class TextFieldRow: Row<TextFieldCell>, RowType {
  required public init(tag: String?) {
    super.init(tag: tag)

    cellProvider = CellProvider<TextFieldCell>(nibName: "TextFieldCell", bundle: Bundle.main)
  }
}
