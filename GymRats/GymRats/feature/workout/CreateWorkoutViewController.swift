//
//  CreateWorkoutViewController.swift
//  GymRats
//
//  Created by mack on 1/5/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class CreateWorkoutViewController: GRFormViewController {
    
    var workoutImage: UIImage
    
    init(workoutImage: UIImage) {
        self.workoutImage = workoutImage
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
