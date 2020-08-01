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
  
  @IBOutlet private weak var bannerImageView: UIImageView! {
    didSet {
      bannerImageView.contentMode = .scaleAspectFill
      
      if let url = challenge.profilePictureUrl, let resource = URL(string: url) {
        bannerImageView.kf.setImage(with: resource)
      }
    }
  }
  
  @IBOutlet private weak var calendarImageView: UIImageView! {
    didSet { calendarImageView.tintColor = .primaryText }
  }
  
  @IBOutlet private weak var clockImageView: UIImageView! {
    didSet { clockImageView.tintColor = .primaryText }
  }

  @IBOutlet private weak var starImageView: UIImageView! {
    didSet { starImageView.tintColor = .primaryText }
  }
  
  @IBOutlet private weak var clipboardImageView: UIImageView! {
    didSet { clipboardImageView.tintColor = .primaryText }
  }

  @IBOutlet private weak var startDateLabel: UILabel! {
    didSet {
      startDateLabel.font = .body
      startDateLabel.textColor = .primaryText
      startDateLabel.text = {
        let date: String = {
          if challenge.startDate.isToday {
            return "today"
          } else if challenge.startDate.isYesterday {
            return "yesterday"
          } else if challenge.startDate.isTomorrow {
            return "tomorrow"
          } else {
            return challenge.startDate.toFormat("MMMM d")
          }
        }()
        
        if challenge.isPast {
          return "Started \(date)"
        } else if challenge.isActive {
          return "Started \(date)"
        } else {
          return "Starts \(date)"
        }
      }()
    }
  }
  
  @IBOutlet private weak var durationLabel: UILabel! {
    didSet {
      durationLabel.text = "Lasts \(challenge.days.count) days"
      durationLabel.font = .body
      durationLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var scoreByLabel: UILabel! {
    didSet {
      scoreByLabel.font = .body
      scoreByLabel.textColor = .primaryText
      scoreByLabel.text = "Scored by most \(challenge.scoreBy.display.lowercased())"
    }
  }
  
  @IBOutlet private weak var lastDivider: UIStackView! {
    didSet {
      lastDivider.isHidden = challenge.description == nil || challenge.description == ""
    }
  }
  
  @IBOutlet private weak var descriptionLabel: UILabel! {
    didSet {
      descriptionLabel.text = challenge.description
      descriptionLabel.textColor = .primaryText
      descriptionLabel.font = .body
    }
  }
  
  @IBOutlet private weak var descriptionStackView: UIStackView! {
    didSet {
      descriptionStackView.isHidden = challenge.description == nil || challenge.description == ""
    }
  }
  
  @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint! {
    didSet {
      if challenge.profilePictureUrl == nil {
        imageViewHeightConstraint.constant = 0
      }
    }
  }
  
  @IBOutlet private weak var bgView: UIView! {
    didSet {
      bgView.clipsToBounds = true
      bgView.layer.cornerRadius = 4
      bgView.backgroundColor = .foreground
    }
  }
  
  private var shadowLayer: CAShapeLayer!
  
  private lazy var shadowView = UIView().apply {
    $0.backgroundColor = .clear
    $0.translatesAutoresizingMaskIntoConstraints = false
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
    view.addSubview(shadowView)
    view.sendSubviewToBack(shadowView)
    setupBackButton()
    
    shadowView.leftAnchor.constraint(equalTo: bgView.leftAnchor).isActive = true
    shadowView.rightAnchor.constraint(equalTo: bgView.rightAnchor).isActive = true
    shadowView.topAnchor.constraint(equalTo: bgView.topAnchor).isActive = true
    shadowView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor).isActive = true
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
      self.shadowLayer = CAShapeLayer().apply { shadowLayer in
        shadowLayer.path = UIBezierPath(roundedRect: self.bgView.bounds, cornerRadius: 4).cgPath
        shadowLayer.fillColor = UIColor.foreground.cgColor
        shadowLayer.shadowColor = UIColor.shadow.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowRadius = 2
      }
      
      self.shadowView.layer.insertSublayer(self.shadowLayer, at: 0)
    }
  }
  
  @IBAction private func accept(_ sender: Any) {
    showLoadingBar()
    
    gymRatsAPI.joinChallenge(code: challenge.code)
      .subscribe(onNext: { [weak self] result in
        self?.hideLoadingBar()
        
        switch result {
        case .success(let challenge):
          Challenge.State.join(challenge)
          
          if let self = self { Challenge.State.all.fetch().ignore(disposedBy: self.disposeBag) }
          
          NotificationCenter.default.post(name: .joinedChallenge, object: challenge)
          
          if UserDefaults.standard.bool(forKey: "account-is-onboarding") {
            GymRats.completeOnboarding()
          } else {
            self?.dismissSelf()
          }
        case .failure(let error):
          self?.presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)
  }
}
