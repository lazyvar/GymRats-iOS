//
//  SettingsViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/7/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import Cache
import Kingfisher
import RxSwift
import SafariServices

private let SettingsCellId = "SettingsCell"

class SettingsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteSmoke
        
        setupBackButton()
        
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserWasUpdated), name: .updatedCurrentUser, object: nil)
    }
    
    @objc func currentUserWasUpdated() {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 36))
        view.backgroundColor = .whiteSmoke
        
        let label = UILabel(frame: CGRect(x: 10, y: 8, width: tableView.frame.width, height: 18))
        label.font = .details
        label.textColor = .brand
        
        switch section {
        case 0:
            label.text = "PROFILE"
            break
        case 1:
            label.text = "APP INFO"
            break
        case 2:
            label.text = "STORAGE"
        case 3:
            label.text = "ACCOUNT"
            break
        default:
            break
        }
        
        view.addSubview(label)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 4
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismissSelf()
        
        var image: UIImage! = nil
        if let img = info[.editedImage] as? UIImage {
            image = img
            
        } else if let img = info[.originalImage] as? UIImage {
            image = img
        }

        showLoadingBar()
        
        gymRatsAPI.updateUser(email: nil, name: nil, password: nil, profilePicture: image)
            .subscribe { event in
                self.hideLoadingBar()
                switch event {
                case .next(let user):
                    GymRatsApp.coordinator.updateUser(user)
                case .error(let error):
                    self.presentAlert(with: error)
                default: break
                }
            }.disposed(by: disposeBag)
    }
    
    func chooseProfilePic() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cam = UIAlertAction(title: "Take picture from camera", style: .default) { (alert) in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.cameraCaptureMode = .photo
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let library = UIAlertAction(title: "Choose from library", style: .default) { (alert) in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cam)
        alertController.addAction(library)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let aliasController = ProfileChangeController(changeType: .email)
                self.navigationController?.pushViewController(aliasController, animated: true)
            case 1:
                chooseProfilePic()
            case 2:
                let firstController = ProfileChangeController(changeType: .fullName)
                navigationController?.pushViewController(firstController, animated: true)
            case 3:
                let changePasswordController = ChangePasswordController()
                navigationController?.pushViewController(changePasswordController, animated: true)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                if let reviewURL = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/1453444814?mt=8"), UIApplication.shared.canOpenURL(reviewURL) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(reviewURL)
                    }
                }
            case 1:
                self.openURLInAppBrowser(url: "https://gym-rats-api.herokuapp.com/terms.html")
            case 2:
                self.openURLInAppBrowser(url: "https://gym-rats-api.herokuapp.com/privacy.html")
            case 3:
                let url = URL(string: "mailto:gymratsapp@gmail.com")!
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            default:
                break
            }
        case 2:
            showLoadingBar()
            GService.clearCache()
            KingfisherManager.shared.cache.clearDiskCache()
            KingfisherManager.shared.cache.clearMemoryCache()
            hideLoadingBar()
        case 3:
            GymRatsApp.coordinator.logout()
        default:
            break
        }
    }
    
    func openURLInAppBrowser(url: String) {
        let webView = WebViewController(string: url)
        let nav = UINavigationController(rootViewController: webView)
        
        self.present(nav, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SettingsCellId)
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: SettingsCellId)
        }
        
        let theCell = cell!
        theCell.isUserInteractionEnabled = true
        
        theCell.textLabel?.font = .body
        theCell.detailTextLabel?.font = .body
        theCell.textLabel?.text = ""
        theCell.detailTextLabel?.text = ""
        theCell.accessoryType = .none
        theCell.accessoryView = nil
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                theCell.textLabel?.text = "Email"
                theCell.detailTextLabel?.text = GymRatsApp.coordinator.currentUser.email
                theCell.accessoryType = .disclosureIndicator
            case 1:
                theCell.textLabel?.text = "Profile picture"
                
                let userImageView = UserImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
                userImageView.load(avatarInfo: GymRatsApp.coordinator.currentUser)
                
                cell?.accessoryView = userImageView
            case 2:
                theCell.textLabel?.text = "Name"
                theCell.detailTextLabel?.text = GymRatsApp.coordinator.currentUser.fullName
                theCell.accessoryType = .disclosureIndicator
            case 3:
                theCell.textLabel?.text = "Password"
                theCell.accessoryType = .disclosureIndicator
                theCell.detailTextLabel?.text = "••••••"
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                theCell.textLabel?.text = "App Store"
            case 1:
                theCell.textLabel?.text = "Terms of Service"
            case 2:
                theCell.textLabel?.text = "Privacy Policy"
            case 3:
                theCell.textLabel?.text = "Support"
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                theCell.textLabel?.text = "Clear cache"
            default:
                break
            }
        case 3:
            switch indexPath.row {
            case 0:
                theCell.textLabel?.text = "Sign out"
            default:
                break
            }
        default:
            break
        }
        
        return theCell
    }
    
}
