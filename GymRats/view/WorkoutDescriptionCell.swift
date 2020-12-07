//
//  WorkoutDescriptionCell.swift
//  GymRats
//
//  Created by mack on 12/7/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import Eureka
import RSKPlaceholderTextView

class WorkoutDescriptionCell: Cell<String>, CellType {
  @IBOutlet private weak var textView: RSKPlaceholderTextView!
  
  override func setup() {
    selectionStyle = .none
    textView.delegate = self
    textView.placeholder = "Description (optional)"
    textView.font = .body
    textView.tintColor = .none
    textView.backgroundColor = .clear
    textView.textContainer.lineFragmentPadding = 0

    if #available(iOS 13.0, *) {
      if traitCollection.userInterfaceStyle == .dark {
        textView.placeholderColor = .init(red: 0.92, green: 0.92, blue: 0.96, alpha: 0.3)
      } else {
        textView.placeholderColor = .init(red: 0, green: 0.1, blue: 0.098, alpha: 0.22)
      }
    } else {
      textView.placeholderColor = .init(red: 0, green: 0, blue: 0.098, alpha: 0.22)
    }
  }
  
  override func update() {
    textView.text = row.value
  }
}

extension WorkoutDescriptionCell: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    row.value = textView.text ?? ""
  }
}

final class WorkoutDescriptionRow: Row<WorkoutDescriptionCell>, RowType {
  required public init(tag: String?) {
    super.init(tag: tag)

    validationOptions = .validatesOnChangeAfterBlurred
    cellProvider = CellProvider<WorkoutDescriptionCell>(nibName: "WorkoutDescriptionCell", bundle: Bundle.main)
  }
}
