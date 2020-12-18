//
//  UIViewController+Extension.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIViewController {
    func push(_ viewController: UIViewController, animated: Bool = true) {
      viewController.hidesBottomBarWhenPushed = true

      navigationController?.pushViewController(viewController, animated: animated)
    }

    func presentInNav(_ viewController: UIViewController) {
      present(viewController.inNav(), animated: true)
    }
  
    func presentForClose(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
      let navigationController = viewController.inNav()
      viewController.navigationItem.leftBarButtonItem = .close(target: viewController)
      
      present(navigationController, animated: true, completion: completion)
    }

    func inNav() -> UINavigationController {
      return GymRatsNavigationController(rootViewController: self)
    }
    
    func setupBackButton() {
      let chevronLeft = UIImage.chevronLeft.withRenderingMode(.alwaysTemplate)
      
      navigationController?.navigationBar.backIndicatorImage = chevronLeft
      navigationController?.navigationBar.backIndicatorTransitionMaskImage = chevronLeft
      navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    func setupMenuButton() {
      let menu = UIBarButtonItem (
        image: .menu,
        style: .plain,
        target: self,
        action: #selector(UIViewController.toggleMenu)
      )
      
      navigationItem.leftBarButtonItem = menu
    }
  
  @objc func toggleMenu() {
    guard let drawer = mm_drawerController else { return }
    
    if drawer.openSide == .left {
      drawer.closeDrawer(animated: true, completion: nil)
    } else {
      drawer.open(.left, animated: true, completion: nil)
    }
  }
  
  var gymRatsNavigationController: GymRatsNavigationController? {
    return navigationController as? GymRatsNavigationController
  }
    
  func showLoadingBar(disallowUserInteraction: Bool = false) {
    gymRatsNavigationController?.showLoading()

    if disallowUserInteraction {
      UIApplication.shared.beginIgnoringInteractionEvents()
    }
  }

  func hideLoadingBar() {
    gymRatsNavigationController?.hideLoading()

    UIApplication.shared.endIgnoringInteractionEvents()
  }

  func setupForHome() {
    setupMenuButton()
    setupBackButton()

    navigationItem.rightBarButtonItem = UIBarButtonItem (
      image: UIImage(named: "chat"),
      style: .plain,
      target: self,
      action: #selector(doNothing)
    )
  }
  
  convenience init(_ xibName: String) {
    self.init(nibName: xibName, bundle: nil)
  }
    
  @objc func doNothing() { }
  
  static var xibName: String {
    return classNameWithoutModule(Self.self)
  }
  
  func adjustLargeTitleSize() {
    guard let title = navigationItem.title else { return }

    let maxWidth = UIScreen.main.bounds.size.width - 40
    var fontSize = UIFont.title.pointSize
    var width = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.proRoundedBold(size: fontSize)]).width

    while width > maxWidth {
      fontSize -= 1
      width = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.proRoundedBold(size: fontSize)]).width
    }

    navigationController?.navigationBar.largeTitleTextAttributes = [
      NSAttributedString.Key.font: UIFont.proRoundedBold(size: fontSize)
    ]
  }
  
  func presentAlert(title: String, message: String) {
    DispatchQueue.main.async {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      
      alertController.addAction(okAction)
      self.present(alertController, animated: true, completion:  nil)
    }
  }
    
  func presentAlert(with error: Error) {
    presentAlert(title: "Uh-oh", message: error.localizedDescription)
  }
    
  @objc func dismissSelf() {
    self.dismiss(animated: true, completion: nil)
  }
    
  func install(_ child: UIViewController) {
    addChild(child)
    child.view.inflate(in: view)
    child.didMove(toParent: self)
  }
}

func classNameWithoutModule(_ class: AnyClass) -> String {
  return `class`
    .description()
    .components(separatedBy: ".")
    .dropFirst()
    .joined(separator: ".")
}

extension Int {
  var stringify: String {
    return String(self)
  }
}
