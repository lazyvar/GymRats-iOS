//
//  HomeViewModel.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel: ViewModel {
  
  private let disposeBag = DisposeBag()
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
  }
  
  struct Output {
    let message = PublishSubject<String>()
  }
  
  let input = Input()
  let output = Output()
  
  init() {
    // ...
    
    input.viewDidLoad
      .map { "Hi!" }
      .bind(to: output.message)
      .disposed(by: disposeBag)
  }
}
