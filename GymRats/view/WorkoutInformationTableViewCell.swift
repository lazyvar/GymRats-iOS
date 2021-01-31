//
//  WorkoutInformationTableViewCell.swift
//  GymRats
//
//  Created by Mack on 1/30/21.
//  Copyright © 2021 Mack Hasz. All rights reserved.
//

import UIKit
import Eureka
import RSKPlaceholderTextView
import YPImagePicker

struct WorkoutInformation: Equatable {
  var title: String?
  var description: String?
  var media: [YPMediaItem]
}

class WorkoutInformationTableViewCell: Cell<WorkoutInformation>, CellType {
  @IBOutlet private weak var textView: RSKPlaceholderTextView!
  @IBOutlet private weak var workoutImageView: UIImageView!
  @IBOutlet private weak var workoutTitleTextField: UITextField!
  
  override func setup() {
    selectionStyle = .none

    workoutImageView.layer.cornerRadius = 8
    workoutImageView.contentMode = .scaleAspectFill
    workoutImageView.clipsToBounds = true

    textView.delegate = self
    textView.placeholder = "Description (optional)"
    textView.font = .body
    textView.tintColor = .none
    textView.backgroundColor = .clear
    textView.textContainer.lineFragmentPadding = 0

    workoutTitleTextField.font = .body
    workoutTitleTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)

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
//    textView.text = row.value
//    textField.text = row.value
  }
  
  @objc func editingChanged() {
//    row.value = workoutTitleTextField.text
  }
}

extension WorkoutInformationTableViewCell: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    
  }
}

final class WorkoutInformationRow: Row<WorkoutInformationTableViewCell>, RowType {
  required public init(tag: String?) {
    super.init(tag: tag)

    validationOptions = .validatesOnChangeAfterBlurred
    cellProvider = CellProvider<WorkoutInformationTableViewCell>(nibName: "WorkoutInformationTableViewCell", bundle: .main)
  }
}

extension YPMediaItem: Equatable {
  public static func == (lhs: YPMediaItem, rhs: YPMediaItem) -> Bool {
    switch (lhs, rhs) {
    case (.photo(let p1), .photo(let p2)):
      return p1.image == p2.image
    case (.video(let v1), .video(let v2)):
      return v1.url == v2.url
    default:
      return false
    }
  }
}
