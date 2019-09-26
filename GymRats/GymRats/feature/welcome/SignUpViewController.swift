//
//  SignUpViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import Eureka
import TTTAttributedLabel

class SignUpViewController: FormViewController, Special {
    
    let disposeBag = DisposeBag()
    
    let signUpButton: UIButton = .primary(text: "Sign Up")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackButton()
        
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .firebrick
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = .details
            cell.textLabel?.textAlignment = .right
        }
        
        form = form +++ Section()
                <<< profilePictureImageRow
            +++ userInfoSection
                <<< emailRow
                <<< fullNameRow
                <<< passwordRow
                <<< confirmPasswordRow
        
        signUpButton.onTouchUpInside { [weak self] in
            self?.signUp()
        }.disposed(by: disposeBag)
    }
    
    func signUp() {
        guard form.validate().count == 0 else { return }
        
        let valuesDictionary = form.values()

        let email = valuesDictionary["email"] as! String
        let password = valuesDictionary["password"] as! String
        let proPic = valuesDictionary["proPic"] as! UIImage?
        let fullName = valuesDictionary["full_name"] as! String

        self.showLoadingBar(disallowUserInteraction: true)
        
        gymRatsAPI.signUp(email: email, password: password, profilePicture: proPic, fullName: fullName)
            .subscribe(onNext: { [weak self] user in
                self?.hideLoadingBar()
                GymRatsApp.delegate.appCoordinator.login(user: user)
            }, onError: { [weak self] error in
                self?.presentAlert(with: error)
                self?.hideLoadingBar()
            }).disposed(by: disposeBag)
    }
    
    let profilePictureImageRow: ImageRow = {
        return ImageRow() { imageRow in
            imageRow.title = "Profile Picture"
            imageRow.tag = "proPic"
            imageRow.placeholderImage = UIImage(named: "photo")
            imageRow.sourceTypes = [.Camera, .PhotoLibrary]
        }
    }()
    
    lazy var userInfoSection: Section = {
        return Section() { section in
            section.footer = self.sectionFooter
        }
    }()
    
    lazy var sectionFooter: HeaderFooterView<UIView> = {
        let footerBuilder = { () -> UIView in
            let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
            
            let label = TTTAttributedLabel(frame: CGRect(x: 24, y: 56, width: self.view.frame.width-48, height: 50))
            label.font = .body
            label.numberOfLines = 0
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            label.delegate = self
            
            let disclosure = "By signing up you are agreeing to the\nTerms of Service and Privacy Policy"
            
            label.text = disclosure
            
            let termsRange = (disclosure as NSString).range(of: "Terms of Service")
            let privacyRange = (disclosure as NSString).range(of: "Privacy Policy")
            let termsUrl = URL(string: "https://gym-rats-api.herokuapp.com/terms.html")!
            let privacyUrl = URL(string: "https://gym-rats-api.herokuapp.com/privacy.html")!
            
            label.addLink(to: termsUrl, with: termsRange)
            label.addLink(to: privacyUrl, with: privacyRange)
            
            self.signUpButton.layer.cornerRadius = 0
            self.signUpButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 48)

            container.addSubview(self.signUpButton)
            container.addSubview(label)
            
            return container
        }
        
        var footer = HeaderFooterView<UIView>(.callback(footerBuilder))
        footer.height = { 230 }
        
        return footer
    }()
    
    lazy var passwordRow: PasswordRow = {
        return PasswordRow() { passwordRow in
            passwordRow.title = "Password"
            passwordRow.tag = "password"
            passwordRow.add(rule: RuleRequired())
            passwordRow.add(rule: RuleMinLength(minLength: 6))
            passwordRow.add(rule: RuleMaxLength(maxLength: 16))
        }.cellSetup(self.standardCellSetup)
        .onRowValidationChanged(self.handleRowValidationChange)
    }()
    
    lazy var confirmPasswordRow: PasswordRow = {
        return PasswordRow() { passwordRow in
            passwordRow.title = "Confirm password"
            passwordRow.tag = "confirmPass"
            passwordRow.add(rule: RuleEqualsToRow(form: form, tag: "password"))
        }.cellSetup(self.standardCellSetup)
        .onRowValidationChanged(self.handleRowValidationChange)
    }()
    
    lazy var fullNameRow: TextRow = {
        return TextRow() { textRow in
            textRow.title = "Full Name"
            textRow.tag = "full_name"
            textRow.placeholder = "Cindy Lou"
            textRow.add(rule: RuleRequired())
        }.cellSetup(self.standardCellSetup)
        .onRowValidationChanged(self.handleRowValidationChange)
    }()
    
    lazy var emailRow: EmailRow = {
        return EmailRow() { emailRow in
            emailRow.title = "Email"
            emailRow.placeholder = "your@email.com"
            emailRow.tag = "email"
            emailRow.add(rule: RuleEmail())
            emailRow.add(rule: RuleRequired())
        }.cellSetup(self.standardCellSetup)
        .onRowValidationChanged(self.handleRowValidationChange)
    }()
    
}

