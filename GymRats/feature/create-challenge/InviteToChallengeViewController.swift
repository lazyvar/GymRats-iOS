//
//  InviteToChallengeViewController.swift
//  GymRats
//
//  Created by mack on 4/16/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class InviteToChallengeViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let challenge: Challenge

  @IBOutlet private weak var label: UILabel! {
    didSet {
      label.font = .h4
      label.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var textField: NoTouchingTextField! {
    didSet {
      textField.font = .proRoundedRegular(size: 12)
      textField.textColor = .primaryText
      textField.backgroundColor = .foreground
      textField.layer.cornerRadius = 4
      textField.clipsToBounds = true
      textField.text = "https://share.gmyrats.app/join?code=\(challenge.code)"
    }
  }
  
  init(challenge: Challenge) {
    self.challenge = challenge
    
    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let press = UILongPressGestureRecognizer(target: self, action: #selector(pressed))
    press.minimumPressDuration = 0.001
    
    let copyLabel = UILabel()
    copyLabel.text = "COPY"
    copyLabel.font = .detailsBold
    copyLabel.textColor = .brand
    copyLabel.isUserInteractionEnabled = false

    textField.rightViewMode = .always
    textField.rightView = copyLabel
    textField.addGestureRecognizer(press)

    view.backgroundColor = .background
    title = "Invite"
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: .close, style: .plain, target: self, action: #selector(self.continue(_:)))
    navigationController?.presentationController?.delegate = self
    setupBackButton()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  
    Track.screen(.inviteToChallenge)
  }
  
  @objc private func pressed(gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .began:
      textField.backgroundColor = UIColor.foreground.darker
    case .cancelled, .ended, .failed:
      textField.backgroundColor = UIColor.foreground
      UIPasteboard.general.string = textField.text
      presentPanModal(CopiedText())
    default:
      break
    }
  }
  
  @IBAction private func shareCode(_ sender: Any) {
    ChallengeFlow.invite(to: challenge)
  }
  
  @IBAction private func `continue`(_ sender: Any) {
    Challenge.State.all.fetch().ignore(disposedBy: disposeBag)

    NotificationCenter.default.post(name: .joinedChallenge, object: challenge)
    
    if UserDefaults.standard.bool(forKey: "account-is-onboarding") {
      GymRats.completeOnboarding()
    } else {
      dismissSelf()
    }
  }
}

extension InviteToChallengeViewController: UIAdaptivePresentationControllerDelegate {
  func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
    Challenge.State.all.fetch().ignore(disposedBy: disposeBag)
    NotificationCenter.default.post(name: .joinedChallenge, object: challenge)
  }
}
