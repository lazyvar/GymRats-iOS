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

class LoginViewController: FormViewController {
    
    let disposeBag = DisposeBag()
    
    let loginButton: UIButton = .primary(text: "Log In")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form = form +++ section <<< emailRow <<< passwordRow
        
        setupBackButton()
        
        loginButton.onTouchUpInside { [weak self] in
            self?.login()
        }.disposed(by: disposeBag)
    }
    
    func login() {
        let formValues = form.values()
        
        guard let email = formValues["email"] as? String,
            let password = formValues["password"] as? String else { return }
        
        self.showLoadingBar(disallowUserInteraction: true)
        
        gymRatsAPI.login(email: email, password: password)
            .subscribe(onNext: { [weak self] user in
                self?.hideLoadingBar()
                GymRatsApp.delegate.appCoordinator.login(user: user)
            }, onError: { [weak self] error in
                print(error)
                self?.presentAlert(with: error)
                self?.hideLoadingBar()
            }).disposed(by: disposeBag)
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
        })
    }()
    
    let passwordRow: PasswordRow = {
        return PasswordRow() { passwordRow in
            passwordRow.title = "Password"
            passwordRow.tag = "password"
        }.cellSetup({ (cell, row) in
            cell.textField.font = .body
            cell.textLabel?.font = .body
        })
    }()
    
    lazy var sectionFooter: HeaderFooterView<UIView> = {
        let footerBuilder = { () -> UIView in
            let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
            self.loginButton.layer.cornerRadius = 0
            self.loginButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
            
            container.addSubview(self.loginButton)
            
            return container
        }
        
        var footer = HeaderFooterView<UIView>(.callback(footerBuilder))
        footer.height = { 40 }
        
        return footer
    }()
    
}
