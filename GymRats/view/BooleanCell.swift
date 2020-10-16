//
//  BooleanCell.swift
//  GymRats
//
//  Created by mack on 10/16/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import Eureka

class BooleanCell:  Cell<Bool>, CellType {
  @IBOutlet private weak var `switch`: UISwitch! {
    didSet {
      `switch`.tintColor = .brand
    }
  }

  @IBOutlet private weak var titleThing: UILabel! {
    didSet {
      titleThing.textColor = .primaryText
      titleThing.font = .body
    }
  }
  
  var booleanRow: BooleanRow? { return row as? BooleanRow }

  override func setup() {
    selectionStyle = .none
    backgroundColor = .clear
    `switch`.isOn = booleanRow?.value ?? false
    `switch`.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    titleThing.text = booleanRow?.titleThing
  }
  
  public override func update() {
    super.update()
    
    `switch`.isOn = booleanRow?.value ?? false
    titleThing.text = booleanRow?.titleThing
  }
  
  @objc private func switchChanged() {
    booleanRow?.value = `switch`.isOn
  }
}

final class BooleanRow: Row<BooleanCell>, RowType {
  var titleThing: String?
  
  required public init(tag: String?) {
    super.init(tag: tag)

    cellProvider = CellProvider<BooleanCell>(nibName: "BooleanCell", bundle: Bundle.main)
  }
}
