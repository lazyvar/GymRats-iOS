//
//  WelcomeViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class WelcomeViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    let logoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "mr-rat"))
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()

    let loginButton: UIButton = .secondary(text: "Log In")
    
    let signUpButton: UIButton = .secondary(text: "Sign Up")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackButton()
                
        view.backgroundColor = .background
        
        let logoBackground = UIView()
        logoBackground.backgroundColor = .brand
        
        let text = UILabel()
        text.font = .h2
        text.text = "Welcome to GymRats."
        text.textAlignment = .center
        
        logoBackground.addSubview(logoView)
        logoBackground.addConstraintsWithFormat(format: "V:|[v0]|", views: logoView)
        logoBackground.addConstraintsWithFormat(format: "H:|[v0]|", views: logoView)
        
        view.addSubview(logoBackground)
        view.addSubview(text)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        
        view.addConstraintsWithFormat(format: "V:|[v0(144)]-20-[v1]-20-[v2]-15-[v3]", views: logoBackground, text, loginButton, signUpButton)
        
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: logoBackground)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: text)
        view.addConstraintsWithFormat(format: "H:|-64-[v0]-64-|", views: loginButton)
        view.addConstraintsWithFormat(format: "H:|-64-[v0]-64-|", views: signUpButton)

        loginButton.onTouchUpInside { [weak self] in
            self?.present(LoginViewController().inNav(), animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        signUpButton.onTouchUpInside { [weak self] in
            self?.present(SignUpViewController().inNav(), animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }
    
}
