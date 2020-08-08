//
//  ViewModel.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift
import Kingfisher
import MMDrawerController

protocol ViewModel {
  associatedtype Intput
  associatedtype Output
  
  var input: Intput { get }
  var output: Output { get }
}

extension BehaviorSubject {
  var value: Element {
    get {
      return try! value()
    }
    set {
      onNext(newValue)
    }
  }
}

extension Observable {
  func ignore(disposedBy disposeBag: DisposeBag) {
    return subscribe { _ in }
    .disposed(by: disposeBag)
  }

  func next(_ do: @escaping (Element) -> Void) -> Disposable {
    return subscribe { event in
      if case .next(let element) = event { `do`(element) }
    }
  }
}

enum InputSubject {
  static func string(defaultValue: String = "") -> BehaviorSubject<String> {
    return .init(value: defaultValue)
  }

  static func tap() -> BehaviorSubject<Void> {
    return .init(value: ())
  }

  static func viewLifecycle() -> BehaviorSubject<Void> {
    return .init(value: ())
  }
}

extension BehaviorSubject where Element == Void {
  func trigger() {
    value = ()
  }
}

extension PublishSubject where Element == Void {
  func trigger() {
    onNext(())
  }
}

struct LocalizedErrorMessage: Error, LocalizedError {
  private let error: Error?
  private let message: String?
  
  init(_ error: Error) { self.error = error; self.message = nil }
  init(_ message: String) { self.message = message; self.error = nil}

  var errorDescription: String? { return message ?? error?.localizedDescription ?? "Something went wrong. Please try again." }
}

extension Error {
  func localized() -> LocalizedErrorMessage {
    return .init(self)
  }
}

typealias NetworkResult<T> = Result<T, LocalizedErrorMessage>

extension Result {
  var success: Bool { object != nil}
  var failure: Bool { error != nil }
  
  var object: Success? {
    switch self {
    case .success(let object): return object
    case .failure: return nil
    }
  }

  var error: Failure? {
    switch self {
    case .success: return nil
    case .failure(let error): return error
    }
  }
}

extension Decodable {
  init(from anything: Any) throws {
    let data = try JSONSerialization.data(withJSONObject: anything, options: .prettyPrinted)

    self = try JSONDecoder.gymRatsAPIDecoder.decode(Self.self, from: data)
  }
}

extension Notification {
  static let commentNotification = Notification(name: .commentNotification)
  static let challengeEdited = Notification(name: .challengeEdited)
  static let leftChallenge = Notification(name: .leftChallenge)
  static let workoutCreated = Notification(name: .workoutCreated)
  static let workoutsLoaded = Notification(name: .workoutsLoaded)
  static let workoutDeleted = Notification(name: .workoutDeleted)
  static let currentAccountUpdated = Notification(name: .currentAccountUpdated)
  static let appEnteredForeground = Notification(name: .appEnteredForeground)
  static let appEnteredBackground = Notification(name: .appEnteredBackground)
  static let sawChat = Notification(name: .sawChat)
  static let joinedChallenge = Notification(name: .joinedChallenge)
}

extension NSNotification.Name {
  static let commentNotification = NSNotification.Name.init("CommentNotification")
  static let chatNotification = NSNotification.Name.init("ChatNotification")
  static let challengeEdited = NSNotification.Name.init("ChallengeEdited")
  static let leftChallenge = NSNotification.Name.init("LeftChallenge")
  static let workoutCreated = NSNotification.Name.init("WorkoutCreated")
  static let workoutsLoaded = NSNotification.Name.init("WorkoutsLoaded")
  static let workoutDeleted = NSNotification.Name.init("WorkoutDeleted")
  static let currentAccountUpdated = NSNotification.Name.init("CurrentAccountUpdated")
  static let appEnteredForeground = NSNotification.Name.init("AppEnteredForeground")
  static let appEnteredBackground = NSNotification.Name.init("AppEnteredBackground")
  static let sawChat = NSNotification.Name.init("SawChat")
  static let joinedChallenge = NSNotification.Name.init("JoinedChallenge")
}

extension UIView: Placeholder { }


struct UserWorkout {
  let user: Account
  let workout: Workout?
}

extension Keychain {
    static var gymRats = Keychain(group: nil)
}

extension Keychain.Key where Object == Account {
    static var currentUser: Keychain.Key<Account> {
        return Keychain.Key<Account>(rawValue: "currentUser", synchronize: true)
    }
}

extension UIWindow {
  func topmostViewController() -> UIViewController {
    func recurse(_ viewController: UIViewController) -> UIViewController {
      switch viewController {
      case let drawer as DrawerViewController:
        return recurse((drawer.children.first as? MMDrawerController)?.centerViewController ?? drawer)
      case let tabBarViewController as UITabBarController:
        return recurse(tabBarViewController.selectedViewController ?? tabBarViewController)
      case let navigationViewController as UINavigationController:
        return recurse(navigationViewController.viewControllers.last ?? navigationViewController)
      default:
        if let presentedViewController = viewController.presentedViewController, !presentedViewController.isBeingDismissed {
          return recurse(presentedViewController)
        } else {
          return viewController
        }
      }
    }
    
    return recurse(rootViewController!)
  }
}

extension UIViewController {
  static func topmost(for window: UIWindow = UIApplication.shared.keyWindow!) -> UIViewController {
    return window.topmostViewController()
  }
}

extension UIBarButtonItem {
  static func close(target: Any?) -> UIBarButtonItem {
    return UIBarButtonItem(image: .close, style: .plain, target: target, action: #selector(UIViewController.dismissSelf))
  }
}

public extension CGFloat {
  static func scaleAndShift(
    value: CGFloat,
    inRange: (min: CGFloat, max: CGFloat),
    toRange: (min: CGFloat, max: CGFloat) = (min: 0.0, max: 1.0)
  ) -> CGFloat {
    assert(inRange.max > inRange.min)
    assert(toRange.max > toRange.min)

    if value < inRange.min {
      return toRange.min
    } else if value > inRange.max {
      return toRange.max
    } else {
      let ratio = (value - inRange.min) / (inRange.max - inRange.min)
      return toRange.min + ratio * (toRange.max - toRange.min)
    }
  }
}
