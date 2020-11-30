//
//  HealthAppViewModel.swift
//  GymRats
//
//  Created by mack on 11/29/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import HealthKit
import RxSwift

final class HealthAppViewModel: ViewModel {
  private let disposeBag = DisposeBag()
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let grantPermissionTapped = PublishSubject<Void>()
    let healthSettingsTapped = PublishSubject<Void>()
    let autoSyncSwitchChanged = PublishSubject<Bool>()
  }
  
  struct Output {
    let grantPermissionButtonIsHidden = PublishSubject<Bool>()
    let healthSettingsButtonIsHidden = PublishSubject<Bool>()
    let openHealthApp = PublishSubject<Void>()
    let autoSyncEnabled = PublishSubject<Bool>()
  }
  
  let input = Input()
  let output = Output()
  
  private let healthService: HealthServiceType
  
  init(healthService: HealthServiceType = HealthService.shared) {
    self.healthService = healthService
    
    input.viewDidLoad
      .map { return healthService.autoSyncEnabled }
      .bind(to: output.autoSyncEnabled)
      .disposed(by: disposeBag)
  
    let requestedPermission =
      input.viewDidLoad
      .flatMap { healthService.didRequestWorkoutAuthorization() }
      .share()
    
    requestedPermission
      .bind(to: output.grantPermissionButtonIsHidden)
      .disposed(by: disposeBag)

    requestedPermission
      .map { !$0 }
      .bind(to: output.healthSettingsButtonIsHidden)
      .disposed(by: disposeBag)

    input.grantPermissionTapped
      .flatMap { healthService.requestWorkoutAuthorization() }
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { [self] _ in
        output.grantPermissionButtonIsHidden.on(.next(true))
        output.healthSettingsButtonIsHidden.on(.next(false))
      })
      .disposed(by: disposeBag)
    
    input.healthSettingsTapped.map { _ in () }
      .bind(to: output.openHealthApp)
      .disposed(by: disposeBag)
    
    input.autoSyncSwitchChanged
      .flatMap { isOn in
        return Observable.zip(Observable<Bool>.just(isOn), healthService.requestWorkoutAuthorization().asObservable())
      }
      .subscribe(onNext: { isOn, _ in
        healthService.autoSyncEnabled = isOn
      })
      .disposed(by: disposeBag)
    }
}
