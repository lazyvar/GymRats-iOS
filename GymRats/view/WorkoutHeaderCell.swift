//
//  WorkoutHeaderCell.swift
//  GymRats
//
//  Created by mack on 4/8/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import Kingfisher

protocol WorkoutHeaderCellDelegate: class {
  func tappedHeader()
  func layoutTableView()
}

class WorkoutHeaderCell: UITableViewCell {
  enum WorkoutData: String, CaseIterable {
    case duration
    case distance
    case steps
    case calories
    case points
  }

  @IBOutlet private weak var bgView: UIView! {
    didSet {
      bgView.backgroundColor = .clear
    }
  }
  
  @IBOutlet private weak var workoutImageView: UIImageView! {
    didSet {
      workoutImageView.contentMode = .scaleAspectFill
      workoutImageView.backgroundColor = .clear
      workoutImageView.layer.cornerRadius = 4
      workoutImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
  }
  
  @IBOutlet private weak var workoutImageSkeleton: UIView! {
    didSet {
      workoutImageSkeleton.isSkeletonable = true
      workoutImageSkeleton.showAnimatedSkeleton()
      workoutImageSkeleton.layer.cornerRadius = 4
      workoutImageSkeleton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
  }
  
  @IBOutlet private weak var accountImageView: UserImageView!
  @IBOutlet private weak var workoutImageHeight: NSLayoutConstraint!
  
  @IBOutlet private weak var accountNameLabel: UILabel! {
    didSet {
      accountNameLabel.textColor = .primaryText
      accountNameLabel.font = .body
    }
  }

  @IBOutlet private weak var timeLabel: UILabel! {
    didSet {
      timeLabel.textColor = .primaryText
      timeLabel.font = .details
    }
  }
  
  @IBOutlet private weak var durationLabel: UILabel! {
    didSet {
      durationLabel.textColor = .primaryText
      durationLabel.font = .details
    }
  }
  
  @IBOutlet private weak var distanceLabel: UILabel! {
    didSet {
      distanceLabel.textColor = .primaryText
      distanceLabel.font = .details
    }
  }
  
  @IBOutlet private weak var stepsLabel: UILabel! {
    didSet {
      stepsLabel.textColor = .primaryText
      stepsLabel.font = .details
    }
  }
  
  @IBOutlet private weak var caloriesLabel: UILabel! {
    didSet {
      caloriesLabel.textColor = .primaryText
      caloriesLabel.font = .details
    }
  }
  
  @IBOutlet private weak var pointsLabel: UILabel! {
    didSet {
      pointsLabel.textColor = .primaryText
      pointsLabel.font = .details
    }
  }
  
  @IBOutlet private weak var durationLabelLabel: UILabel! {
    didSet {
      durationLabelLabel.textColor = .primaryText
      durationLabelLabel.font = .detailsBold
    }
  }
  
  @IBOutlet private weak var distanceLabelLabel: UILabel! {
    didSet {
      distanceLabelLabel.textColor = .primaryText
      distanceLabelLabel.font = .detailsBold
    }
  }
  
  @IBOutlet private weak var stepsLabelLabel: UILabel! {
    didSet {
      stepsLabelLabel.textColor = .primaryText
      stepsLabelLabel.font = .detailsBold
    }
  }
  
  @IBOutlet private weak var caloriesLabelLabel: UILabel! {
    didSet {
      caloriesLabelLabel.textColor = .primaryText
      caloriesLabelLabel.font = .detailsBold
    }
  }
  
  @IBOutlet private weak var pointsLabelLabel: UILabel! {
    didSet {
      pointsLabelLabel.textColor = .primaryText
      pointsLabelLabel.font = .detailsBold
    }
  }
  
  @IBOutlet private weak var firstStack: UIStackView!
  @IBOutlet private weak var secondStack: UIStackView!

  @IBOutlet weak var workoutImageBackground: UIView!
  
  @IBOutlet private weak var workoutDescriptionLabel: UILabel! {
    didSet {
      workoutDescriptionLabel.textColor = .primaryText
      workoutDescriptionLabel.font = .body
    }
  }
  
  @IBOutlet private weak var workoutTitleLabel: UILabel! {
    didSet {
      workoutTitleLabel.textColor = .primaryText
      workoutTitleLabel.font = .h4Bold
    }
  }
  
  @IBOutlet private weak var dividerView: UIView! {
    didSet {
      dividerView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
    }
  }
  
  @IBOutlet private weak var dividerView2: UIView! {
     didSet {
      dividerView2.backgroundColor = UIColor.black.withAlphaComponent(0.1)
     }
   }
  
  @IBOutlet private weak var headerStackView: UIStackView!
  
  private var shadowLayer: CAShapeLayer!
  
  weak var delegate: WorkoutHeaderCellDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()

    let tap = UITapGestureRecognizer(target: self, action: #selector(tappedHeader))
    headerStackView.addGestureRecognizer(tap)

    workoutImageHeight.constant = 400

    addObserver(self, forKeyPath: "bgView.bounds", options: .new, context: nil)
    
    selectionStyle = .none
    backgroundColor = .clear
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    workoutImageBackground.isHidden = false
    workoutImageHeight.constant = frame.width
    firstStack.isHidden = false
    secondStack.isHidden = false
    durationLabel.text = nil
    distanceLabel.text = nil
    stepsLabel.text = nil
    caloriesLabel.text = nil
    pointsLabel.text = nil
    durationLabelLabel.text = nil
    distanceLabelLabel.text = nil
    stepsLabelLabel.text = nil
    caloriesLabelLabel.text = nil
    pointsLabelLabel.text = nil
  }
  
  override func layoutIfNeeded() {
    super.layoutIfNeeded()
    
    if self.shadowLayer == nil {
      self.shadowLayer = CAShapeLayer()
      self.shadowLayer.path = UIBezierPath(roundedRect: self.bgView.bounds, cornerRadius: 4).cgPath
      self.shadowLayer.fillColor = UIColor.foreground.cgColor

      self.shadowLayer.shadowColor = UIColor.shadow.cgColor
      self.shadowLayer.shadowPath = self.shadowLayer.path
      self.shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
      self.shadowLayer.shadowOpacity = 1
      self.shadowLayer.shadowRadius = 2

      self.bgView.layer.insertSublayer(self.shadowLayer, at: 0)
    }
  }
  
  private func configureStacks(_ workout: Workout) {
    let possibleData: [(dataType: WorkoutData, value: String?)] = [
      (.duration, workout.duration?.stringify),
      (.distance, workout.distance),
      (.steps, workout.steps?.stringify),
      (.calories, workout.calories?.stringify),
      (.points, workout.points?.stringify),
    ]
      
    let data = possibleData.compactMap { data -> (dataType: WorkoutData, value: String)? in
      guard let value = data.value else { return nil }
          
      return (data.dataType, value)
    }

    for data in data.enumerated() {
      let dataType = data.element.dataType.rawValue.capitalized
      let dataValue = data.element.value
      
      switch data.offset {
      case 0:
        durationLabelLabel.text = dataType
        durationLabel.text = dataValue
      case 1:
        distanceLabelLabel.text = dataType
        distanceLabel.text = dataValue
      case 2:
        stepsLabelLabel.text = dataType
        stepsLabel.text = dataValue
      case 3:
        caloriesLabelLabel.text = dataType
        caloriesLabel.text = dataValue
      case 4:
        pointsLabelLabel.text = dataType
        pointsLabel.text = dataValue
      default: break
      }
    }
    
    if data.isEmpty {
      firstStack.isHidden = true
      secondStack.isHidden = true
    }
    
    if data.count < 4 {
      secondStack.isHidden = true
    }
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "bgView.bounds" {
      self.shadowLayer?.path = UIBezierPath(roundedRect: self.bgView.bounds, cornerRadius: 4).cgPath
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  @objc private func tappedHeader() {
    delegate?.tappedHeader()
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, workout: Workout, delegate: WorkoutHeaderCellDelegate) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: WorkoutHeaderCell.self, for: indexPath).apply { cell in
      cell.accountNameLabel.text = workout.account.fullName
      cell.workoutTitleLabel.text = workout.title
      cell.workoutDescriptionLabel.text = workout.description
      cell.accountImageView.load(workout.account)
      cell.timeLabel.text = "\(workout.createdAt.challengeTime)"
      cell.configureStacks(workout)
      cell.delegate = delegate
      
      if let photo = workout.photoUrl, let url = URL(string: photo) {
        if let image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: photo) ?? KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: photo) {
          let width = image.size.width
          let height = image.size.height
          let aspectRatio = height / width
          let newHeight = cell.bgView.frame.width * aspectRatio

          cell.workoutImageHeight.constant = newHeight
          cell.workoutImageView.image = image
          cell.setNeedsLayout()
          cell.layoutIfNeeded()
          cell.delegate?.layoutTableView()
        } else {
          cell.workoutImageView.kf.setImage(with: url, options: [.transition(.fade(0.2)), .forceTransition]) { image, _, _, _ in
            guard let image = image else { return }
            
            let width = image.size.width
            let height = image.size.height
            let aspectRatio = height / width
            let newHeight = cell.bgView.frame.width * aspectRatio

            UIView.animate(withDuration: 0.25) {
              cell.workoutImageHeight.constant = newHeight
              cell.setNeedsLayout()
              cell.layoutIfNeeded()
              cell.delegate?.layoutTableView()
            }
          }
        }
      } else {
        cell.workoutImageBackground.isHidden = true
      }
    }
  }
}
