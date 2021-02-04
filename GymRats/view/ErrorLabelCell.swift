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
    backgroundColor = (row as? ErrorLabelRow)?.bgColor ?? .clear
    
    errorLabel.textColor = .brand
    errorLabel.font = .details
  }
}


final class ErrorLabelRow: Row<ErrorLabelCell>, RowType {
  var placeholder: String?
  var bgColor: UIColor?
  
  required public init(tag: String?) {
    super.init(tag: tag)

    cellProvider = CellProvider<ErrorLabelCell>(nibName: "ErrorLabelCell", bundle: Bundle.main)
  }
}
