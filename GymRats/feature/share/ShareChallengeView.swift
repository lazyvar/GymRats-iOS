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

  enum Size: Int, CaseIterable {
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    
    var total: Int { rawValue.squared }
  }
  
  var size: Size = .seven
  var challenge: Challenge? {
    didSet {
      challengeNameLabel?.text = challenge?.name
    }
  }
  
  var workoutImages: [UIImage] = [] {
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
      if days == 0 {
        durationLabel.text = "\(days) day"
      } else {
        durationLabel.text = "\(days) days"
      }
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
  
  @IBOutlet private weak var durationLabel: UILabel! {
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
        gradientLayer.colors = [UIColor.hex("#000000", alpha: 0.87).cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.hex("#000000", alpha: 0.87).cgColor]
        gradientLayer.locations = [0.0, 0.25, 0.5, 0.75, 1.0]
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
    return size.total
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return WorkoutImageCell.configure(collectionView: collectionView, indexPath: indexPath, workoutImage: workoutImages[safe: indexPath.row])
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let square = frame.width / CGFloat(size.rawValue)
    
    return CGSize(width: square, height: square)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return .zero
  }
}

extension Int {
  var squared: Int { self * self }
}
