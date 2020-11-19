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
  private let inititalViewController: UIViewController
  
  init(inititalViewController: UIViewController) {
    self.inititalViewController = inititalViewController
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    guard motion == .motionShake else { return }
    
    UIViewController.topmost().presentForClose(SupportViewController())
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    UserDefaults.standard.removeObject(forKey: "account-is-onboarding")
    
    let menu = MenuViewController()
    let home = inititalViewController
    
    let drawer = MMDrawerController(center: home, leftDrawerViewController: menu).apply {
      $0.view.backgroundColor = .background
      $0.showsShadow = false
      $0.maximumLeftDrawerWidth = MenuViewController.width
      $0.centerHiddenInteractionMode = .full
      $0.openDrawerGestureModeMask = []
      $0.closeDrawerGestureModeMask = [.all]
      $0.setDrawerVisualStateBlock(MMDrawerVisualState.parallaxVisualStateBlock(withParallaxFactor: 2))
    }
    
    Observable.merge(NotificationCenter.default.rx.notification(.challengeEdited), NotificationCenter.default.rx.notification(.leftChallenge))
      .flatMap { _ in Challenge.State.all.fetch() }
      .subscribe(onNext: { result in
        switch result {
        case .success(let challenges):
          let (navigation, screen) = RouteCalculator.home(challenges)
          
          switch navigation {
          case .replaceDrawerCenter:
            GymRats.replaceRoot(with: DrawerViewController(inititalViewController: screen.viewController))
          default:
            GymRats.replaceRoot(with: DrawerViewController(inititalViewController: screen.viewController.inNav()))
          }
        case .failure(let error):
          self.presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)
    
    install(drawer)
    
    if let code = UserDefaults.standard.string(forKey: "join-code") {
      UserDefaults.standard.removeObject(forKey: "join-code")
      ChallengeFlow.join(code: code)
    }
      
    NotificationCenter.default.rx.notification(.joinedChallenge)
      .compactMap { $0.object as? Challenge }
      .do(onNext: { challenge in
        UserDefaults.standard.set(challenge.id, forKey: "last_opened_challenge")
      })
      .map { challenge -> (Navigation, Screen) in
        switch challenge.status {
        case .active:
          return (.replaceDrawerCenter(animated: true), .activeChallenge(challenge))
        case .upcoming:
          return (.replaceDrawerCenterInNav(animated: true), .upcomingChallenge(challenge))
        case .complete:
          var challenges = Challenge.State.all.state?.object ?? []
          challenges.removeAll(where: { $0.id == challenge.id })
          challenges.append(challenge)
          
          return RouteCalculator.home(challenges)
        }
      }
      .subscribe(onNext: { (navigation, screen) in
        drawer.centerViewController?.navigate(navigation, to: screen.viewController)
      })
      .disposed(by: disposeBag)
    
    GymRats.handleColdStartNotification()
  }
}
