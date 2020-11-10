//
//  CreateTeamViewController.swift
//  GymRats
//
//  Created by mack on 10/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import Eureka
import UnsplashPhotoPicker

class CreateTeamViewController: GRFormViewController {
  private let disposeBag = DisposeBag()
  private var challenge: Challenge
  private let createButton = PrimaryButton()

  init(_ challenge: Challenge) {
    self.challenge = challenge
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Create team"
    view.backgroundColor = .background
    setupBackButton()
    
    tableView.backgroundColor = .background
    tableView.separatorStyle = .none

    form = form
      +++ section
        <<< nameRow
        <<< photoRow
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  
    Track.screen(.createTeam)
  }
  
  @objc private func create() {
    guard self.form.validate().isEmpty else { return }

    showLoadingBar()
    
    gymRatsAPI.createTeam(challenge: challenge, name: nameRow.value!, photo: photoRow.value)
      .subscribe(onNext: { [weak self] result in
        guard let self = self else { return }
        
        self.hideLoadingBar()
        
        switch result {
        case .success(let team):
          NotificationCenter.default.post(name: .joinedTeam, object: team)

          if UserDefaults.standard.bool(forKey: "account-is-onboarding") {
            GymRats.completeOnboarding()
          } else {
            self.dismissSelf()
          }
        case .failure(let error):
          Alert.presentAlert(error: error)
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func presentPhotoAlert() {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let cam = UIAlertAction(title: "Camera", style: .default) { (alert) in
      guard UIImagePickerController.isCameraDeviceAvailable(.front) || UIImagePickerController.isCameraDeviceAvailable(.rear) else {
        self.presentAlert(title: "Uh-oh", message: "Your device needs a camera to do that.")
        return
      }

      let imagePicker = UIImagePickerController()
      imagePicker.sourceType = .camera
      imagePicker.delegate = self
      imagePicker.cameraCaptureMode = .photo
      
      self.present(imagePicker, animated: true, completion: nil)
    }
    
    let unsplash = UIAlertAction(title: "Choose preset", style: .default) { (alert) in
      let configuration = UnsplashPhotoPickerConfiguration(
        accessKey: Secrets.Unsplash.accessKey,
        secretKey: Secrets.Unsplash.secretKey,
        allowsMultipleSelection: false
      )
      
      let unsplashPhotoPicker = UnsplashPhotoPicker(configuration: configuration)
      unsplashPhotoPicker.photoPickerDelegate = self

      self.present(unsplashPhotoPicker, animated: true, completion: nil)
    }

    let library = UIAlertAction(title: "Photo library", style: .default) { (alert) in
      let imagePicker = UIImagePickerController()
      imagePicker.sourceType = .photoLibrary
      imagePicker.delegate = self
      
      self.present(imagePicker, animated: true, completion: nil)
    }
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alertController.addAction(cam)
    alertController.addAction(unsplash)
    alertController.addAction(library)
    alertController.addAction(cancel)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  private lazy var section: Section = {
    return Section() { section in
      section.header = self.sectionHeader
      section.footer = self.sectionFooter
    }
  }()
  
  private lazy var nameRow: TextFieldRow = {
    return TextFieldRow() { textRow in
      textRow.placeholder = "Team name"
      textRow.tag = "name"
      textRow.icon = .name
      textRow.add(rule: RuleRequired(msg: "Name is required."))
    }
    .onRowValidationChanged(self.handleRowValidationChange)
  }()

  private lazy var photoRow: ButtonChoiceRow = {
    return ButtonChoiceRow() { row in
      row.title = "Team photo"
      row.tag = "team_photo"
      row.onSelect = {
        self.presentPhotoAlert()
      }
    }
  }()

  private lazy var sectionHeader: HeaderFooterView<UIView> = {
    let headerBuilder = { () -> UIView in
      let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))

      let label = UILabel()
      label.font = .body
      label.text = """
      Give the team a name and an optional team photo.
      """
      label.frame = CGRect(x: 20, y: 0, width: self.view.frame.width - 40, height: 20)
      label.sizeToFit()
      
      container.addSubview(label)
      
      return container
    }
      
    var header = HeaderFooterView<UIView>(.callback(headerBuilder))
    header.height = { 40 }
    
    return header
  }()
  
  private lazy var sectionFooter: HeaderFooterView<UIView> = {
    let footerBuilder = { () -> UIView in
      let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 96))
      
      container.addSubview(self.createButton)

      self.createButton.addTarget(self, action: #selector(self.create), for: .touchUpInside)
      self.createButton.constrainWidth(self.tableView.frame.width - 40)
      self.createButton.translatesAutoresizingMaskIntoConstraints = false
      self.createButton.setTitle("Create", for: .normal)
      self.createButton.horizontallyCenter(in: container)
      self.createButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 10).isActive = true

      return container
    }
    
    var footer = HeaderFooterView<UIView>(.callback(footerBuilder))
    footer.height = { 50 }
    
    return footer
  }()

  private func handleRowValidationChange(cell: UITableViewCell, row: TextFieldRow) {
    guard let textRowNumber = row.indexPath?.row, var section = row.section else { return }
    
    let validationLabelRowNumber = textRowNumber + 1
    
    while validationLabelRowNumber < section.count && section[validationLabelRowNumber] is ErrorLabelRow {
      section.remove(at: validationLabelRowNumber)
    }
    
    if row.isValid { return }
    
    for (index, validationMessage) in row.validationErrors.map({ $0.msg }).enumerated() {
      let labelRow = ErrorLabelRow()
        .cellSetup { cell, _ in
          cell.errorLabel.text = validationMessage
        }
      
      section.insert(labelRow, at: validationLabelRowNumber + index)
    }
  }
}

extension CreateTeamViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismissSelf()
    
    guard let image = info[.originalImage] as? UIImage else { return }
    
    self.photoRow.value = .left(image)
    self.photoRow.updateCell()
    self.tableView.reloadData()
  }
}

extension CreateTeamViewController: UnsplashPhotoPickerDelegate {
  func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
    guard let photo = photos.first else { return }

    self.photoRow.value = .right(photo.urls[.regular]?.absoluteString ?? "")
    self.photoRow.updateCell()
    self.tableView.reloadData()
  }
  
  func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) {
    // ...
  }
}
