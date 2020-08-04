//
//  ShareChallengeViewController.swift
//  GymRats
//
//  Created by mack on 8/3/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import NVActivityIndicatorView
import Kingfisher

class ShareChallengeViewController: UIViewController {
  private let challenge: Challenge
  private let disposeBag = DisposeBag()
  private var allWorkouts: [Workout] = []
  private var selectedWorkouts: [Workout] = [] {
    didSet {
      fetchSelectedWorkouts()
    }
  }
  
  @IBOutlet private weak var preview: UIView! {
    didSet {
      preview.layer.cornerRadius = 4
      preview.clipsToBounds = true
    }
  }

  @IBOutlet private weak var previewImageView: UIImageView!

  private var shareChallengeView: ShareChallengeView!
  
  @IBOutlet private weak var loadingBackground: UIView! {
    didSet {
      loadingBackground.backgroundColor = .asbestos
      loadingBackground.isSkeletonable = true
      loadingBackground.showAnimatedSkeleton()
      
      let spinner = NVActivityIndicatorView(frame: .init(x: 0, y: 0, width: 100, height: 100), type: .ballPulseSync, color: .brand, padding: 20)
      spinner.translatesAutoresizingMaskIntoConstraints = false
      spinner.startAnimating()
      
      loadingBackground.addSubview(spinner)
      
      spinner.center(in: loadingBackground)
      spinner.constrainWidth(100)
      spinner.constrainHeight(100)
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
    
    shareChallengeView = ShareChallengeView(frame: CGRect(x: 1000, y: 1000, width: 600, height: 600))
    shareChallengeView.challenge = challenge
    
    navigationItem.largeTitleDisplayMode = .never
    view.backgroundColor = .background
    view.addSubview(shareChallengeView)
    
    Observable.combineLatest(gymRatsAPI.getAllWorkouts(for: challenge), gymRatsAPI.challengeInfo(challenge))
      .subscribe(onNext: { [weak self] a, b in
        guard let self = self else { return }
        guard let workouts = a.object, let challengeInfo = b.object else { self.presentAlert(with: (a.error ?? b.error)!); return }

        self.shareChallengeView.size = {
          if workouts.count >= 16 {
            return .sixteen
          } else if workouts.count >= 9 {
            return .nine
          } else {
            return .four
          }
        }()
        
        self.shareChallengeView.memberCount = challengeInfo.memberCount
        self.shareChallengeView.score = "\(workouts.count) workouts"
        self.shareChallengeView.days = self.challenge.days.count
        self.allWorkouts = workouts
        self.selectedWorkouts = Array(self.allWorkouts.shuffled().prefix(self.shareChallengeView.size.rawValue))
      })
      .disposed(by: disposeBag)
  }

  private func fetchSelectedWorkouts() {
    UIView.animate(withDuration: 0.1) {
      self.loadingBackground.alpha = 1
    }

    Observable.merge(self.selectedWorkouts.map { self.fetchImage(from: $0) })
      .toArray()
      .subscribe(onSuccess: { [weak self] images in
        guard let self = self else { return }
        
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          
          self.shareChallengeView.workoutImages = images.compactMap { $0 }

          DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            UIView.animate(withDuration: 0.1) {
              self.loadingBackground.alpha = 0
              self.previewImageView.image = self.shareChallengeView.imageFromContext()
            }
          }
        }
      }, onError: { _ in
        // ...
      })
      .disposed(by: self.disposeBag)
  }
  
  func fetchImage(from workout: Workout) -> Observable<UIImage?> {
    return Observable.create { subscriber -> Disposable in
      DispatchQueue.global().async {
        guard let photoUrl = workout.photoUrl, let url = URL(string: photoUrl) else {
          subscriber.on(.next(nil))
          subscriber.onCompleted()
          
          return
        }
        
        KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { image, _, _, _ in
          subscriber.on(.next(image))
          subscriber.onCompleted()
        }
      }
      
      return Disposables.create()
    }
  }
  
  @IBAction private func share(_ sender: Any) {
    let previewImage = shareChallengeView.imageFromContext()
    let activityViewController = UIActivityViewController(activityItems: [previewImage as Any], applicationActivities: nil)
    
    present(activityViewController, animated: true)
  }
}
