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
    let imageOrWorkout: Either<UIImage, Workout>
    let title: String
    let description: String
}

class CreateWorkoutHeaderCell: Cell<WorkoutHeaderInfo>, CellType {

    @IBOutlet weak var workoutImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descTextView: RSKPlaceholderTextView!
    @IBOutlet weak var lineView: UIView!
    
    let disposeBag = DisposeBag()
    
    override func setup() {
        selectionStyle = .none
        workoutImageView.layer.cornerRadius = 4
        workoutImageView.contentMode = .scaleAspectFill
        titleTextField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)
        descTextView.delegate = self
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        descTextView.placeholder = "Description"
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
        
      row.value = WorkoutHeaderInfo(imageOrWorkout: currentValue.imageOrWorkout, title: title, description: currentValue.description)
    }
    
    @objc func editButtonTapped() {
        let picka = LogWorkoutModalViewController() { image in
            let currentValue: WorkoutHeaderInfo = self.row.value!
            
          self.row.value = WorkoutHeaderInfo(imageOrWorkout: .left(image), title: currentValue.title, description: currentValue.description)
            self.update()
        }
        picka.showText = false
        
        UIViewController.topmost().presentPanModal(picka)
    }
    
  
  public override func update() {
    super.update()

    let currentValue: WorkoutHeaderInfo = row.value!

    switch currentValue.imageOrWorkout {
    case .left(let image):
      workoutImageView.image = image
    case .right(let workout):
      if let photo = workout.photoUrl, let url = URL(string: photo) {
        workoutImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
      }
    }
    titleTextField.text = currentValue.title
    descTextView.text = currentValue.description
  }
}

extension CreateWorkoutHeaderCell: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    let currentValue: WorkoutHeaderInfo = row.value!
    let description = descTextView.text ?? ""
      
    row.value = WorkoutHeaderInfo(imageOrWorkout: currentValue.imageOrWorkout, title: currentValue.title, description: description)
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
