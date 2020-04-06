//
//  WelcomeViewModel.swift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class WelcomeViewModel: ViewModel {
  
  private let disposeBag = DisposeBag()
  
  struct Input {
    let tappedLogIn = PublishSubject<Void>()
    let tappedGetStarted = PublishSubject<Void>()
  }

  struct Output {
    let navigation = PublishSubject<(Navigation, Screen)>()
  }

  let input = Input()
  let output = Output()
  
  init() {
    input.tappedLogIn
      .map { _ -> (Navigation, Screen) in (.push(animated: true), .login) }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)

    input.tappedGetStarted
      .map { _ -> (Navigation, Screen) in (.push(animated: true), .getStarted) }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)
  }
}
