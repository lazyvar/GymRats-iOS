//
//  CreateWorkoutHeaderCell.swift
//  GymRats
//
//  Created by mack on 1/5/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import Eureka
import RSKPlaceholderTextView
import RxSwift

struct WorkoutHeaderInfo: Equatable {
  let image: UIImage?
  let title: String
  let description: String
}

class CreateWorkoutHeaderCell: Cell<WorkoutHeaderInfo>, CellType {
  @IBOutlet private weak var workoutImageView: UIImageView!
  @IBOutlet private weak var editButton: UIButton!
  @IBOutlet private weak var titleTextField: UITextField!
  @IBOutlet private weak var descTextView: RSKPlaceholderTextView!
  @IBOutlet private weak var lineView: UIView!
  
  private let disposeBag = DisposeBag()
    
  override func setup() {
    selectionStyle = .none
    workoutImageView.layer.cornerRadius = 4
    workoutImageView.contentMode = .scaleAspectFill
    titleTextField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)
    descTextView.delegate = self
    editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    descTextView.placeholder = "Description (optional)"
    titleTextField.font = .body
    descTextView.font = .body
    descTextView.tintColor = .none
    
    if #available(iOS 13.0, *) {
      if UIViewController().traitCollection.userInterfaceStyle == .dark {
        descTextView.placeholderColor = .init(red: 0.92, green: 0.92, blue: 0.96, alpha: 0.3)
        lineView.backgroundColor = .init(red: 0.92, green: 0.92, blue: 0.96, alpha: 0.3)
      } else {
        descTextView.placeholderColor = .init(red: 0, green: 0.1, blue: 0.098, alpha: 0.22)
      }
    } else {
      descTextView.placeholderColor = .init(red: 0, green: 0, blue: 0.098, alpha: 0.22)
      // seperator R:0.92 G:0.92 B:0.96 A:0.3
      // R:0.33 G:0.33 B:0.35 A:0.6
    }
    
    let tap = UITapGestureRecognizer()
    tap.numberOfTouchesRequired = 1
    tap.addTarget(self, action: #selector(editButtonTapped))
    
    let currentValue: WorkoutHeaderInfo = row.value!
    
    if currentValue.image != nil {
      editButton.setTitle("CHANGE", for: .normal)
      workoutImageView.backgroundColor = .clear
      workoutImageView.contentMode = .scaleAspectFill
      workoutImageView.layer.borderWidth = 0
      workoutImageView.layer.borderColor = UIColor.clear.cgColor
    } else {
      workoutImageView.image = .plusCircle
      workoutImageView.backgroundColor = .foreground
      workoutImageView.contentMode = .center
      workoutImageView.layer.borderWidth = 2
      workoutImageView.layer.borderColor = workoutImageView.tintColor.cgColor
      editButton.setTitle("ADD PHOTO", for: .normal)
    }

    workoutImageView.isUserInteractionEnabled = true
    isUserInteractionEnabled = true
    workoutImageView.addGestureRecognizer(tap)
    descTextView.backgroundColor = .clear
    descTextView.contentInset = .init(top: 5, left: 0, bottom: 0, right: 0)
    descTextView.textContainerInset = .init(top: 5, left: 0, bottom: 0, right: 0)
    descTextView.textContainer.lineFragmentPadding = 0
  }

  @objc func titleChanged() {
    let currentValue: WorkoutHeaderInfo = row.value!
    let title = titleTextField.text ?? ""
    
    row.value = WorkoutHeaderInfo(image: currentValue.image, title: title, description: currentValue.description)
  }
    
  @objc func editButtonTapped() {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let library = UIAlertAction(title: "Photo library", style: .default) { (alert) in
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
      self.formViewController()?.present(imagePicker, animated: true, completion: nil)
    }
    
    let cam = UIAlertAction(title: "Camera", style: .default) { (alert) in
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.cameraCaptureMode = .photo
        
        self.formViewController()?.present(imagePicker, animated: true, completion: nil)
    }
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alertController.addAction(cam)
    alertController.addAction(library)
    alertController.addAction(cancel)
    
    self.formViewController()?.present(alertController, animated: true, completion: nil)
  }
    
  public override func update() {
    super.update()

    let currentValue: WorkoutHeaderInfo = row.value!

    workoutImageView.image = currentValue.image
    titleTextField.text = currentValue.title
    descTextView.text = currentValue.description
    
    if currentValue.image != nil {
      editButton.setTitle("CHANGE", for: .normal)
      workoutImageView.backgroundColor = .clear
      workoutImageView.contentMode = .scaleAspectFill
      workoutImageView.layer.borderWidth = 0
      workoutImageView.layer.borderColor = UIColor.clear.cgColor
    } else {
      workoutImageView.image = .plusCircle
      workoutImageView.backgroundColor = .foreground
      workoutImageView.contentMode = .center
      workoutImageView.layer.borderWidth = 2
      workoutImageView.layer.borderColor = workoutImageView.tintColor.cgColor
      editButton.setTitle("ADD PHOTO", for: .normal)
    }
  }
}

extension CreateWorkoutHeaderCell: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    let currentValue: WorkoutHeaderInfo = row.value!
    let description = descTextView.text ?? ""
    
    row.value = WorkoutHeaderInfo(image: currentValue.image, title: currentValue.title, description: description)
  }
}

final class CreateWorkoutHeaderRow: Row<CreateWorkoutHeaderCell>, RowType {
  required public init(tag: String?) {
    super.init(tag: tag)

    cellProvider = CellProvider<CreateWorkoutHeaderCell>(nibName: "CreateWorkoutHeaderCell", bundle: Bundle.main)
  }
}

extension UIColor {
    static var officialApplePlaceholderGray: UIColor {
        return UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
    }
}

extension CreateWorkoutHeaderCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismissSelf()
    
    guard let image = info[.originalImage] as? UIImage else { return }
    
    let currentValue: WorkoutHeaderInfo = row.value!

    row.value = WorkoutHeaderInfo(image: image, title: currentValue.title, description: currentValue.description)
    update()
  }
}
