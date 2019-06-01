//
//  LoadingUserWorkoutView.swift
//  GymRats
//
//  Created by Mack on 6/1/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import SkeletonView

class LoadingUserWorkoutView: UIView {

    init(frame: CGRect, userWorkout: UserWorkout) {
        super.init(frame: frame)
        
        let circleView = UIView()
        circleView.constrainWidth(44)
        circleView.constrainHeight(44)
        circleView.layer.cornerRadius = 22
        circleView.clipsToBounds = true
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.isSkeletonable = true
        circleView.showAnimatedSkeleton()
        
        addSubview(circleView)
        
        let titleLabel = UILabel()
        titleLabel.font = .body
        titleLabel.text = userWorkout.workout?.title ?? userWorkout.user.fullName
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.sizeToFit()
        titleLabel.isSkeletonable = true
        titleLabel.showAnimatedSkeleton()
        
        let detailsLabel = UILabel()
        detailsLabel.font = .details
        detailsLabel.text = userWorkout.user.fullName
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.sizeToFit()
        detailsLabel.isSkeletonable = true
        detailsLabel.showAnimatedSkeleton()

        let zzz = UILabel()
        zzz.font = .details
        zzz.text = "Zzz"
        zzz.sizeToFit()
        zzz.translatesAutoresizingMaskIntoConstraints = false
        zzz.isSkeletonable = true
        zzz.showAnimatedSkeleton()

        addSubview(titleLabel)
        addSubview(zzz)
        addSubview(detailsLabel)
        
        zzz.verticallyCenter(in: self)
        
        addConstraint(NSLayoutConstraint(item: circleView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 10))
        addConstraint(NSLayoutConstraint(item: circleView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 7))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: circleView, attribute: .trailing, multiplier: 1, constant: 10))
        addConstraint(NSLayoutConstraint(item: detailsLabel, attribute: .leading, relatedBy: .equal, toItem: circleView, attribute: .trailing, multiplier: 1, constant: 10))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: circleView, attribute: .top, multiplier: 1, constant: 2))
        addConstraint(NSLayoutConstraint(item: detailsLabel, attribute: .bottom, relatedBy: .equal, toItem: circleView, attribute: .bottom, multiplier: 1, constant: -3.5))
        addConstraint(NSLayoutConstraint(item: zzz, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 10))

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
