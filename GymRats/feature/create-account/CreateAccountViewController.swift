//
//  CreateAccountViewController.swift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import Eureka
import TTTAttributedLabel

class CreateAccountViewController: GRFormViewController {
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Create an account"

    LabelRow.defaultCellUpdate = { cell, row in
      cell.contentView.backgroundColor = .foreground
      cell.textLabel?.textColor = .niceBlue
      cell.textLabel?.font = .details
      cell.textLabel?.textAlignment = .left
    }
    
    tableView.backgroundColor = .background
    tableView.separatorStyle = .none
    
    let textFieldRow = TextFieldRow() { row in

    }
    
    form = form
      +++ userInfoSection
        <<< textFieldRow
        <<< textFieldRow
        <<< textFieldRow
        <<< textFieldRow
//        <<< profilePictureRow
//        <<< emailRow
//        <<< fullNameRow
//        <<< passwordRow
//        <<< confirmPasswordRow
  }
  
  @objc private func createAccountButtonTapped() {
    guard form.validate().count == 0 else { return }
    
    let valuesDictionary = form.values()

    let email    = valuesDictionary["email"] as! String
    let password = valuesDictionary["password"] as! String
    let proPic   = valuesDictionary["pro_pic"] as! UIImage?
    let fullName = valuesDictionary["full_name"] as! String

    self.showLoadingBar(disallowUserInteraction: true)
    
    gymRatsAPI.signUp(email: email, password: password, profilePicture: proPic, fullName: fullName)
      .subscribe(onNext: { [weak self] result in

        self?.hideLoadingBar()
        
        switch result {
        case .success(let user):
          Track.event(.signup)
          GymRats.login(user)
        case .failure(let error):
          self?.presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: Eurekah
  
  lazy var userInfoSection: Section = {
    return Section() { section in
      section.footer = self.sectionFooter
      section.header = self.sectionHeader
    }
  }()

  lazy var sectionHeader: HeaderFooterView<UIView> = {
    let headerBuilder = { () -> UIView in
      let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))

      let label = UILabel()
      label.font = .body
      label.text = "GymRats needs some information before getting started."
      label.frame = CGRect(x: 20, y: 0, width: self.view.frame.width - 40, height: 20)
      label.sizeToFit()
      
      container.addSubview(label)
      
      return container
    }
      
    var footer = HeaderFooterView<UIView>(.callback(headerBuilder))
    footer.height = { 40 }
    
    return footer
  }()
  
  lazy var sectionFooter: HeaderFooterView<UIView> = {
    let footerBuilder = { () -> UIView in
      let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
      let disclosure = "By signing up you are agreeing to the\nTerms of Service and Privacy Policy"
      let label = TTTAttributedLabel(frame: CGRect(x: 24, y: 71, width: self.view.frame.width - 40, height: 50))
      let termsRange = (disclosure as NSString).range(of: "Terms of Service")
      let privacyRange = (disclosure as NSString).range(of: "Privacy Policy")
      let termsUrl = URL(string: "https://www.gymrats.app/terms/")!
      let privacyUrl = URL(string: "https://www.gymrats.app/privacy/")!

      label.font = .details
      label.numberOfLines = 0
      label.textColor = .secondaryText
      label.textAlignment = .center
      label.isUserInteractionEnabled = true
      label.delegate = self
      label.text = disclosure
      label.activeLinkAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.brand,
      ]
      label.linkAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.brand.darker,
      ]

      label.addLink(to: termsUrl, with: termsRange)
      label.addLink(to: privacyUrl, with: privacyRange)
      
      let createAccountButton = PrimaryButton()
      createAccountButton.addTarget(self, action: #selector(self.createAccountButtonTapped), for: .touchUpInside)
      createAccountButton.setTitle("Create account", for: .normal)
      createAccountButton.translatesAutoresizingMaskIntoConstraints = false
      
      container.addSubview(createAccountButton)
      container.addSubview(label)

      createAccountButton.constrainWidth(250)
      createAccountButton.horizontallyCenter(in: container)
      createAccountButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 15).isActive = true
      
      return container
    }
      
    var footer = HeaderFooterView<UIView>(.callback(footerBuilder))
    footer.height = { 230 }
    
    return footer
  }()
  
  let profilePictureRow: ImageRow = {
    return ImageRow() { imageRow in
      imageRow.title = "Profile picture"
      imageRow.tag = "pro_pic"
      imageRow.placeholderImage = UIImage(named: "photo")?.withRenderingMode(.alwaysTemplate)
      imageRow.sourceTypes = [.Camera, .PhotoLibrary]
    }.cellSetup { cell, _ in
      cell.tintColor = .primaryText
      cell.height = { return 48 }
    }
  }()
  
  lazy var passwordRow: PasswordRow = {
    return PasswordRow() { passwordRow in
      passwordRow.title = "Password"
      passwordRow.tag = "password"
      passwordRow.add(rule: RuleRequired())
      passwordRow.add(rule: RuleMinLength(minLength: 6))
      passwordRow.add(rule: RuleMaxLength(maxLength: 16))
    }
    .cellSetup(self.standardCellSetup)
    .onRowValidationChanged(self.handleRowValidationChange)
  }()
  
  lazy var confirmPasswordRow: PasswordRow = {
    return PasswordRow() { passwordRow in
      passwordRow.title = "Confirm password"
      passwordRow.tag = "confirmPass"
      passwordRow.add(rule: RuleEqualsToRow(form: form, tag: "password"))
    }
    .cellSetup(self.standardCellSetup)
    .onRowValidationChanged(self.handleRowValidationChange)
  }()
  
  lazy var fullNameRow: TextRow = {
    return TextRow() { textRow in
      textRow.title = "Full name"
      textRow.tag = "full_name"
      textRow.placeholder = "Master Splinter"
      textRow.add(rule: RuleRequired())
    }
    .cellSetup(self.standardCellSetup)
    .onRowValidationChanged(self.handleRowValidationChange)
  }()
  
  lazy var emailRow: EmailRow = {
    return EmailRow() { emailRow in
      emailRow.title = "Email"
      emailRow.placeholder = "your@email.com"
      emailRow.tag = "email"
      emailRow.add(rule: RuleEmail())
      emailRow.add(rule: RuleRequired())
    }
    .cellSetup(self.standardCellSetup)
    .onRowValidationChanged(self.handleRowValidationChange)
  }()
}

