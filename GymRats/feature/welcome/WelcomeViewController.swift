//
//  WelcomeViewController.swift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class WelcomeViewController: BindableViewController {
  private let viewModel = WelcomeViewModel()
  private let disposeBag = DisposeBag()

  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      let welcome = NSMutableAttributedString(string: "Welcome to ")
      welcome.append(NSAttributedString(string: "GymRats", attributes: [
        NSMutableAttributedString.Key.font: UIFont.h1Bold
      ]))

      titleLabel.font = .h1
      titleLabel.textColor = .primaryText
      titleLabel.attributedText = welcome
    }
  }

  @IBOutlet private weak var imageView: UIImageView! {
    didSet {
      imageView.layer.cornerRadius = 4
      imageView.clipsToBounds = true
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  
    navigationItem.largeTitleDisplayMode = .never
  }

  override func bindViewModel() {
    viewModel.output.navigation
      .subscribe(onNext: { [weak self] (navigation, screen) in
        self?.navigate(navigation, to: screen.viewController)
      })
      .disposed(by: disposeBag)
  }

  @IBAction private func loginButtonTapped(_ sender: Any) {
    viewModel.input.tappedLogIn.trigger()
  }

  @IBAction private func getStartedButtonTapped(_ sender: Any) {
    viewModel.input.tappedGetStarted.trigger()
  }
}
