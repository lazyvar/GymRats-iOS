//
//  UIAlertViewController+Rx.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

protocol AlertActionType {
  associatedtype Result

  var title: String? { get }
  var style: UIAlertAction.Style { get }
  var result: Result { get }
}

struct AlertAction<R>: AlertActionType {
  typealias Result = R
  
  let title: String?
  let style: UIAlertAction.Style
  let result: R
}

struct OKAlertAction: AlertActionType {
  typealias Result = Void

  let title: String? = "OK"
  let style: UIAlertAction.Style = .default
  let result: Result = ()
}

extension UIAlertController {
  static func present(_ error: Error, from viewController: UIViewController = .topmost()) -> Observable<Void> {
    present(title: "Uh-oh", message: error.localizedDescription, actions: [OKAlertAction()])
  }
    
  static func present<Action: AlertActionType, Result> (
    title: String,
    message: String,
    from viewController: UIViewController = .topmost(),
    preferredStyle: UIAlertController.Style = .alert,
    animated: Bool = true,
    actions: [Action]
  ) -> Observable<Result> where Action.Result == Result {
    return Observable.create { observer -> Disposable in
      let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)

      actions.map { action in
        return UIAlertAction(title: action.title, style: action.style, handler: { _ in
          observer.onNext(action.result)
          observer.onCompleted()
        })
      }
      .forEach(alertController.addAction)

      viewController.present(alertController, animated: animated, completion: nil)

      return Disposables.create {
        alertController.dismiss(animated: true, completion: nil)
      }
    }
  }
}
