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

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  private let disposeBag = DisposeBag()
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: .leastNonzeroMagnitude))
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .background
    
    if navigationController?.viewControllers.count == 1 {
      setupMenuButton()
    }
    
    navigationItem.largeTitleDisplayMode = .never
    setupBackButton()
    
    tableView.tableFooterView = UIView()
    tableView.backgroundColor = .background
    tableView.delegate = self
    tableView.dataSource = self
    
    gymRatsAPI.getCurrentAccount()
      .subscribe(onNext: { result in
        guard let account = result.object else { return }
        
        GymRats.currentAccount = account
        Account.saveCurrent(account)
        NotificationCenter.default.post(name: .currentAccountUpdated, object: account)
      })
      .disposed(by: disposeBag)
    
    NotificationCenter.default.addObserver(self, selector: #selector(currentAccountUpdated), name: .currentAccountUpdated, object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  
    Track.screen(.settings)
  }
    
  @objc private func currentAccountUpdated() {
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 36))
    view.backgroundColor = .background
    
    let label = UILabel(frame: CGRect(x: 10, y: 8, width: tableView.frame.width, height: 18))
    label.font = .details
    label.textColor = .brand
    label.backgroundColor = .clear
    
    switch section {
    case 0:
      label.text = "PROFILE"
    case 1:
      label.text = "APP INFO"
    case 2:
      label.text = "STORAGE"
    case 3:
      label.text = "ACCOUNT"
    default: break
    }
    
    view.addSubview(label)
    
    return view
  }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return 36
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
      return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      switch section {
      case 0: return 4
      case 1: return 4
      case 2: return 1
      case 3: return 3
      default: return 0
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
        
      gymRatsAPI.updateUser(email: nil, name: nil, password: nil, profilePicture: image, currentPassword: nil)
        .subscribe(onNext: { [weak self] result in
          self?.hideLoadingBar()
          
          switch result {
          case .success(let account):
            GymRats.currentAccount = account
            Account.saveCurrent(account)
            NotificationCenter.default.post(name: .currentAccountUpdated, object: account)
          case .failure(let error):
            self?.presentAlert(with: error)
          }
        })
        .disposed(by: disposeBag)
    }
    
    func chooseProfilePic() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cam = UIAlertAction(title: "Camera", style: .default) { (alert) in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.cameraCaptureMode = .photo
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let library = UIAlertAction(title: "Photo library", style: .default) { (alert) in
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
                self.openURLInAppBrowser(url: "https://www.gymrats.app/terms")
            case 2:
                self.openURLInAppBrowser(url: "https://www.gymrats.app/privacy")
            case 3:
              push(SupportViewController())
            default:
                break
            }
        case 2:
          showLoadingBar()

          DispatchQueue.global().async {
            GService.clearCache()
            KingfisherManager.shared.cache.clearDiskCache()
            KingfisherManager.shared.cache.clearMemoryCache()
            EZCache.shared.clear()
            
            DispatchQueue.main.async {
              self.hideLoadingBar()
            }
          }
        case 3:
          let healthAppViewController = HealthAppViewController()
          healthAppViewController.title = "Health app settings"
          healthAppViewController.delegate = self

          switch indexPath.row {
          case 0: push(NotificationSettingsViewController())
          case 1: push(healthAppViewController)
          case 2: GymRats.logout()
          default: break
          }
        default:
          break
        }
    }
    
    func openURLInAppBrowser(url: String) {
        let webView = WebViewController(string: url)
        let nav = UINavigationController(rootViewController: webView)
        
        self.present(nav, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SettingsCellId)
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: SettingsCellId)
        }
        
        let theCell = cell!

        theCell.backgroundColor = .foreground
        
        theCell.isUserInteractionEnabled = true
        
        theCell.textLabel?.font = .body
        theCell.detailTextLabel?.font = .body
        theCell.textLabel?.text = ""
        theCell.detailTextLabel?.text = ""
        theCell.accessoryType = .none
        theCell.accessoryView = nil
        theCell.accessoryType = .disclosureIndicator
      
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                theCell.textLabel?.text = "Email"
                theCell.detailTextLabel?.text = GymRats.currentAccount.email
                theCell.accessoryType = .disclosureIndicator
            case 1:
                theCell.textLabel?.text = "Profile picture"
                
                let userImageView = UserImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
                userImageView.load(GymRats.currentAccount)
                
                cell?.accessoryView = userImageView
            case 2:
                theCell.textLabel?.text = "Name"
                theCell.detailTextLabel?.text = GymRats.currentAccount.fullName
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
                theCell.textLabel?.text = "App Store page"
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
                theCell.textLabel?.text = "Notifications"
            case 1:
                theCell.textLabel?.text = "Health app"
            case 2:
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

extension SettingsViewController: HealthAppViewControllerDelegate {
  func closed(_ healthAppViewController: HealthAppViewController, tappedAllow: Bool) {
    navigationController?.popViewController(animated: true)
  }

  func closeButtonHidden() -> Bool {
    return true
  }
}
