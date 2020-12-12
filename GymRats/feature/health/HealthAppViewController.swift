//
//  HealthAppViewController.swift
//  GymRats
//
//  Created by mack on 11/29/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol HealthAppViewControllerDelegate: class {
  func closed(_ healthAppViewController: HealthAppViewController, tappedAllow: Bool)
  func closeButtonHidden() -> Bool
}

class HealthAppViewController: BindableViewController {
  private let disposeBag = DisposeBag()
  private let viewModel = HealthAppViewModel()
  
  @IBOutlet private weak var contentLabel: UILabel! {
    didSet {
      contentLabel.font = .body
      contentLabel.textColor = .primaryText
    }
  }

  @IBOutlet private weak var autoSyncLabel: UILabel! {
    didSet {
      autoSyncLabel.font = .emphasis
      autoSyncLabel.textColor = .secondaryText
    }
  }
  
  @IBOutlet private weak var autoSyncDetailsLabel: UILabel! {
    didSet {
      autoSyncDetailsLabel.font = .details
      autoSyncDetailsLabel.textColor = .secondaryText
    }
  }
  
  @IBOutlet private weak var rats100: UIImageView! {
    didSet {
      rats100.layer.cornerRadius = 16
      rats100.clipsToBounds = true
    }
  }
  
  @IBOutlet private weak var permissionLabel: UILabel!{
    didSet {
      permissionLabel.font = .emphasis
      permissionLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var permissionDetailsLabel: UILabel! {
    didSet {
      permissionDetailsLabel.font = .details
      permissionDetailsLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var autoSyncSwitch: UISwitch!
  @IBOutlet private weak var healthAppButton: SecondaryButton!
  @IBOutlet private weak var grantPermissionButton: PrimaryButton!
  
  private var tappedAllow: Bool = false

  weak var delegate: HealthAppViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    autoSyncSwitch.onTintColor = .brand
    navigationItem.largeTitleDisplayMode = .always
    
    if !(delegate?.closeButtonHidden() ?? false) {
      navigationItem.leftBarButtonItem = UIBarButtonItem(image: .close, style: .plain, target: self, action: #selector(closeMe))
    }

    viewModel.input.viewDidLoad.trigger()
  }

  override func bindViewModel() {
    viewModel.output.autoSyncEnabled
      .bind(to: autoSyncSwitch.rx.isOn)
      .disposed(by: disposeBag)

    viewModel.output.autoSyncSectionDisabled
      .map { $0 ? UIColor.secondaryText : UIColor.primaryText }
      .bind(to: autoSyncLabel.rx.textColor)
      .disposed(by: disposeBag)

    viewModel.output.autoSyncSectionDisabled
      .map { $0 ? UIColor.secondaryText : UIColor.primaryText }
      .bind(to: autoSyncDetailsLabel.rx.textColor)
      .disposed(by: disposeBag)

    viewModel.output.autoSyncSectionDisabled
      .map { !$0 }
      .bind(to: autoSyncSwitch.rx.isEnabled)
      .disposed(by: disposeBag)

    viewModel.output.grantPermissionButtonIsHidden
      .bind(to: grantPermissionButton.rx.isHidden)
      .disposed(by: disposeBag)

    viewModel.output.healthSettingsButtonIsHidden
      .do(onNext: { [self] isHidden in
        if !isHidden {
          tappedAllow = true
        }
      })
      .bind(to: healthAppButton.rx.isHidden)
      .disposed(by: disposeBag)

    viewModel.output.autoSyncDetailsText
      .bind(to: autoSyncDetailsLabel.rx.text)
      .disposed(by: disposeBag)

    viewModel.output.permissionDetailsText
      .bind(to: permissionDetailsLabel.rx.text)
      .disposed(by: disposeBag)

    viewModel.output.openHealthApp
      .subscribe(onNext: {
        GymRats.open(url: "x-apple-health://")
      })
      .disposed(by: disposeBag)
  }
  
  @objc private func closeMe() {
    delegate?.closed(self, tappedAllow: tappedAllow)
  }

  @IBAction func autoSyncSwitchChanged(_ sender: UISwitch) {
    viewModel.input.autoSyncSwitchChanged.on(.next(sender.isOn))
  }
  
  @IBAction func grantPermissionTapped(_ sender: Any) {
    tappedAllow = true
    viewModel.input.grantPermissionTapped.trigger()
  }
  
  @IBAction func openHealthApp(_ sender: Any) {
    viewModel.input.healthSettingsTapped.trigger()
  }
}
