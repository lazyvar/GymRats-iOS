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
    
    let disposeBag = DisposeBag()
    
    let loginButton: UIButton = .primary(text: "Log in")
    let resetPasswordButton: UIButton = .secondary(text: "Reset password")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Login"
        
        form = form +++ section <<< emailRow <<< passwordRow
        
        tableView.backgroundColor = .background
        setupBackButton()        
        
        loginButton.onTouchUpInside { [weak self] in
            self?.login()
        }.disposed(by: disposeBag)
        
        resetPasswordButton.onTouchUpInside {
            let alertController = UIAlertController(title: "Reset Password", message: nil, preferredStyle: .alert)
            
            let resetPassword = UIAlertAction(title: "Send", style: .default, handler: { _ in
                self.resetPassword(email: alertController.textFields?.first?.text)
                Track.event(.passwordReset)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addTextField { (textField: UITextField!) -> Void in
                textField.placeholder = "Email"
            }
            
            alertController.addAction(resetPassword)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }
    
    func login() {
      let formValues = form.values()
      
      guard let email = formValues["email"] as? String,
          let password = formValues["password"] as? String else { return }
      
      self.showLoadingBar(disallowUserInteraction: true)
        
//        gymRatsAPI.login(email: email, password: password)
//            .subscribe(onNext: { [weak self] user in
//                self?.hideLoadingBar()
//                Track.event(.login)
//                GymRatsApp.delegate.appCoordinator.login(user: user)
//            }, onError: { [weak self] error in
//                self?.presentAlert(title: "Uh-oh", message: error.localizedDescription)
//                self?.hideLoadingBar()
//            }).disposed(by: disposeBag)
    }
    
    func resetPassword(email: String?) {
        guard let email = email else { return }
        
        showLoadingBar()
        gymRatsAPI.resetPassword(email: email)
            .subscribe { event in
                self.hideLoadingBar()
                
                switch event {
                case .next:
                    self.presentAlert(title: "Email sent", message: "Check your inbox!")
                case .error(let error):
                    self.presentAlert(with: error)
                case .completed: break
                }
            }.disposed(by: disposeBag)
    }
    
    lazy var section: Section = {
        return Section() { section in
            section.footer = self.sectionFooter
        }
    }()
    
    let emailRow: TextRow = {
        return TextRow() { textRow in
            textRow.title = "Email"
            textRow.tag = "email"
        }.cellSetup({ cell, row in
            cell.textField.font = .body
            cell.textLabel?.font = .body
            cell.textField.autocapitalizationType = .none
            cell.tintColor = .brand
            cell.height = { return 48 }
        })
    }()
    
    let passwordRow: PasswordRow = {
        return PasswordRow() { passwordRow in
            passwordRow.title = "Password"
            passwordRow.tag = "password"
        }.cellSetup({ (cell, row) in
            cell.textField.font = .body
            cell.textLabel?.font = .body
            cell.tintColor = .brand
            cell.height = { return 48 }
        })
    }()
    
    lazy var sectionFooter: HeaderFooterView<UIView> = {
        let footerBuilder = { () -> UIView in
            let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 96))
            self.loginButton.layer.cornerRadius = 0
            self.loginButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 48)
            self.resetPasswordButton.layer.cornerRadius = 0
            self.resetPasswordButton.frame = CGRect(x: 0, y: 48, width: self.view.frame.width, height: 48)

            container.addSubview(self.resetPasswordButton)
            container.addSubview(self.loginButton)

            return container
        }
        
        var footer = HeaderFooterView<UIView>(.callback(footerBuilder))
        footer.height = { 96 }
        
        return footer
    }()
    
}
