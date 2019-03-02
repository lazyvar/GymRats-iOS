//
//  UserWorkoutTableViewCell.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import AvatarImageView
import SwiftDate
import RxSwift

class UserWorkoutTableViewCell: UITableViewCell {

    let disposeBag = DisposeBag()
    
    @IBOutlet weak var userImageView: UserImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = .body
        detailsLabel.font = .details
        fullNameLabel.font = .body
        
        titleLabel.isHidden = true
        detailsLabel.isHidden = true
        fullNameLabel.isHidden = true
        contentView.alpha = 1.0
        accessoryView = nil
        addDivider()
    }
    
    var userWorkout: UserWorkout! {
        didSet {
            let user = userWorkout.user

            userImageView.load(avatarInfo: user)
            
            if let workout = userWorkout.workout {
                titleLabel.isHidden = false
                detailsLabel.isHidden = false
                titleLabel.text = workout.title
                
                detailsLabel.attributedText = detailsLabeText()

                if let googlePlaceId = workout.googlePlaceId {
                    GService.getPlaceInformation(forPlaceId: googlePlaceId)
                        .subscribe {  [weak self] event in
                            guard let self = self else { return }
                            
                            if case let .next(val) = event {
                                UIView.transition (
                                    with: self.detailsLabel,
                                    duration: 0.2,
                                    options: .transitionCrossDissolve,
                                    animations: { [weak self] in
                                        self?.detailsLabel.attributedText = self?.detailsLabeText(including: val)
                                    }, completion: nil)
                            }
                        }.disposed(by: disposeBag)
                }
                
                let label = UILabel()
                label.text = workout.createdAt.challengeTime
                label.font = .details
                label.sizeToFit()
                
                accessoryView = label
            } else {
                fullNameLabel.isHidden = false
                fullNameLabel.text = userWorkout.user.fullName
                
                let label = UILabel()
                label.text = "Zzz"
                label.font = .details
                label.sizeToFit()
                label.alpha = 0.333
                label.textColor = .fog
                
                accessoryView = label
                contentView.alpha = 0.333
            }
        }
    }
    
    var challenge: Challenge! {
        didSet {
            titleLabel.isHidden = false
            detailsLabel.isHidden = false
            userImageView.load(avatarInfo: challenge)
            titleLabel.text = challenge.name

            if challenge.isActive {
                let difference = Date().getInterval(toDate: challenge.endDate, component: .day)
                
                if difference == 0 {
                    detailsLabel.text = "Last day"
                } else {
                    detailsLabel.text = "\(difference) days remaining"
                }
                
                accessoryType = .disclosureIndicator
            } else {
                detailsLabel.text = "Starts \(challenge.endDate.toFormat("MMMM d")) - Join using \(challenge.code)"
                contentView.alpha = 0.333
            }
        }
    }

    func configure(for user: User, withNumberOfWorkouts numberOfWorkouts: Int) {
        userImageView.load(avatarInfo: user)
        
        fullNameLabel.isHidden = false
        fullNameLabel.text = user.fullName
        
        let label = UILabel()
        label.text = "\(numberOfWorkouts)"
        label.font = .details
        label.sizeToFit()
        label.textColor = .black
        
        accessoryView = label
    }
    
    private func detailsLabeText(including place: Place? = nil) -> NSAttributedString {
        let details = NSMutableAttributedString()
        
        if userWorkout.workout?.photoUrl != nil {
            let cameraImage = NSTextAttachment()
            cameraImage.image = UIImage(named: "camera")
            cameraImage.bounds = CGRect(x: 0, y: -2.5, width: 14, height: 14)
            
            details.append(NSAttributedString(attachment: cameraImage))
            details.append(NSAttributedString(string: "  "))
        }
        
        details.append(NSAttributedString(string: "\(userWorkout.user.fullName)"))
        
        if let place = place {
            details.append(NSAttributedString(string: " @ \(place.name)"))
        }
        
        return details
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.isHidden = true
        detailsLabel.isHidden = true
        fullNameLabel.isHidden = true
        contentView.alpha = 1.0
        accessoryView = nil
    }
    
}
