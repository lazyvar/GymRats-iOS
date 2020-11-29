//
//  HealthAppViewController.swift
//  GymRats
//
//  Created by mack on 11/29/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class HealthAppViewController: BindableViewController {
  private let disposeBag = DisposeBag()
  private let viewModel = HealthAppViewModel()
  
  @IBOutlet private weak var contentLabel: UILabel! {
    didSet {
      contentLabel.font = .body
      contentLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var autoSyncLabel: UILabel!{
    didSet {
      autoSyncLabel.font = .body
      autoSyncLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var grantPermissionButton: PrimaryButton!
  @IBOutlet private weak var notNowButton: SecondaryButton!
  @IBOutlet private weak var autoSyncSwitch: UISwitch!
  @IBOutlet private weak var healthAppButton: SecondaryButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if navigationController?.viewControllers.count == 1 {
      navigationItem.leftBarButtonItem = UIBarButtonItem(image: .close, style: .plain, target: target, action: #selector(close))
      navigationItem.title = "Health app sync?"
    } else {
      navigationItem.title = "Health app settings"
      notNowButton.isHidden = true
    }
    
    viewModel.input.viewDidLoad.trigger()
  }
  
  override func bindViewModel() {
    viewModel.output.autoSyncEnabled
      .bind(to: autoSyncSwitch.rx.isOn)
      .disposed(by: disposeBag)

    viewModel.output.grantPermissionButtonIsHidden
      .bind(to: grantPermissionButton.rx.isHidden)
      .disposed(by: disposeBag)

    viewModel.output.healthSettingsButtonIsHidden
      .bind(to: healthAppButton.rx.isHidden)
      .disposed(by: disposeBag)

    viewModel.output.openHealthApp
      .subscribe(onNext: {
        GymRats.open(url: "x-apple-health://")
      })
      .disposed(by: disposeBag)
  }
  
  @objc private func close() {
    
  }

  @IBAction func autoSyncSwitchChanged(_ sender: UISwitch) {
    viewModel.input.autoSyncSwitchChanged.on(.next(sender.isOn))
  }
  
  @IBAction private func notNow(_ sender: Any) {
    close()
  }
  
  @IBAction private func grantPermission(_ sender: Any) {
    viewModel.input.grantPermissionTapped.trigger()
  }
  
  @IBAction func openHealthApp(_ sender: Any) {
    viewModel.input.healthSettingsTapped.trigger()
  }
}
