//
//  ChallengeViewModel.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ChallengeViewModel: ViewModel {
  
  private let disposeBag = DisposeBag()
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
  }
  
  struct Output {
    let error = PublishSubject<Error>()
    let pushScreen = PublishSubject<Screen>()
  }
  
  let input = Input()
  let output = Output()
  
  init() {
    
  }
}
