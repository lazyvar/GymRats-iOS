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


typealias NetworkResult<T> = Result<T, AnyError>

struct AnyError: Error {
  let error: Error & LocalizedError
  
  var localizedDescription: String {
    return error.localizedDescription
  }
  
  var description: String {
    get {
      return error.errorDescription ?? ""
    }
  }

  var errorDescription: String? {
    get {
      return error.errorDescription
    }
  }

}

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

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    
    let decoder: JSONDecoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    self = try decoder.decode(Self.self, from: data)
  }
}

extension Notification {
  static let commentNotification = Notification(name: .commentNotification)
  static let chatNotification = Notification(name: .chatNotification)
  static let challengesUpdated = Notification(name: .challengesUpdated)
  static let workoutCreated = Notification(name: .workoutCreated)
}

extension NSNotification.Name {
  static let commentNotification = NSNotification.Name.init("CommentNotification")
  static let chatNotification = NSNotification.Name.init("ChatNotification")
  static let challengesUpdated = NSNotification.Name.init("ChallengesUpdated")
  static let workoutCreated = NSNotification.Name.init("WorkoutCreated")
}

extension UIView: Placeholder { }
