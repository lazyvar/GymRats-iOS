//
//  LoginViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import RxSwift
import PKHUD

class LoginViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    let email: SkyFloatingLabelTextField  = {
        let textField = SkyFloatingLabelTextField()
        textField.errorColor = .firebrick
        textField.placeholder = "Email"
        textField.titleColor = .brand
        textField.selectedLineColor = .brand
        textField.lineErrorColor = .brand
        textField.selectedTitleColor = .brand
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        return textField
    }()

    let password: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.errorColor = .firebrick
        textField.placeholder = "Password"
        textField.titleColor = .brand
        textField.selectedLineColor = .brand
        textField.lineErrorColor = .brand
        textField.selectedTitleColor = .brand
        textField.isSecureTextEntry = true
        
        return textField
    }()
    
    let loginButton: UIButton = .primary(text: "Log In")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Log In"
        view.backgroundColor = .white
     
        view.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.alignContent = .center
            layout.padding = 64
        }
        
        email.configureLayout { layout in
            layout.isEnabled = true
            layout.alignContent = .center
            layout.justifyContent = .center
        }
        
        password.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }
        
        loginButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }
        
        view.addSubview(email)
        view.addSubview(password)
        view.addSubview(loginButton)
        
        view.yoga.applyLayout(preservingOrigin: true)
        
        loginButton.onTouchUpInside { [weak self] in
            self?.tryLogIn()
        }.disposed(by: disposeBag)
        
        let emailRequired = email.requiredValidation
        let passwordRequired = password.requiredValidation

        let enableButton = Observable.combineLatest(emailRequired, passwordRequired) { a, b in
            return a && b
        }

        enableButton
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func tryLogIn() {
        HUD.show(.progress)
        
        gymRatsAPI.login(email: email.text!, password: password.text!)
            .standardServiceResponse { user in
                print(user)
            }.disposed(by: disposeBag)
    }
    
}
