//
//  ChangeProfileViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/13/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

enum ProfileChangeType: String {
    case email = "email"
    case fullName = "name"
}

struct UpdateUser: Encodable {
    var email: String?
    var fullName: String?
}

class ProfileChangeController: UIViewController, UITextFieldDelegate {
    
    let disposeBag = DisposeBag()
    let change: ProfileChangeType
    var bottomLayoutConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        edgesForExtendedLayout = .bottom
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapp))
        tap.numberOfTapsRequired = 1
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func tapp() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tappedSave()
        return false
    }
    
    func setup() {
        textField.delegate = self
        
        view.addSubview(detailLabel)
        view.addSubview(textField)
        view.addSubview(saveButton)
        
        view.addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: detailLabel)
        view.addConstraintsWithFormat(format: "V:|-8-[v0(60)]", views: detailLabel)
        
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: textField)
        view.addConstraintsWithFormat(format: "V:|-76-[v0(44)][v1(48)]", views: textField, saveButton)
        
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: saveButton)
        
        switch change {
        case .email:
            detailLabel.text = "Your email can be used for password recovery."
            textField.text = GymRatsApp.coordinator.currentUser.email
            textField.placeholder = "Enter email"
            navigationItem.title = "Email"
        case .fullName:
            detailLabel.text = "Set your name"
            textField.text = GymRatsApp.coordinator.currentUser.fullName
            textField.placeholder = "Enter name"
            navigationItem.title = "Name"
        }
        
        saveButton.addTarget(self, action: #selector(tappedSave), for: .touchUpInside)
    }
    
    @objc func tappedSave() {
        showLoadingBar()
        
        let text = textField.text ?? ""
        
        guard !text.isEmpty else { return }
        
        let observable: Observable<User>
        
        switch change {
        case .fullName:
            observable = gymRatsAPI.updateUser(email: nil, name: text, password: nil, profilePicture: nil)
        case .email:
            guard text.isValidEmail() else {
                presentAlert(title: "Invalid Email", message: "Please provide a valid email address.")
                
                return
            }
            
            observable = gymRatsAPI.updateUser(email: text, name: nil, password: nil, profilePicture: nil)
        }
        
        observable.subscribe { event in
            self.hideLoadingBar()
            
            switch event {
            case .next(let user):
                GymRatsApp.coordinator.updateUser(user)
                Track.event(.profileEdited, parameters: ["change_type": self.change.rawValue])
                self.navigationController?.popViewController(animated: true)
            case .error(let error):
                self.presentAlert(with: error)
            default: break
            }
        }.disposed(by: disposeBag)
    }
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.font = .body
        label.textAlignment = .center
        label.numberOfLines = 3
        
        return label
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("SAVE", for: .normal)
        button.setTitleColor(UIColor.newWhite, for: .normal)
        button.setTitleColor(UIColor.newWhite, for: .highlighted)
        button.setBackgroundImage(.init(color: .greenSea), for: .normal)
        button.setBackgroundImage(.init(color: UIColor.greenSea.darker), for: .highlighted)

        return button
    }()
    
    let textField: OHTextField = {
        let text = OHTextField()
        text.font = .body
        text.autocorrectionType = .no
        text.returnKeyType = .done
        text.backgroundColor = .foreground
        
        return text
    }()
    
    init(changeType: ProfileChangeType) {
        change = changeType
        
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class OHTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 10)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 10)
    }
    
}

extension String {
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

}
