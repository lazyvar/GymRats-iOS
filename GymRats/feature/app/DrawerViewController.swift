//
//  DrawerViewController.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import MMDrawerController
import RxSwift

class DrawerViewController: UIViewController {
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    defer { UserDefaults.standard.removeObject(forKey: "join-code") }
    defer { UserDefaults.standard.removeObject(forKey: "account-is-onboarding") }

    let menu = MenuViewController()
    let home = HomeViewController().inNav()
    
    let drawer = MMDrawerController(center: home, leftDrawerViewController: menu).apply {
      $0.view.backgroundColor = .background
      $0.showsShadow = false
      $0.maximumLeftDrawerWidth = MenuViewController.width
      $0.centerHiddenInteractionMode = .full
      $0.openDrawerGestureModeMask = [.all]
      $0.closeDrawerGestureModeMask = [.all]
      $0.setDrawerVisualStateBlock(MMDrawerVisualState.parallaxVisualStateBlock(withParallaxFactor: 2))
    }

    Observable.merge(NotificationCenter.default.rx.notification(.challengeEdited), NotificationCenter.default.rx.notification(.leftChallenge))
      .next { _ in
        drawer.setCenterView(HomeViewController().inNav(), withCloseAnimation: true, completion: nil)
      }
      .disposed(by: disposeBag)
    
    install(drawer)
  }
}
