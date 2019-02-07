//
//  CreateChallengeViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SwiftDate
import RxSwift
import GradientLoadingBar

protocol CreateChallengeDelegate: class {
    func challengeCreated(challenge: Challenge)
}

class CreateChallengeViewController: UIViewController {

    weak var delegate: CreateChallengeDelegate?
    
    let disposeBag = DisposeBag()
    
    let challengeName: SkyFloatingLabelTextField = .standardTextField(placeholder: "Challenge Name")
    
    let startDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.text = "Start Date"
        label.numberOfLines = 0
        
        return label
    }()

    let startDate: UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.minimumDate = Date()
        datePicker.maximumDate = Date() + 60.days
        datePicker.datePickerMode = .date
        datePicker.date = Date()
        
        return datePicker
    }()
    
    let endDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.text = "End Date"
        label.numberOfLines = 0
        
        return label
    }()

    let endDate: UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.minimumDate = Date() + 1.days
        datePicker.maximumDate = Date() + 180.days
        datePicker.datePickerMode = .date
        datePicker.date = Date() + 30.days
        
        return datePicker
    }()
    
    let numberOfDaysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.text = "Start Date"
        label.numberOfLines = 0

        return label
    }()
    
    let createChallengeButton: UIButton = .primary(text: "Create Challenge")

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Create Challenge"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem (
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(UIViewController.dismissSelf)
        )
        
        view.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.alignContent = .center
            layout.padding = 64
        }
        
        startDateLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 60
        }

        startDate.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 5
            layout.height = 100
        }

        endDateLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }
        
        endDate.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 5
            layout.height = 100
        }

        numberOfDaysLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }

        challengeName.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }
        
        createChallengeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }

        view.addSubview(startDateLabel)
        view.addSubview(startDate)
        view.addSubview(endDateLabel)
        view.addSubview(endDate)
        view.addSubview(numberOfDaysLabel)
        view.addSubview(challengeName)
        view.addSubview(createChallengeButton)

        view.yoga.applyLayout(preservingOrigin: true)
        
        let startingDate = startDate.rx.date
        let endingDate = endDate.rx.date
        
        let numberOfDays = Observable<String>.combineLatest(startingDate, endingDate) { startDateVal, endDateVal in
            let difference = startDateVal.getInterval(toDate: endDateVal, component: .day)
            
            return "\(difference) day challenge"
        }
        
        numberOfDays.bind(to: numberOfDaysLabel.rx.text)
            .disposed(by: disposeBag)
        
        challengeName.requiredValidation
            .bind(to: createChallengeButton.rx.isEnabled)
            .disposed(by: disposeBag)
    
        createChallengeButton.onTouchUpInside { [weak self] in
            self?.createChallenge()
        }.disposed(by: disposeBag)
    }
    
    func createChallenge() {
        gymRatsAPI.createChallenge(startDate: startDate.date, endDate: endDate.date, challengeName: challengeName.text!)
            .standardServiceResponse { [weak self] challenge in
                self?.dismissSelf()
                self?.delegate?.challengeCreated(challenge: challenge)
            }.disposed(by: disposeBag)
    }

}
