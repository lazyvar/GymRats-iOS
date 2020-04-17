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
  
  @IBOutlet private weak var label: UILabel! {
    didSet {
      label.font = .h4
      label.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var textView: UITextView! {
    didSet {
      textView.font = .h4
      textView.textColor = .primaryText
      textView.backgroundColor = .foreground
      textView.layer.cornerRadius = 4
      textView.clipsToBounds = true
      textView.isEditable = false
      textView.contentInset = .init(top: 5, left: 0, bottom: 0, right: 0)
    }
  }
  
  private let challenge: Challenge
  
  init(challenge: Challenge) {
    self.challenge = challenge
    
    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .background
    title = "Invite"
    navigationController?.presentationController?.delegate = self
    
    textView.text = challenge.code
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

    if presentingViewController != nil {
      dismissSelf()
    } else {
      GymRats.completeOnboarding()
    }
  }
}

extension InviteToChallengeViewController: UIAdaptivePresentationControllerDelegate {
  func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
    Challenge.State.all.fetch().ignore(disposedBy: disposeBag)
    NotificationCenter.default.post(name: .joinedChallenge, object: challenge)
  }
}
