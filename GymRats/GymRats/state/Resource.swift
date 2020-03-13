//
//  Resource.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

struct Resource<T> {
  let resource = BehaviorSubject<T?>(value: nil)
  
  private let source: () -> Observable<T>
  private let disposeBag = DisposeBag()
  
  init(source: @escaping () -> Observable<T>) {
    self.source = source
  }
  
  @discardableResult func fetch() -> Observable<T> {
    let source = self.source()
      
    source
      .bind(to: resource)
      .disposed(by: disposeBag)
    
    return source
  }
}
