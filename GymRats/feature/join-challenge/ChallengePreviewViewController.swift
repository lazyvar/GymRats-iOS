//
//  ChallengePreviewViewController.swift
//  GymRats
//
//  Created by mack on 3/28/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class ChallengePreviewViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let challenge: Challenge
  
  @IBOutlet weak var bannerImageView: UIImageView! {
    didSet {
      if let url = challenge.profilePictureUrl, let resource = URL(string: url) {
        bannerImageView.kf.setImage(with: resource)
      }
    }
  }
  
  @IBOutlet weak var calendarImageView: UIImageView! {
    didSet { calendarImageView.tintColor = .primaryText }
  }
  
  @IBOutlet weak var clockImageView: UIImageView! {
    didSet { clockImageView.tintColor = .primaryText }
  }

  @IBOutlet weak var startDateLabel: UILabel! {
    didSet {
      startDateLabel.text = "Starts "
      startDateLabel.font = .body
      startDateLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet weak var durationLabel: UILabel! {
    didSet {
      durationLabel.text = "Lasts "
      durationLabel.font = .body
      durationLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var bgView: UIView! {
    didSet {
      bgView.backgroundColor = .foreground
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

    title = challenge.name
    view.backgroundColor = .background
  }
  
  @IBAction private func accept(_ sender: Any) {
    showLoadingBar()
    
    gymRatsAPI.joinChallenge(code: challenge.code)
      .subscribe(onNext: { [weak self] result in
        self?.hideLoadingBar()
        
        switch result {
        case .success(let challenge):
          // TODO
          Challenge.State.all.fetch().ignore(disposedBy: self?.disposeBag ?? DisposeBag())
        case .failure(let error):
          self?.presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)
  }
}
