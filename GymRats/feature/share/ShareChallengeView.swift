//
//  ShareChallengeView.swift
//  GymRats
//
//  Created by mack on 8/3/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class ShareChallengeView: UIView {
  private var tintLayer: CAGradientLayer!

  enum Size: Int {
    case four = 4
    case nine = 9
    
    var side: CGFloat {
      switch self {
      case .four: return 2
      case .nine: return 3
      }
    }
  }
  
  var size: Size = .nine
  var challenge: Challenge? {
    didSet {
      challengeNameLabel?.text = challenge?.name
    }
  }
  
  var workouts: [Workout] = [] {
    didSet {
      collectionView.reloadData()
    }
  }
  
  var memberCount: Int = 0 {
    didSet {
      membersLabel.text = "\(memberCount) members"
    }
  }
  
  var days: Int = 0 {
    didSet {
      durationLabel.text = "\(days) days"
    }
  }
  
  var score: String = "" {
    didSet {
      scoreLabel.text = score
    }
  }
  
  @IBOutlet private weak var collectionView: UICollectionView! {
    didSet {
      collectionView.delegate = self
      collectionView.dataSource = self
      collectionView.registerCellNibForClass(WorkoutImageCell.self)
    }
  }
  
  @IBOutlet private weak var tintedView: UIView!
  
  @IBOutlet private weak var gymRatsAppLabel: UILabel! {
    didSet {
      gymRatsAppLabel.font = .title
    }
  }
  
  @IBOutlet private weak var gymRatsAppIcon: UIImageView! {
    didSet {
      gymRatsAppIcon.clipsToBounds = true
      gymRatsAppIcon.layer.cornerRadius = 4
    }
  }
  
  @IBOutlet private weak var challengeNameLabel: UILabel! {
    didSet {
      challengeNameLabel.font = .proRoundedBlack(size: 28)
    }
  }
  
  @IBOutlet private weak var scoreLabel: UILabel! {
    didSet {
      scoreLabel.font = .proRoundedSemibold(size: 20)
    }
  }
  
  @IBOutlet weak var durationLabel: UILabel! {
    didSet {
      durationLabel.font = .proRoundedSemibold(size: 20)
    }
  }
  
  @IBOutlet private weak var membersLabel: UILabel! {
    didSet {
      membersLabel.font = .proRoundedSemibold(size: 20)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    setup()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    
    if tintLayer == nil {
      tintLayer = CAGradientLayer().apply { gradientLayer in
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.hex("#000000", alpha: 65).cgColor, UIColor.clear.cgColor, UIColor.hex("#000000", alpha: 65).cgColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
      }
      
      tintedView.layer.insertSublayer(tintLayer, at: 0)
      
      addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
    }
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "bounds" {
      tintLayer.bounds = bounds
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  private func setup() {
    loadNib().inflate(in: self)
  }
}

extension ShareChallengeView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return size.rawValue
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return WorkoutImageCell.configure(collectionView: collectionView, indexPath: indexPath, workoutPhotoURL: workouts[safe: indexPath.row]?.photoUrl)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let side: CGFloat = frame.width / size.side
    
    return CGSize(width: side, height: side)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return .zero
  }
}
