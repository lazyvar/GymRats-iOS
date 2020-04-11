//
//  HowItWorksViewController.swift
//  GymRats
//
//  Created by mack on 4/7/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class HowItWorksViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let code: String? = UserDefaults.standard.string(forKey: "join-code")
  
  @IBOutlet private weak var content: UILabel! {
    didSet {
      content.textColor = .primaryText
      content.font = .body
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "How it works"
    view.backgroundColor = .background
    
    setupBackButton()
  }
  
  @IBAction func gotIt(_ sender: Any) {
    if let code = code {
      showLoadingBar()
      
      gymRatsAPI.getChallenge(code: code)
        .subscribe(onNext: { [weak self] result in
          self?.hideLoadingBar()
          
          switch result {
          case .success(let challenges):
            guard let challenge = challenges.first(where: { $0.code == code }) else { return }

            self?.push(
              ChallengePreviewViewController(challenge: challenge)
            )
          case .failure:
            self?.push(
              TodaysGoalViewController()
            )
          }
        })
      .disposed(by: disposeBag)
    } else {
      push(
        TodaysGoalViewController()
      )
    }
  }
}
