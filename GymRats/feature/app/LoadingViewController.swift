//
//  LoadingViewController.swift
//  GymRats
//
//  Created by mack on 8/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class LoadingViewController: UIViewController {
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let launchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
    
    if let launchView = launchScreen?.view {
      launchView.inflate(in: view)
    }
    
    let fetch = Challenge.State.all.fetch()
      .share()
      
    fetch
      .compactMap { $0.object }
      .map { RouteCalculator.home($0) }
      .subscribe(onNext: { (navigation, screen) in
        switch navigation {
        case .replaceDrawerCenter:
          GymRats.replaceRoot(with: DrawerViewController(inititalViewController: screen.viewController))
        default:
          GymRats.replaceRoot(with: DrawerViewController(inititalViewController: screen.viewController.inNav()))
        }
      })
      .disposed(by: disposeBag)

    fetch
      .compactMap { $0.error }
      .subscribe(onNext: { [weak self] error in
        self?.presentAlert(with: error)
      })
      .disposed(by: disposeBag)
  }
}
