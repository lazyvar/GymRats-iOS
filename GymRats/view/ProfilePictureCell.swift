//
//  ProfilePictureCell.swift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import Eureka

class ProfilePictureCell: Cell<UIImage>, CellType {
  @IBOutlet weak var profilePictureImageVIew: UIImageView!
  @IBOutlet weak var cameraImageView: UIImageView!
  
  override func setup() {
    selectionStyle = .none
    accessoryType = .none
    editingAccessoryView = .none
    backgroundColor = .clear
    profilePictureImageVIew.tintColor = .hex("#000000", alpha: 0.85)
    profilePictureImageVIew.backgroundColor = UIColor(red: 235/250, green: 235/250, blue: 235/250, alpha: 1)
    profilePictureImageVIew.contentMode = .center
    profilePictureImageVIew.clipsToBounds = true
    profilePictureImageVIew.layer.cornerRadius = 56
    cameraImageView.backgroundColor = .brand
    cameraImageView.layer.cornerRadius = 17.5
    cameraImageView.clipsToBounds = true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    animatePress(true)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    animatePress(false)
    (row as? ProfilePictureRow)?.selectionSon()
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    
    animatePress(false)
  }
  
  public override func update() {
    super.update()

    profilePictureImageVIew.image = row.value ?? .proPic
    profilePictureImageVIew.contentMode = (row.value as UIImage?) != nil ? .scaleAspectFill : .center
  }
}

final class ProfilePictureRow: Row<ProfilePictureCell>, RowType, PresenterRowType {
  typealias PresentedControllerType = ImagePickerController

  var presentationMode: PresentationMode<ImagePickerController>?
  var onPresentCallback: ((FormViewController, ImagePickerController) -> Void)?
  var clearAction = ImageClearAction.yes(style: .destructive)

  func selectionSon() {
    var availableSources: ImageRowSourceTypes = []

    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      availableSources.insert(.PhotoLibrary)
    }

    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      availableSources.insert(.Camera)
    }

    let sourceActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    createOptionsForAlertController(sourceActionSheet, sources: availableSources)

    if case .yes(let style) = clearAction, value != nil {
      let clearPhotoOption = UIAlertAction(title: "Clear photo", style: style) { [weak self] _ in
        self?.value = nil
        self?.updateCell()
      }

      sourceActionSheet.addAction(clearPhotoOption)
    }

    let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

    sourceActionSheet.addAction(cancelOption)

    DispatchQueue.main.async {
      UIViewController.topmost().present(sourceActionSheet, animated: true)
    }
  }
  
  func createOptionsForAlertController(_ alertController: UIAlertController, sources: ImageRowSourceTypes) {
    if sources.contains(.Camera) { createOptionForAlertController(alertController, sourceType: .Camera) }
    if sources.contains(.PhotoLibrary) { createOptionForAlertController(alertController, sourceType: .PhotoLibrary) }
  }
  
  func createOptionForAlertController(_ alertController: UIAlertController, sourceType: ImageRowSourceTypes) {
    guard let pickerSourceType = UIImagePickerController.SourceType(rawValue: sourceType.imagePickerControllerSourceTypeRawValue) else { return }

    let option = UIAlertAction(title: sourceType.desc, style: .default) { [weak self] _ in
      self?.displayImagePickerController(pickerSourceType)
    }

    alertController.addAction(option)
  }
  
  func displayImagePickerController(_ sourceType: UIImagePickerController.SourceType) {
    if let presentationMode = presentationMode, !isDisabled {
      if let controller = presentationMode.makeController(){
        controller.row = self
        controller.sourceType = sourceType
        onPresentCallback?(cell.formViewController()!, controller)
        presentationMode.present(controller, row: self, presentingController: cell.formViewController()!)
      } else {
        presentationMode.present(nil, row: self, presentingController: cell.formViewController()!)
      }
    }
  }

  public required init(tag: String?) {
    super.init(tag: tag)

    presentationMode = .presentModally(controllerProvider: ControllerProvider.callback {
      return ImagePickerController()
    }, onDismiss: { viewController in
      viewController.dismissSelf()
    })
    
    cellProvider = CellProvider<ProfilePictureCell>(nibName: "ProfilePictureCell", bundle: Bundle.main)
  }
}
