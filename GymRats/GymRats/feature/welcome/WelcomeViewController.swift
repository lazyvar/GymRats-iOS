//
//  WelcomeViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import FlexLayout
import RxSwift

class WelcomeViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    let logoView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "gr-logo"))
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()

    let loginButton: UIButton = .secondary(text: "Log In")
    
    let signUpButton: UIButton = .secondary(text: "Sign Up")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .brand
        
        view.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.justifyContent = .center
            layout.alignContent = .center
            layout.padding = 64
        }
        
        logoView.configureLayout { layout in
            layout.isEnabled = true
            layout.alignContent = .center
            layout.justifyContent = .center
        }
        
        loginButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }
        
        signUpButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }

        view.addSubview(logoView)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        
        view.yoga.applyLayout(preservingOrigin: true)
        
        loginButton.onTouchUpInside {
            
        }.disposed(by: disposeBag)
        
        signUpButton.onTouchUpInside {
            
        }.disposed(by: disposeBag)

    }
    
}
