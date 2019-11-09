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

class ChangePasswordController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.separatorStyle = .none
        navigationItem.title = "Password"
        
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .brand
//            cell.textLabel?.textColor = .white
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
                    label.textColor = UIColor.black
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
                    signUpButton.setTitle("Save", for: .normal)
                    signUpButton.setTitleColor(UIColor.white, for: .normal)
//                    signUpButton.backgroundColor = .primary
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
                })
                .onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = validationMsg
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
            }
            
            <<< PasswordRow() {
                $0.title = "New password"
                $0.tag = "new_password"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 6))
                $0.add(rule: RuleMaxLength(maxLength: 16))
                
                }.cellSetup({ (cell, row) in
                    cell.textField.font = .body
                    cell.textLabel?.font = .body
                })
                .onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = validationMsg
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
            }
            
            <<< PasswordRow() {
                $0.title = "Confirm new password"
                $0.tag = "confirm_new_pass"
                $0.add(rule: RuleEqualsToRow(form: form, tag: "new_password"))
                
                }.cellSetup({ (cell, row) in
                    cell.textField.font = .body
                    cell.textLabel?.font = .body
                })
                .onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = validationMsg
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
        }
    }
    
    let disposeBag = DisposeBag()
    
    @objc func doSave() {
        guard form.validate().count == 0 else {
            return
        }
        
        let valuesDictionary = form.values()
        let newPassword = valuesDictionary["new_password"] as! String
        
        showLoadingBar()
        
        gymRatsAPI.updateUser(email: nil, name: nil, password: newPassword, profilePicture: nil)
            .subscribe { event in
                self.hideLoadingBar()
                
                switch event {
                case .next(let user):
                    GymRatsApp.coordinator.updateUser(user)
                    self.navigationController?.popViewController(animated: true)
                case .error(let error):
                    self.presentAlert(with: error)
                default: break
                }
            }.disposed(by: disposeBag)
    }
}
