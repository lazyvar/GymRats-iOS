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
  static private let disposeBag = DisposeBag()
  
  static func invite(to challenge: Challenge) {
    let activityViewController = UIActivityViewController(
      activityItems: ["""
      Ready for a challenge? Join me in "\(challenge.name)" https://share.gymrats.app/join?code=\(challenge.code)
      """],
      applicationActivities: nil
    )
    
    activityViewController.completionWithItemsHandler = { activity, completed, thing, error in
      guard error == nil else { return }
      guard let activity = activity else { return }
      
      Track.event(.invitedToChallenge, properties: ["activity_type": activity.rawValue])
    }
    
    UIViewController.topmost().present(activityViewController, animated: true, completion: nil)
  }
  
  static func leave(_ challenge: Challenge) {
    let alert = UIAlertController(title: "Are you sure you want to leave \(challenge.name)?", message: nil, preferredStyle: .alert)
    let leave = UIAlertAction(title: "Leave", style: .destructive) { _ in
      UIViewController.topmost().showLoadingBar()
      
      gymRatsAPI.leaveChallenge(challenge)
        .next { result in
          UIViewController.topmost().hideLoadingBar()
          
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
    let topmost = UIViewController.topmost()

    topmost.showLoadingBar()
  
    gymRatsAPI.getChallenge(code: code)
      .subscribe(onNext: { result in
        topmost.hideLoadingBar()
        
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

          topmost.present(nav, animated: true, completion: nil)
        case .failure(let error):
          topmost.presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)
  }
  
  static func join() -> Observable<Challenge> {
    return .create { observer in
      let joinChallengeViewController = JoinChallengeViewController()
      let nav = joinChallengeViewController.inNav()
      let topmost = UIViewController.topmost()
      let drawer = topmost.mm_drawerController
      
      if drawer?.openSide == .left {
        drawer?.closeDrawer(animated: true, completion: nil)
      }

      joinChallengeViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
        image: .close,
        style: .plain,
        target: joinChallengeViewController,
        action: #selector(UIViewController.dismissSelf)
      )
      
      topmost.present(nav, animated: true, completion: nil)

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
  
  static func present(completedChallenge: Challenge) {
    let completedViewController = CompletedChallengeViewController(challenge: completedChallenge)
    completedViewController.popUp = true
    completedViewController.itIsAParty = true
    
    let nav = GymRatsNavigationController(rootViewController: completedViewController)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      let topmost = UIViewController.topmost()

      topmost.present(nav, animated: true, completion: nil)
    }
  }
}
