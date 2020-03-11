//
//  NoChallengesViewController.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class NoChallengesViewController: BindableViewController {
  
  let viewModel = NoChallengesViewModel()
  
  private let disposeBag = DisposeBag()
  
  override func bindViewModel() {
    viewModel.output.presentScreen
      .next { [weak self] screen in
        self?.present(screen.viewController)
      }
      .disposed(by: disposeBag)
  }

  @IBAction private func tappedJoinButton(_ sender: Any) {
    viewModel.input.tappedJoinChallenge.trigger()
  }
  
  @IBAction private func tappedStartButton(_ sender: Any) {
    viewModel.input.tappedStartChallenge.trigger()
  }
}
