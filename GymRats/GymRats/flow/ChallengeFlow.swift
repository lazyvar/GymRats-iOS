//
//  ChallengeFlow.swift
//  GymRats
//
//  Created by mack on 3/12/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import MessageUI
import RxSwift

enum ChallengeFlow {
  static private var delegate = TrackMessageDelegate()
  
  static func invite(to challenge: Challenge) {
    let topMost = UIViewController.topmost()
    
    guard MFMessageComposeViewController.canSendText() else {
      topMost.presentAlert(title: "Uh-oh", message: "This device cannot send text message.")
      return
    }
      
    let messageViewController = MFMessageComposeViewController().apply {
      $0.body = "Let's workout together! Join my GymRats challenge using invite code \"\(challenge.code)\" https://apps.apple.com/us/app/gymrats-group-challenge/id1453444814"
      $0.messageComposeDelegate = delegate
    }
    
    topMost.present(messageViewController, animated: true, completion: nil)
  }
  
  static func leave(_ challenge: Challenge) {
    // TODO
  }
  
  static func join(_ onJoin: @escaping (Challenge) -> Void) {
    let disposeBag = DisposeBag()
    let cancelAction = UIAlertAction(title: "Cancel", style: .default)
    let alert = UIAlertController (
      title: "Join Challenge",
      message: "Enter the 6 character challenge code",
      preferredStyle: .alert
    )

    let ok = UIAlertAction(title: "OK", style: .default, handler: { _ in
      let code = alert.textFields?.first?.text ?? ""
      
      gymRatsAPI.joinChallenge(code: code)
        .next { result in
          switch result {
          case .success(let challenge):
            onJoin(challenge)
          case .failure(let error):
            UIViewController.topmost().presentAlert(with: error)
          }
        }
        .disposed(by: disposeBag)
    })

    alert.addTextField { (textField: UITextField!) -> Void in
      textField.placeholder = "Code"
    }
    
    alert.addAction(cancelAction)
    alert.addAction(ok)

    UIViewController.topmost().present(alert, animated: true, completion: nil)
  }
}
