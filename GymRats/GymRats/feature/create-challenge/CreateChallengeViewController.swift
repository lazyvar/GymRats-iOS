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
import RxEureka

protocol CreateChallengeDelegate: class {
    func challengeCreated(challenge: Challenge)
}

class CreateChallengeViewController: FormViewController {

    weak var delegate: CreateChallengeDelegate?
    
    let disposeBag = DisposeBag()

    let name = BehaviorRelay<String?>(value: nil)
    let startDate = BehaviorRelay<Date?>(value: nil)
    let endDate = BehaviorRelay<Date?>(value: nil)
    let photo = BehaviorRelay<UIImage?>(value: nil)

    let submitButton: UIButton = .primary(text: "Submit")

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Start Challenge"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem (
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(UIViewController.dismissSelf)
        )
        
        let nameRow = TextRow("name") {
            $0.title = "Name"
            $0.placeholder = "Best Rats"
        }.cellSetup { cell, _ in
            cell.tintColor = .brand
            cell.textLabel?.font = .body
            cell.titleLabel?.font = .body
        }
        
        let pictureRow = ImageRow("photo") {
            $0.title = "Picture"
            $0.placeholderImage = UIImage(named: "photo")
        }.cellSetup { cell, _ in
            cell.textLabel?.font = .body
        }
        
        let startDateRow = DateRow() {
            $0.value = Date()
            $0.title = "Start Date"
            $0.minimumDate = Date()
        }

        let endDateRow = DateRow() {
            $0.value = Date() + 30.days
            $0.minimumDate = Date()
            $0.title = "End Date"
        }
        
        let numberOfDayslabel = LabelRow() {
            $0.title = "Total Days"
            $0.value = "30"
        }.cellSetup { cell, _ in
            cell.textLabel?.font = .body
        }

        form +++ Section() {
            let footerBuilder = { () -> UIView in
                let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
                self.submitButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
                self.submitButton.layer.cornerRadius = 0
                
                container.addSubview(self.submitButton)
                
                return container
            }
            
            var footer = HeaderFooterView<UIView>(.callback(footerBuilder))
            footer.height = { 40 }
            
            $0.footer = footer
        }
            <<< nameRow
            <<< startDateRow
            <<< endDateRow
            <<< numberOfDayslabel
            <<< pictureRow

        let startingDate = startDateRow.rx.value
        let endingDate = endDateRow.rx.value

        let numberOfDays = Observable<String>.combineLatest(startingDate, endingDate) { startDateVal, endDateVal in
            let difference = startDateVal!.getInterval(toDate: endDateVal!, component: .day)

            return "\(difference)"
        }

        numberOfDays.subscribe(onNext: { val in
            numberOfDayslabel.value = val
            numberOfDayslabel.reload()
        }).disposed(by: disposeBag)

        nameRow.rx.value.bind(to: self.name).disposed(by: disposeBag)
        startDateRow.rx.value.bind(to: self.startDate).disposed(by: disposeBag)
        endDateRow.rx.value.bind(to: self.endDate).disposed(by: disposeBag)
        pictureRow.rx.value.bind(to: self.photo).disposed(by: disposeBag)

        name.asObservable()
            .isPresent
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: disposeBag)

        submitButton.onTouchUpInside { [weak self] in
            self?.createChallenge()
        }.disposed(by: disposeBag)
    }
    
    func createChallenge() {
        showLoadingBar(disallowUserInteraction: true)
        
        gymRatsAPI.createChallenge (
            startDate: startDate.value!,
            endDate: endDate.value!,
            challengeName: name.value!,
            photo: self.photo.value
        )
        .subscribe(onNext: { [weak self] challenge in
            self?.hideLoadingBar()
            self?.dismissSelf()
            self?.delegate?.challengeCreated(challenge: challenge)
        }, onError: { [weak self] error in
            self?.presentAlert(with: error)
            self?.hideLoadingBar()
        }).disposed(by: disposeBag)
    }

}
