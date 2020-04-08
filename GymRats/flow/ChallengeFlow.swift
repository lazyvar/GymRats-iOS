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
  
  static func join(code: String) {
    UIViewController.topmost().showLoadingBar()
  
    gymRatsAPI.getChallenge(code: code)
      .subscribe(onNext: { result in
        UIViewController.topmost().hideLoadingBar()
        
        switch result {
        case .success(let challenges):
          guard let challenge = challenges.first(where: { $0.code == code }) else { return }
          
          let preview = ChallengePreviewViewController(challenge: challenge)
          let nav = preview.inNav()
          
          preview.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: .close,
            style: .plain,
            target: preview,
            action: #selector(UIViewController.dismissSelf)
          )
          
          UIViewController.topmost().present(nav, animated: true, completion: nil)
        case .failure(let error):
          UIViewController.topmost().presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)
  }
  
  static func join() -> Observable<Challenge> {
    return .create { observer in
      let joinChallengeViewController = JoinChallengeViewController()
      let nav = joinChallengeViewController.inNav()
      
      joinChallengeViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
        image: .close,
        style: .plain,
        target: joinChallengeViewController,
        action: #selector(UIViewController.dismissSelf)
      )
      
      UIViewController.topmost().present(nav, animated: true, completion: nil)

      return NotificationCenter.default.rx.notification(.joinedChallenge)
        .subscribe { event in
          switch event {
          case .next(let notification):
            guard let challenge = notification.object as? Challenge else { return }
            
            observer.onNext(challenge)
          case .error(let error):
            observer.onError(error)
          case .completed:
            observer.onCompleted()
          }
        }
    }
  }
}
