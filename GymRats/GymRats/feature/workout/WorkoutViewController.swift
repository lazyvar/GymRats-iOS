//
//  WorkoutViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import YogaKit

class WorkoutViewController: UIViewController {

    let disposeBag = DisposeBag()
    let user: User
    let workout: Workout
    
    let refresher = UIRefreshControl()
    
    let userImageView: UserImageView = UserImageView()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    init(user: User, workout: Workout) {
        self.user = user
        self.workout = workout
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let containerView = UIView()
        containerView.frame = view.frame
        
        containerView.backgroundColor = .white
        
        let headerView = UIView()
        
        let userImageView = UserImageView()
        userImageView.load(user: user)
        
        let usernameLabel: UILabel = UILabel()
        usernameLabel.font = UIFont.systemFont(ofSize: 16)
        usernameLabel.text = user.fullName

        let timeLabel: UILabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.text = workout.date.localTime
        timeLabel.textAlignment = .right
        
        headerView.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .row
            layout.justifyContent = .flexStart
        }
        
        userImageView.configureLayout { layout in
            layout.isEnabled = true
            layout.width = 44
            layout.height = 44
        }
        
        usernameLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginLeft = 10
        }

        timeLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.flexGrow = 1
        }

        headerView.addSubview(userImageView)
        headerView.addSubview(usernameLabel)
        headerView.addSubview(timeLabel)

        headerView.yoga.applyLayout(preservingOrigin: true)
        
        containerView.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.justifyContent = .flexStart
            layout.padding = 15
        }
        
        containerView.addSubview(headerView)

        if let pictureUrl = workout.pictureUrl, let url = URL(string: pictureUrl) {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 2
            imageView.backgroundColor = .whiteSmoke
            
            imageView.configureLayout { layout in
                layout.isEnabled = true
                layout.flexGrow = 1
                layout.marginTop = 15
                layout.width = YGValue(self.view.frame.width - 30)
                layout.height = YGValue(self.view.frame.width - 30)
            }
            
            imageView.kf.setImage(with: url)
            
            containerView.addSubview(imageView)
        }
        
        if let description = workout.description {
            let descriptionLabel = UILabel()
            descriptionLabel.text = description
            descriptionLabel.numberOfLines = 0
            
            descriptionLabel.configureLayout { layout in
                layout.isEnabled = true
                layout.marginTop = 15
            }
            
            containerView.addSubview(descriptionLabel)
        }

        containerView.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: .flexibleHeight)
        containerView.makeScrolly(in: view)
    }
    
}
