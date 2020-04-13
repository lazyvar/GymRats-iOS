//
//  ChangePasswordViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/13/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import Eureka
import RxSwift

class ChangePasswordController: GRFormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.backgroundColor = .background
        view.backgroundColor = .background
        tableView?.separatorStyle = .none
        navigationItem.title = "Password"
        
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .brand
            cell.textLabel?.font = .body
            cell.textLabel?.textAlignment = .right
        }
        
        form = form +++ Section() { section in
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 72))
                    let label = UILabel(frame: CGRect(x: 24, y: 9, width: self.view.frame.width-48, height: 44))
                    label.font = .body
                    label.textAlignment = .center
                    label.numberOfLines = 3
                    label.text = "Password must be between 6 and 16 characters long."
                    
                    container.addSubview(label)
                    
                    return container
                }))
                header.height = { 72 }
                return header
            }()
            
            section.footer = {
                
                var footer = HeaderFooterView<UIView>(.callback({
                    
                    let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 96))
                    
                    let signUpButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
                    signUpButton.titleLabel?.font = .body
                    signUpButton.setTitle("SAVE", for: .normal)
                    signUpButton.setTitleColor(UIColor.white, for: .normal)
                    signUpButton.setTitleColor(UIColor.white, for: .highlighted)
                    signUpButton.setBackgroundImage(.init(color: .greenSea), for: .normal)
                    signUpButton.setBackgroundImage(.init(color: UIColor.greenSea.darker), for: .highlighted)
                    signUpButton.addTarget(self, action: #selector(self.doSave), for: .touchUpInside)
                    
                    container.addSubview(signUpButton)
                    
                    return container
                }))
                footer.height = { 222 }
                return footer
            }()
            }
            
            <<< PasswordRow() {
                $0.title = "Current password"
                $0.tag = "current_password"
                $0.add(rule: RuleRequired())
                
                }.cellSetup({ (cell, row) in
                    cell.textField.font = .body
                    cell.textLabel?.font = .body
                    cell.backgroundColor = .foreground
                    cell.tintColor = .brand
                })
                .onRowValidationChanged(self.handleRowValidationChange)

            
            <<< PasswordRow() {
                $0.title = "New password"
                $0.tag = "new_password"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 6))
                $0.add(rule: RuleMaxLength(maxLength: 16))
                
                }.cellSetup({ (cell, row) in
                    cell.textField.font = .body
                    cell.textLabel?.font = .body
                    cell.backgroundColor = .foreground
                    cell.tintColor = .brand
                })
                .onRowValidationChanged(self.handleRowValidationChange)

            
            <<< PasswordRow() {
                $0.title = "Confirm new password"
                $0.tag = "confirm_new_pass"
                $0.add(rule: RuleEqualsToRow(form: form, tag: "new_password"))
                
                }.cellSetup({ (cell, row) in
                    cell.textField.font = .body
                    cell.textLabel?.font = .body
                    cell.backgroundColor = .foreground
                    cell.tintColor = .brand
                })
                .onRowValidationChanged(self.handleRowValidationChange)

    }
    
    let disposeBag = DisposeBag()
    
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

    
    @objc func doSave() {
        guard form.validate().count == 0 else {
            return
        }
        
        let valuesDictionary = form.values()
        let newPassword = valuesDictionary["new_password"] as! String
        let currentPassword = valuesDictionary["current_password"] as! String
        
      showLoadingBar()
      
      gymRatsAPI.updateUser(email: nil, name: nil, password: newPassword, profilePicture: nil, currentPassword: currentPassword)
          .subscribe(onNext: { [weak self] result in
            guard let self = self else { return }
            self.hideLoadingBar()
            
            switch result {
            case .success(let account):
              GymRats.currentAccount = account
              Account.saveCurrent(account)
              NotificationCenter.default.post(name: .currentAccountUpdated, object: account)
              Track.event(.profileEdited, parameters: ["change_type": "password"])
              self.navigationController?.popViewController(animated: true)
            case .failure(let error):
              self.presentAlert(with: error)
            }
          })
          .disposed(by: disposeBag)
    }
}
