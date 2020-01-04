//
//  CreateChallengeViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import SwiftDate
import RxSwift
import RxCocoa
import GradientLoadingBar
import Eureka

protocol CreateChallengeDelegate: class {
    func challengeCreated(challenge: Challenge)
}

class CreateChallengeViewController: GRFormViewController, Special {

    weak var delegate: CreateChallengeDelegate?
    
    let disposeBag = DisposeBag()

    let name = BehaviorRelay<String?>(value: nil)
    let startDate = BehaviorRelay<Date?>(value: nil)
    let endDate = BehaviorRelay<Date?>(value: nil)
    let photo = BehaviorRelay<UIImage?>(value: nil)

    lazy var submitButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(createChallenge))

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Start Challenge"
        submitButton.tintColor = .brand
        LabelRow.defaultCellUpdate = nil
        
        navigationItem.rightBarButtonItem = submitButton
        navigationItem.leftBarButtonItem = UIBarButtonItem (
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(UIViewController.dismissSelf)
        )
        
        let nameRow = TextRow("name") {
            $0.title = "Name"
            $0.placeholder = "Super Rats"
        }.cellSetup { cell, _ in
            cell.textLabel?.font = .body
            cell.titleLabel?.font = .body
            cell.height = { return 48 }
            cell.tintColor = .brand
            DispatchQueue.main.async {
                cell.textField.becomeFirstResponder()
            }
        }
        
        let pictureRow = ImageRow("photo") {
            $0.title = "Banner photo"
            $0.placeholderImage = UIImage(named: "photo")?.withRenderingMode(.alwaysTemplate)
            $0.sourceTypes = [.Camera, .PhotoLibrary]
        }.cellSetup { cell, _ in
            cell.textLabel?.font = .body
            cell.tintColor = .primaryText
            cell.height = { return 48 }
        }
        
        let startDateRow = DateRow() {
            $0.value = Date()
            $0.title = "Start Date"
            $0.minimumDate = Date()
        }.cellSetup { cell, _ in
            cell.tintColor = .brand
            cell.height = { return 48 }
        }

        let endDateRow = DateRow() {
            $0.value = Date() + 30.days
            $0.minimumDate = Date()
            $0.title = "End Date"
        }.cellSetup { cell, _ in
            cell.tintColor = .brand
            cell.height = { return 48 }
        }
        
        let numberOfDayslabel = LabelRow() {
            $0.title = "Total Days"
            $0.value = "30"
        }.cellSetup { cell, _ in
            cell.textLabel?.font = .body
            cell.height = { return 48 }
        }

        form +++ Section()
            <<< nameRow
            <<< startDateRow
            <<< endDateRow
            <<< numberOfDayslabel
            <<< pictureRow

        nameRow.rx.value.bind(to: self.name).disposed(by: disposeBag)
        startDateRow.rx.value.bind(to: self.startDate).disposed(by: disposeBag)
        endDateRow.rx.value.bind(to: self.endDate).disposed(by: disposeBag)
        pictureRow.rx.value.bind(to: self.photo).disposed(by: disposeBag)

        name.asObservable()
            .isPresent
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        let numberOfDays = Observable<String>.combineLatest(startDate, endDate) { startDateVal, endDateVal in
            let difference = startDateVal!.getInterval(toDate: endDateVal!, component: .day)
            
            return "\(difference)"
        }
        
        numberOfDays.subscribe(onNext: { val in
            numberOfDayslabel.value = val
            numberOfDayslabel.reload()
        }).disposed(by: disposeBag)
    }
    
    @objc func createChallenge() {
        let difference = startDate.value!.getInterval(toDate: endDate.value!, component: .day)

        guard difference > 0 else {
            presentAlert(title: "Number of Days Error", message: "The ending date must be further ahead in time than the starting date.")
            
            return
        }
        
        showLoadingBar(disallowUserInteraction: true)
        
        let start = DateInRegion(startDate.value!, region: .current).dateAtStartOf(.day).date
        let end = DateInRegion(endDate.value!, region: .current).dateAtStartOf(.day).date
            
        gymRatsAPI.createChallenge (
            startDate: start.dateAtStartOf(.day),
            endDate: end.dateAtStartOf(.day),
            challengeName: name.value!,
            photo: self.photo.value
        )
        .subscribe(onNext: { [weak self] challenge in
            self?.hideLoadingBar()
            
            Track.event(.challengeCreated)
            
            let share = ShareCodeViewController.loadFromNib(from: .challenge)
            share.challenge = challenge
            share.delegate = self?.delegate
            
            self?.navigationController?.setViewControllers([share], animated: true)
        }, onError: { [weak self] error in
            self?.presentAlert(with: error)
            self?.hideLoadingBar()
        }).disposed(by: disposeBag)
    }

}
