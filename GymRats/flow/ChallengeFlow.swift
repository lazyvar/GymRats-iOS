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
  static private let disposeBag = DisposeBag()
  
  static func invite(to challenge: Challenge) {
    let activityViewController = UIActivityViewController(
      activityItems: ["""
      Let's workout together! Join \(challenge.name) using code \(challenge.code). https://apps.apple.com/us/app/gymrats-group-challenge/id1453444814
      """],
      applicationActivities: nil
    )
    
    UIViewController.topmost().present(activityViewController, animated: true, completion: nil)
  }
  
  static func leave(_ challenge: Challenge) {
    let alert = UIAlertController(title: "Are you sure you want to leave \(challenge.name)?", message: nil, preferredStyle: .alert)
    let leave = UIAlertAction(title: "Leave", style: .destructive) { _ in
      gymRatsAPI.leaveChallenge(challenge)
        .next { result in
          switch result {
          case .success:
            NotificationCenter.default.post(name: .leftChallenge, object: challenge)
          case .failure(let error):
            UIViewController.topmost().presentAlert(with: error)
          }
        }
        .disposed(by: disposeBag)
    }

    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      
    alert.addAction(leave)
    alert.addAction(cancel)
      
    UIViewController.topmost().present(alert, animated: true, completion: nil)
  }
  
  static func join() -> Observable<Challenge> {
    return .create { observer in
      let disposeBag = DisposeBag()
      let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
        observer.onCompleted()
      }
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
              observer.on(.next(challenge))
              Challenge.State.all.fetch().ignore(disposedBy: disposeBag)
            case .failure(let error):
              UIViewController.topmost().presentAlert(with: error)
            }
            
            observer.onCompleted()
          }
          .disposed(by: disposeBag)
      })

      alert.addTextField { (textField: UITextField!) -> Void in
        textField.placeholder = "Code"
      }
      
      alert.addAction(cancelAction)
      alert.addAction(ok)

      UIViewController.topmost().present(alert, animated: true, completion: nil)

      return Disposables.create()
    }
  }
}
