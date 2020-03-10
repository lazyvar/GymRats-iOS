//
//  NoChallengesViewController.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class NoChallengesViewController: BindableViewController {
  
  let viewModel = NoChallengesViewModel()
  
  override func bindViewModel() {
    // ...
  }

  @IBAction private func tappedJoinButton(_ sender: Any) {
    viewModel.input.tappedJoinChallenge.trigger()
  }
  
  @IBAction private func tappedStartButton(_ sender: Any) {
    viewModel.input.tappedStartChallenge.trigger()
  }
}
