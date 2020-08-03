//
//  ShareChallengeViewController.swift
//  GymRats
//
//  Created by mack on 8/3/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class ShareChallengeViewController: UIViewController {
  private let challenge: Challenge
  private let disposeBag = DisposeBag()
  
  @IBOutlet private weak var preview: UIView! {
    didSet {
      preview.layer.cornerRadius = 4
      preview.clipsToBounds = true
    }
  }

  private var shareChallengeView: ShareChallengeView!
  
  init(challenge: Challenge) {
    self.challenge = challenge
    
    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Share challenge"
    setupMenuButton()
    
    shareChallengeView = ShareChallengeView(frame: CGRect(x: 1000, y: 1000, width: 600, height: 600))
    shareChallengeView.challenge = challenge
    shareChallengeView.size = .four
    
    view.addSubview(shareChallengeView)
    
    gymRatsAPI.getAllWorkouts(for: challenge).subscribe(onNext: { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case .success(let workouts):
        self.shareChallengeView.workouts = workouts
        
        let previewImage = self.shareChallengeView.imageFromContext()
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.inflate(in: self.preview)
        imageView.image = previewImage
        
        DispatchQueue.main.async {
          let previewImage = self.shareChallengeView.imageFromContext()
          
          let imageView = UIImageView()
          imageView.contentMode = .scaleAspectFill
          imageView.inflate(in: self.preview)
          imageView.image = previewImage
        }
      case .failure(let error):
        self.presentAlert(with: error)
      }
    })
    .disposed(by: disposeBag)
  }
}
