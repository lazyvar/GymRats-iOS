//
//  ImportWorkoutViewModel.swift
//  GymRats
//
//  Created by mack on 5/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import HealthKit
import RxSwift

final class ImportWorkoutViewModel: ViewModel {
  private let disposeBag = DisposeBag()
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let tappedRow = PublishSubject<IndexPath>()
    let submittedComment = PublishSubject<String>()
    let tappedDeleteComment = PublishSubject<Comment>()
  }
  
  struct Output {
    let sections = PublishSubject<[ImportWorkoutSection]>()
    let error = PublishSubject<Error>()
    
  }
  
  let input = Input()
  let output = Output()
  
  init() {
    
  }
}
