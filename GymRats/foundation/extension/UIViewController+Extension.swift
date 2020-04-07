//
//  UIViewController+Extension.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import RxSwift
import RxCocoa

extension UIViewController {
    func push(_ viewController: UIViewController, animated: Bool = true) {
      viewController.hidesBottomBarWhenPushed = true

      navigationController?.pushViewController(viewController, animated: animated)
    }

    func present(_ viewController: UIViewController) {
      present(viewController.inNav(), animated: true)
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
        image: UIImage(named: "menu")?.withRenderingMode(.alwaysTemplate),
        style: .plain,
        target: self,
        action: #selector(UIViewController.toggleMenu)
      )
      menu.tintColor = .lightGray
      
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
    
    func showLoadingBar(disallowUserInteraction: Bool = false) {
      let center = UIApplication.shared.keyWindow!.center
      let thing = NVActivityIndicatorView(frame: CGRect(x: center.x-50, y: center.y-300, width: 100, height: 100), type: .ballPulseSync, color: .brand, padding: 20)
      thing.backgroundColor = .foreground
      thing.layer.cornerRadius = 10
      thing.layer.shadowRadius = 7
      thing.layer.shadowColor = UIColor.shadow.cgColor
      thing.layer.shadowOffset = CGSize(width: 0, height: 0)
      thing.layer.shadowOpacity = 0.5

      view.addSubview(thing)
      
      thing.startAnimating()
      
      if disallowUserInteraction {
        let dimView = UIView()
        view.tag = 333

        UIApplication.shared.beginIgnoringInteractionEvents()
        UIApplication.shared.keyWindow?.addSubview(dimView)
      }
    }

    func hideLoadingBar() {
      UIApplication.shared.endIgnoringInteractionEvents()
      UIApplication.shared.keyWindow?.subviews.first(where: { $0.tag == 333 })?.removeFromSuperview()
      
      if let view = view.allSubviews().first(ofType: NVActivityIndicatorView.self) {
        view.stopAnimating()
        view.removeFromSuperview()
      }
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
  
  func presentAlert(title: String, message: String) {
    DispatchQueue.main.async {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
      
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
