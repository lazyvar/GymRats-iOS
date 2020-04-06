//
//  ErrorLabelCell.swift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import Eureka

class ErrorLabelCell: Cell<String>, CellType {
  @IBOutlet weak var errorLabel: UILabel!

  override func setup() {
    selectionStyle = .none
    backgroundColor = .clear
    
    errorLabel.textColor = .systemOrange
    errorLabel.font = .details
  }
}


final class ErrorLabelRow: Row<ErrorLabelCell>, RowType {
  var placeholder: String?
  
  required public init(tag: String?) {
    super.init(tag: tag)

    cellProvider = CellProvider<ErrorLabelCell>(nibName: "ErrorLabelCell", bundle: Bundle.main)
  }
}
