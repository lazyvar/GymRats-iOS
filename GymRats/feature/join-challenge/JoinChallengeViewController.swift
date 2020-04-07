//
//  JoinChallengeViewController.swift
//  GymRats
//
//  Created by mack on 4/7/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class JoinChallengeViewController: UIViewController {
  private let disposeBag = DisposeBag()
  
  @IBOutlet private weak var content: UILabel! {
    didSet {
      content.textColor = .primaryText
      content.font = .body
    }
  }
  
  @IBOutlet private weak var codeTextField: UITextField! {
    didSet {
      codeTextField.font = .h4
      codeTextField.keyboardType = .asciiCapable
      codeTextField.autocorrectionType = .no
      codeTextField.inputAccessoryView = keyboardToolbar
    }
  }
  
  private lazy var joinButton = UIBarButtonItem(
    // father forgive me for I have sinned
    title: "                         Join                         ",
    style: .plain,
    target: self,
    action: #selector(join)
  ).apply {
    $0.tintColor = .white
  }

  private let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
  
  private lazy var keyboardToolbar = UIToolbar().apply {
    $0.sizeToFit()
    $0.isTranslucent = false
    $0.barTintColor = .brand
    $0.items = [space, joinButton, space]
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    codeTextField.becomeFirstResponder()
    view.backgroundColor = .background
    title = "Join challenge"
    
    setupBackButton()
    
    codeTextField.rx.text
      .map { $0 ?? "" }
      .map { $0.isNotEmpty }
      .bind(to: joinButton.rx.isEnabled)
      .disposed(by: disposeBag)
  }
  
  @objc private func join() {
    showLoadingBar()
    
    gymRatsAPI.getChallenge(code: codeTextField.text ?? "")
      .subscribe(onNext: { [weak self] result in
        self?.hideLoadingBar()
        
        switch result {
        case .success(let challenges):
          guard let challenge = challenges.first else { return }
          
          self?.push(
            ChallengePreviewViewController(challenge: challenge)
          )
        case .failure(let error):
          self?.presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)
  }
}
