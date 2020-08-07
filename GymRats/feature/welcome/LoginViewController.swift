//
//  LoginViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import Eureka

class LoginViewController: GRFormViewController {
    
  private let disposeBag = DisposeBag()
  
  private let loginButton = PrimaryButton()
  private let resetPasswordButton = SecondaryButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
      
    title = "Login"
    
    tableView.backgroundColor = .background
    tableView.separatorStyle = .none

    form = form
      +++ section
        <<< emailRow
        <<< passwordRow
  }
    
  @objc private func login() {
    let formValues = form.values()
    
    guard
      let email = formValues["email"] as? String,
      let password = formValues["password"] as? String else { return }
    
    view.endEditing(true)
    showLoadingBar(disallowUserInteraction: true)
    
    gymRatsAPI.login(email: email, password: password)
      .subscribe(onNext: { [weak self] result in
        self?.hideLoadingBar()
        
        switch result {
        case .success(let user):
          Track.event(.login)
          GymRats.login(user)
          GymRats.replaceRoot(with: LoadingViewController())
        case .failure(let error):
          self?.presentAlert(with: error)
        }
      }).disposed(by: disposeBag)
  }
  
  @objc private func presentResetPasswordThing() {
    let alertController = UIAlertController(title: "Reset Password", message: nil, preferredStyle: .alert)
    let resetPassword = UIAlertAction(title: "Send", style: .default, handler: { _ in
      self.resetPassword(email: alertController.textFields?.first?.text)
      Track.event(.passwordReset)
    })
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alertController.addTextField { (textField: UITextField!) -> Void in
      textField.placeholder = "Email"
      textField.text = self.form.values()["email"] as? String
    }
    
    alertController.addAction(resetPassword)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  private func resetPassword(email: String?) {
    guard let email = email else { return }
    
    showLoadingBar()
    
    gymRatsAPI.resetPassword(email: email)
      .subscribe(onNext: { [weak self] result in
        self?.hideLoadingBar()
          
        switch result {
        case .success:
          self?.presentAlert(title: "Email sent", message: "Check your inbox!")
        case .failure(let error):
          self?.presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)
  }
    
  private lazy var section: Section = {
    return Section() { section in
      section.header = self.sectionHeader
      section.footer = self.sectionFooter
    }
  }()
  
  private lazy var sectionHeader: HeaderFooterView<UIView> = {
    let headerBuilder = { () -> UIView in
      let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))

      let label = UILabel()
      label.font = .body
      label.text = "Welcome back."
      label.frame = CGRect(x: 20, y: 0, width: self.view.frame.width - 40, height: 20)
      label.sizeToFit()
      
      container.addSubview(label)
      
      return container
    }
      
    var footer = HeaderFooterView<UIView>(.callback(headerBuilder))
    footer.height = { 40 }
    
    return footer
  }()

  private let emailRow: TextFieldRow = {
    return TextFieldRow() { textRow in
      textRow.placeholder = "Email"
      textRow.tag = "email"
      textRow.icon = .mail
      textRow.keyboardType = .emailAddress
      textRow.contentType = .emailAddress
    }
    .cellSetup({ cell, row in
      cell.textField.autocapitalizationType = .none
    })
  }()
  
  private let passwordRow: TextFieldRow = {
    return TextFieldRow() { passwordRow in
      passwordRow.placeholder = "Password"
      passwordRow.secure = true
      passwordRow.icon = .lock
      passwordRow.contentType = .password
      passwordRow.tag = "password"
    }
    .cellSetup({ cell, row in
      cell.shadowTextField.autocorrectionType = .no
      cell.shadowTextField.autocapitalizationType = .none
    })
  }()
  
  private lazy var sectionFooter: HeaderFooterView<UIView> = {
    let footerBuilder = { () -> UIView in
      let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 96))
      
      container.addSubview(self.resetPasswordButton)
      container.addSubview(self.loginButton)

      self.loginButton.addTarget(self, action: #selector(self.login), for: .touchUpInside)
      self.resetPasswordButton.addTarget(self, action: #selector(self.presentResetPasswordThing), for: .touchUpInside)
      
      self.loginButton.constrainWidth(250)
      self.resetPasswordButton.constrainWidth(250)
      
      self.loginButton.translatesAutoresizingMaskIntoConstraints = false
      self.resetPasswordButton.translatesAutoresizingMaskIntoConstraints = false
      
      self.loginButton.setTitle("Login", for: .normal)
      self.resetPasswordButton.setTitle("Reset password", for: .normal)
      
      self.loginButton.horizontallyCenter(in: container)
      self.resetPasswordButton.horizontallyCenter(in: container)

      self.loginButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 10).isActive = true
      self.resetPasswordButton.topAnchor.constraint(equalTo: self.loginButton.bottomAnchor, constant: 10).isActive = true

      return container
    }
    
    var footer = HeaderFooterView<UIView>(.callback(footerBuilder))
    footer.height = { 100 }
    
    return footer
  }()
}
