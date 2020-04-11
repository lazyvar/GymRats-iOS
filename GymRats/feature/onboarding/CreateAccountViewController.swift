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
    
    title = "Get started"
    
    tableView.backgroundColor = .background
    tableView.separatorStyle = .none
    
    form = form
      +++ userInfoSection
        <<< profilePictureRow
        <<< emailRow
        <<< fullNameRow
        <<< passwordRow
        <<< confirmPasswordRow
  }
  
  @objc private func createAccountButtonTapped() {
    guard form.validate().count == 0 else { return }
    
    let valuesDictionary = form.values()

    let email    = valuesDictionary["email"] as! String
    let password = valuesDictionary["password"] as! String
    let proPic   = valuesDictionary["pro_pic"] as! UIImage?
    let fullName = valuesDictionary["full_name"] as! String

    view.endEditing(true)
    showLoadingBar(disallowUserInteraction: true)
    
    gymRatsAPI.signUp(email: email, password: password, profilePicture: proPic, fullName: fullName)
      .subscribe(onNext: { [weak self] result in
        self?.hideLoadingBar()
        
        switch result {
        case .success(let account):
          Track.event(.signup)
          GymRats.startOnboarding(account)
        case .failure(let error):
          self?.presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: Eurekah
  
  private lazy var userInfoSection: Section = {
    return Section() { section in
      section.footer = self.sectionFooter
      section.header = self.sectionHeader
    }
  }()

  private lazy var sectionHeader: HeaderFooterView<UIView> = {
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
  
  private lazy var sectionFooter: HeaderFooterView<UIView> = {
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
  
  private let profilePictureRow: ProfilePictureRow = {
    return ProfilePictureRow() { row in
      row.tag = "pro_pic"
    }
  }()
  
  private lazy var passwordRow: TextFieldRow = {
    return TextFieldRow() { passwordRow in
      passwordRow.placeholder = "Password"
      passwordRow.tag = "password"
      passwordRow.secure = true
      passwordRow.icon = UIDevice.contentMode == .dark ? .lockWhite : .lockBlack
      
      if #available(iOS 12.0, *) {
        passwordRow.contentType = .newPassword
      }
      
      passwordRow.add(rule: RuleRequired(msg: "Password is required."))
      passwordRow.add(rule: RuleMinLength(minLength: 6, msg: "Password must be greater than 6 characters."))
      passwordRow.add(rule: RuleMaxLength(maxLength: 32, msg: "Password must be less than 32 characters."))
    }
    .cellSetup({ cell, row in
      cell.shadowTextField.autocorrectionType = .no
      cell.shadowTextField.autocapitalizationType = .none
    })
    .onRowValidationChanged(self.handleRowValidationChange)
  }()
  
  private lazy var confirmPasswordRow: TextFieldRow = {
    return TextFieldRow() { passwordRow in
      passwordRow.placeholder = "Confirm password"
      passwordRow.tag = "confirm_pass"
      passwordRow.secure = true
      passwordRow.icon = UIDevice.contentMode == .dark ? .checkWhite : .checkBlack
      passwordRow.add(rule: RuleEqualsToRow(form: form, tag: "password", msg: "Passwords don't match."))
    }
    .cellSetup({ cell, row in
      cell.shadowTextField.autocorrectionType = .no
      cell.shadowTextField.autocapitalizationType = .none
      
      if #available(iOS 12.0, *) {
        cell.shadowTextField.textContentType = .newPassword
      }
    })
    .onRowValidationChanged(self.handleRowValidationChange)
  }()
  
  private lazy var fullNameRow: TextFieldRow = {
    return TextFieldRow() { textRow in
      textRow.placeholder = "Name"
      textRow.tag = "full_name"
      textRow.icon = UIDevice.contentMode == .dark ? .nameWhite : .nameBlack
      textRow.contentType = .givenName
      textRow.add(rule: RuleRequired(msg: "Name is required."))
    }
    .onRowValidationChanged(self.handleRowValidationChange)
  }()
  
  private lazy var emailRow: TextFieldRow = {
    return TextFieldRow() { emailRow in
      emailRow.icon = UIDevice.contentMode == .dark ? .mailWhite : .mailBlack
      emailRow.placeholder = "Email"
      emailRow.tag = "email"
      emailRow.keyboardType = .emailAddress
      emailRow.contentType = .emailAddress
      emailRow.add(rule: RuleEmail(msg: "Email is not valid format."))
      emailRow.add(rule: RuleRequired(msg: "Email is required."))
    }
    .cellSetup({ cell, row in
      cell.shadowTextField.autocorrectionType = .no
      cell.shadowTextField.autocapitalizationType = .none
    })
    .onRowValidationChanged(self.handleRowValidationChange)
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

extension CreateAccountViewController: TTTAttributedLabelDelegate {
  func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    let webView = WebViewController(url: url)
    let nav = UINavigationController(rootViewController: webView)
    
    self.present(nav, animated: true, completion: nil)
  }
}