// Mark: shared Eurekah madness
extension SignUpViewController {
    
    func standardCellSetup(textCell: TextCell, textRow: TextRow) {
        textCell.textField.font = .body
        textCell.textLabel?.font = .body
    }
    
    func standardCellSetup(passwordCell: PasswordCell, passwordRow: PasswordRow) {
        passwordCell.textField.font = .body
        passwordCell.textLabel?.font = .body
    }
    
    func standardCellSetup(emailCell: EmailCell, emailRow: EmailRow) {
        emailCell.textField.font = .body
        emailCell.textLabel?.font = .body
    }
    
    func handleRowValidationChange(cell: UITableViewCell, textRow: TextRow) {
        guard let textRowNumber = textRow.indexPath?.row, var section = textRow.section else { return }
        
        // remove existing validations labels
        let validationLabelRowNumber = textRowNumber + 1
        while validationLabelRowNumber < section.count && section[validationLabelRowNumber] is LabelRow {
            section.remove(at: validationLabelRowNumber)
        }
        
        // show label row for every validation message
        if !textRow.isValid {
            for (index, validationMessage) in textRow.validationErrors.map({ $0.msg }).enumerated() {
                let labelRow = LabelRow() {
                    $0.title = validationMessage
                    $0.cell.height = { 30 }
                }
                
                section.insert(labelRow, at: validationLabelRowNumber + index)
            }
        }
    }
    
    func handleRowValidationChange(cell: UITableViewCell, emailRow: EmailRow) {
        guard let textRowNumber = emailRow.indexPath?.row, var section = emailRow.section else { return }
        
        // remove existing validations labels
        let validationLabelRowNumber = textRowNumber + 1
        while validationLabelRowNumber < section.count && section[validationLabelRowNumber] is LabelRow {
            section.remove(at: validationLabelRowNumber)
        }
        
        // show label row for every validation message
        if !emailRow.isValid {
            for (index, validationMessage) in emailRow.validationErrors.map({ $0.msg }).enumerated() {
                let labelRow = LabelRow() {
                    $0.title = validationMessage
                    $0.cell.height = { 30 }
                }
                
                section.insert(labelRow, at: validationLabelRowNumber + index)
            }
        }
    }
    
    func handleRowValidationChange(cell: UITableViewCell, passwordRow: PasswordRow) {
        guard let textRowNumber = passwordRow.indexPath?.row, var section = passwordRow.section else { return }
        
        // remove existing validations labels
        let validationLabelRowNumber = textRowNumber + 1
        while validationLabelRowNumber < section.count && section[validationLabelRowNumber] is LabelRow {
            section.remove(at: validationLabelRowNumber)
        }
        
        // show label row for every validation message
        if !passwordRow.isValid {
            for (index, validationMessage) in passwordRow.validationErrors.map({ $0.msg }).enumerated() {
                let labelRow = LabelRow() {
                    $0.title = validationMessage
                    $0.cell.height = { 30 }
                }
                
                section.insert(labelRow, at: validationLabelRowNumber + index)
            }
        }
    }
    
}

extension SignUpViewController: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let webView = WebViewController(url: url)
        let nav = UINavigationController(rootViewController: webView)
        
        self.present(nav, animated: true, completion: nil)
    }
    
}