// Mark: Shared madness
extension CreateAccountViewController {
  func standardCellSetup(textCell: TextCell, textRow: TextRow) {
    textCell.textField.font = .body
    textCell.textLabel?.font = .body
    textCell.tintColor = .brand
    textCell.height = { return 48 }
  }
    
  func standardCellSetup(passwordCell: PasswordCell, passwordRow: PasswordRow) {
    passwordCell.textField.font = .body
    passwordCell.textLabel?.font = .body
    passwordCell.tintColor = .brand
    passwordCell.height = { return 48 }
  }
    
  func standardCellSetup(emailCell: EmailCell, emailRow: EmailRow) {
    emailCell.textField.font = .body
    emailCell.textLabel?.font = .body
    emailCell.tintColor = .brand
    emailCell.height = { return 48 }
  }
    
  func handleRowValidationChange(cell: UITableViewCell, textRow: TextRow) {
    guard let textRowNumber = textRow.indexPath?.row, var section = textRow.section else { return }
    
    let validationLabelRowNumber = textRowNumber + 1
    
    while validationLabelRowNumber < section.count && section[validationLabelRowNumber] is LabelRow {
      section.remove(at: validationLabelRowNumber)
    }
    
    if textRow.isValid { return }

    for (index, validationMessage) in textRow.validationErrors.map({ $0.msg }).enumerated() {
      let labelRow = LabelRow() {
        $0.title = validationMessage
        $0.cell.height = { 30 }
      }

      section.insert(labelRow, at: validationLabelRowNumber + index)
    }
  }
    
  func handleRowValidationChange(cell: UITableViewCell, emailRow: EmailRow) {
    guard let textRowNumber = emailRow.indexPath?.row, var section = emailRow.section else { return }
    
    let validationLabelRowNumber = textRowNumber + 1
    
    while validationLabelRowNumber < section.count && section[validationLabelRowNumber] is LabelRow {
      section.remove(at: validationLabelRowNumber)
    }
    
    if emailRow.isValid { return }

    for (index, validationMessage) in emailRow.validationErrors.map({ $0.msg }).enumerated() {
      let labelRow = LabelRow() {
        $0.title = validationMessage
        $0.cell.height = { 30 }
      }
      
      section.insert(labelRow, at: validationLabelRowNumber + index)
    }
  }
  
  func handleRowValidationChange(cell: UITableViewCell, passwordRow: PasswordRow) {
    guard let textRowNumber = passwordRow.indexPath?.row, var section = passwordRow.section else { return }
    
    let validationLabelRowNumber = textRowNumber + 1
    
    while validationLabelRowNumber < section.count && section[validationLabelRowNumber] is LabelRow {
      section.remove(at: validationLabelRowNumber)
    }
    
    if passwordRow.isValid { return }
    
    for (index, validationMessage) in passwordRow.validationErrors.map({ $0.msg }).enumerated() {
      let labelRow = LabelRow() {
        $0.title = validationMessage
        $0.cell.height = { 30 }
      }
      
      section.insert(labelRow, at: validationLabelRowNumber + index)
    }
  }
}

extension CreateAccountViewController: TTTAttributedLabelDelegate {
  func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    let webView = WebViewController(url: url)
    let nav = UINavigationController(rootViewController: webView)
    
    self.present(nav, animated: true, completion: nil)
  }
}
