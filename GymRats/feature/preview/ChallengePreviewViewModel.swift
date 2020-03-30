//
//  ChallengePreviewViewModel.swift
//  GymRats
//
//  Created by mack on 3/28/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class ChallengePreviewViewModel: ViewModel {
  private let disposeBag = DisposeBag()
  private var code: String!
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
  }
  
  struct Output {
    let challenge = PublishSubject<Challenge>()
  }
  
  let input = Input()
  let output = Output()
  
  func configure(code: String) {
    self.code = code
  }
  
  init() {
    input.viewDidLoad
      .flatMap { gymRatsAPI.getChallenge(code: self.code) }
      .compactMap { $0.object?.first }
      .bind(to: output.challenge)
      .disposed(by: disposeBag)
  }
}
