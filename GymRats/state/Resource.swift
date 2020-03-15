//
//  Resource.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class Resource<T> {
  var state: T? { return try? subject.value() }
  
  private let subject = BehaviorSubject<T?>(value: nil)
  private let source: () -> Observable<T>
  private let disposeBag = DisposeBag()
  
  init(source: @escaping () -> Observable<T>) {
    self.source = source
  }

  deinit { subject.onCompleted() }

  func fetchIfNeeded() -> Observable<T> {
    if let val = try? subject.value() {
      return .just(val)
    } else {
      return fetch()
    }
  }
  
  func fetch() -> Observable<T> {
    let source = Observable<T>.create { observer in
      return Disposables.create(
        [
          self.source().subscribe { event in
            switch event {
            case .next(let next): observer.onNext(next)
            case .error(let error): observer.onError(error)
            case .completed: break
            }
          }
        ]
      )
    }.share()

    source
      .bind(to: subject)
      .disposed(by: disposeBag)
  
    return source
  }
  
  func observe() -> Observable<T> {
    return subject
      .compactMap { $0 }
      .asObservable()
  }
}
