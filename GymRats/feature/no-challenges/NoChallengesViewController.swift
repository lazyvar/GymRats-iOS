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
  private let viewModel = NoChallengesViewModel()
  private let disposeBag = DisposeBag()
  
  @IBOutlet private weak var headerLabel: UILabel! {
    didSet {
      headerLabel.font = .h4
      headerLabel.textColor = .primaryText
    }
  }
  
  override func bindViewModel() {
    viewModel.output.navigation
      .subscribe(onNext: { [weak self] (navigation, screen) in
        self?.navigate(navigation, to: screen.viewController)
      })
      .disposed(by: disposeBag)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupMenuButton()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  
    Track.screen(.noChallenges)
  }
  
  @IBAction private func tappedJoinButton(_ sender: Any) {
    viewModel.input.tappedJoinChallenge.trigger()
  }
  
  @IBAction private func tappedStartButton(_ sender: Any) {
    viewModel.input.tappedStartChallenge.trigger()
  }
}
