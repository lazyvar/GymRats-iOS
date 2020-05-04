//
//  LogWorkoutModalViewController.swift
//  GymRats
//
//  Created by mack on 1/5/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import PanModal
import HealthKit
import RxSwift

class LogWorkoutModalViewController: UITableViewController {
  private let disposeBag = DisposeBag()
  private let onPickSource: (Either<UIImage, HKWorkout>) -> Void
  private var showText = true
    
  init(onPickSource: @escaping (Either<UIImage, HKWorkout>) -> Void) {
    self.onPickSource = onPickSource

    super.init(style: .plain)
  }
    
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.backgroundColor = .background
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
    tableView.register(UINib(nibName: "LogWorkoutCell", bundle: nil), forCellReuseIdentifier: "log")
  }
    
  override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "log") as! LogWorkoutCell
    cell.textStackView.isHidden = !showText
    cell.onTakePicture = { [weak self] in
      guard let self = self else { return }
    
      guard UIImagePickerController.isCameraDeviceAvailable(.front) || UIImagePickerController.isCameraDeviceAvailable(.rear) else {
        self.presentAlert(title: "Uh-oh", message: "Your device needs a camera to do that.")
        return
      }

      let imagePicker = UIImagePickerController()
      imagePicker.sourceType = .camera
      imagePicker.delegate = self
      UINavigationBar.appearance().isTranslucent = false
      UINavigationBar.appearance().barTintColor = .background
      UINavigationBar.appearance().tintColor = .primaryText
      
      self.present(imagePicker, animated: true, completion: nil)
  }
    
    cell.onChooseFromLibrary = { [weak self] in
      guard let self = self else { return }
        
      let imagePicker = UIImagePickerController()
      imagePicker.sourceType = .photoLibrary
      imagePicker.delegate = self
      UINavigationBar.appearance().isTranslucent = false
      UINavigationBar.appearance().barTintColor = .background
      UINavigationBar.appearance().tintColor = .primaryText

      self.present(imagePicker, animated: true, completion: nil)
    }
    
    cell.onHealth = { [weak self] in
      guard let self = self else { return }
      
      guard HKHealthStore.isHealthDataAvailable() else {
        self.present(HealthAppPermissionsViewController(), animated: true, completion: nil)
      
        return
      }
      
      HealthService.requestAuthorization(toShare: nil, read: Set([HKObjectType.workoutType()]))
        .subscribe(onSuccess: { granted in
          DispatchQueue.main.async {
            let importWorkoutViewController = ImportWorkoutViewController()
            importWorkoutViewController.delegate = self
            
            self.present(importWorkoutViewController)
          }
        }, onError: { error in
          print(error)
        })
        .disposed(by: self.disposeBag)
    }

    return cell
  }
}

extension LogWorkoutModalViewController: ImportWorkoutViewControllerDelegate {
  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, imported workout: HKWorkout) {
    importWorkoutViewController.dismissSelf()
    
    dismiss(animated: true) {
      self.onPickSource(.right(workout))
    }
  }
}

extension LogWorkoutModalViewController: UINavigationControllerDelegate { }

extension LogWorkoutModalViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true) {
      self.dismiss(animated: true) {
        if let img = info[.originalImage] as? UIImage {
          self.onPickSource(.left(img))
        }
      }
    }
  }
}

extension LogWorkoutModalViewController: PanModalPresentable {
  var panScrollable: UIScrollView? {
    return tableView
  }
  
  var showDragIndicator: Bool {
    return false
  }
}
