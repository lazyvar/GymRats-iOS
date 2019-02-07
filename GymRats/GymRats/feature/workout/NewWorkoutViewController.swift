//
//  NewWorkoutViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/6/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import RxSwift
import RxCocoa
import GooglePlaces

protocol NewWorkoutDelegate: class {
    func workoutCreated(workout: Workout)
}

class NewWorkoutViewController: UIViewController {
    
    let image = BehaviorRelay<UIImage?>(value: nil)
    let place = BehaviorRelay<String?>(value: nil)

    weak var delegate: NewWorkoutDelegate?
    
    let disposeBag = DisposeBag()
    
    let workoutTitle: SkyFloatingLabelTextField = .standardTextField(placeholder: "Title")
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .bold
        label.text = "Description"
        
        return label
    }()
    
    let descriptionTextView = UITextView()
    
    let imagePickerButton: UIButton = .primary(text: "Attach Image")
    let placePickerButton: UIButton = .primary(text: "Attach Place")
    let submitButton: UIButton = .primary(text: "Do The Thing")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.backgroundColor = .whiteSmoke
        
        title = "Create Workout"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem (
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(UIViewController.dismissSelf)
        )
        
        let containerView = UIView()
        containerView.frame = view.frame
        containerView.backgroundColor = .white

        containerView.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.alignContent = .center
            layout.padding = 15
        }
        
        workoutTitle.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 60
        }

        descriptionLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 10
        }

        descriptionTextView.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 10
            layout.height = 80
        }

        imagePickerButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }

        placePickerButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }

        submitButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }

        containerView.addSubview(workoutTitle)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(descriptionTextView)
        containerView.addSubview(imagePickerButton)
        containerView.addSubview(placePickerButton)
        containerView.addSubview(submitButton)

        containerView.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: .flexibleHeight)
        containerView.makeScrolly(in: view)
        
        imagePickerButton.onTouchUpInside { [weak self] in
            self?.pickImage()
        }.disposed(by: disposeBag)
        
        placePickerButton.onTouchUpInside { [weak self] in
            self?.pickPlace()
        }.disposed(by: disposeBag)
    }
    
    func pickImage() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cam = UIAlertAction(title: "Take picture from camera", style: .default) { (alert) in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.cameraCaptureMode = .photo
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let library = UIAlertAction(title: "Choose from library", style: .default) { (alert) in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cam)
        alertController.addAction(library)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func pickPlace() {
        
    }
    
    func createWorkout() {
        
    }
    
}

extension NewWorkoutViewController: UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.image.accept(info[.originalImage] as? UIImage)
    }
    
}

extension NewWorkoutViewController: UINavigationControllerDelegate {
    
}
