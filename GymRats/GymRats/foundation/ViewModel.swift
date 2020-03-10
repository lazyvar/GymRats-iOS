//
//  ViewModel.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

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
