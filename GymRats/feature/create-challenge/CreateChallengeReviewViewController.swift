//
//  CreateChallengerReviewViewController.swift
//  GymRats
//
//  Created by mack on 4/14/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class CreateChallengeReviewViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let newChallenge: NewChallenge
  
  init(newChallenge: NewChallenge) {
    self.newChallenge = newChallenge
    
    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @IBOutlet private weak var bannerImageView: UIImageView! {
    didSet {
      bannerImageView.contentMode = .scaleAspectFill
      bannerImageView.layer.cornerRadius = 4
      bannerImageView.clipsToBounds = true
      bannerImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

      if let image = newChallenge.banner?.left {
        bannerImageView.image = image
      } else if let url = newChallenge.banner?.right, let resource = URL(string: url) {
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
          if newChallenge.startDate.serverDateIsToday {
            return "today"
          } else if newChallenge.startDate.serverDateIsYesterday {
            return "yesterday"
          } else if newChallenge.startDate.serverDateIsTomorrow {
            return "tomorrow"
          } else {
            return newChallenge.startDate.in(region: .UTC).toFormat("MMMM d")
          }
        }()
        
        return "Starts \(date)"
      }()
    }
  }
  
  @IBOutlet private weak var durationLabel: UILabel! {
    didSet {
      durationLabel.text = "Spans \(newChallenge.days) days"
      durationLabel.font = .body
      durationLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint! {
    didSet {
      if newChallenge.banner?.left == nil && newChallenge.banner?.right == nil {
        imageViewHeightConstraint.constant = 0
      }
    }
  }

  @IBOutlet private weak var scoreByLabel: UILabel! {
    didSet {
      scoreByLabel.font = .body
      scoreByLabel.textColor = .primaryText
      scoreByLabel.text = "Scored by most \(newChallenge.scoreBy.display.lowercased())"
    }
  }
  
  @IBOutlet private weak var descriptionLabel: SmartLabel! {
    didSet {
      descriptionLabel.text = newChallenge.description
    }
  }
  
  @IBOutlet private weak var lastDivider: UIStackView! {
    didSet {
      lastDivider.isHidden = newChallenge.description == nil || newChallenge.description == ""
    }
  }

  @IBOutlet private weak var descriptionStackView: UIStackView! {
    didSet {
      descriptionStackView.isHidden = newChallenge.description == nil || newChallenge.description == ""
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupBackButton()
    view.backgroundColor = .background
    title = newChallenge.name
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  
    Track.screen(.createChallengeReview)
  }
  
  @IBAction private func startTapped(_ sender: UIButton) {
    showLoadingBar()

    sender.isEnabled = false

    gymRatsAPI.createChallenge(newChallenge)
      .subscribe(onNext: { [weak self] result in
        sender.isEnabled = true

        guard let self = self else { return }
                
        switch result {
        case .success(let challenge):
          Track.event(.challengeCreated)

          if let team = self.newChallenge.firstTeam {
            gymRatsAPI
              .createTeam(challenge: challenge, name: team.name, photo: team.photo)
              .subscribe(onNext: { result in
                self.hideLoadingBar()
                self.navigationController?.setViewControllers([InviteToChallengeViewController(challenge: challenge)], animated: true)
              })
              .disposed(by: self.disposeBag)
          } else {
            self.hideLoadingBar()
            self.navigationController?.setViewControllers([InviteToChallengeViewController(challenge: challenge)], animated: true)
          }
        case .failure(let error):
          self.presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)
  }
}
