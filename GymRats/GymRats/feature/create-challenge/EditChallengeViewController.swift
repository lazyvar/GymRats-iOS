//
//  EditChallengeViewController.swift
//  GymRats
//
//  Created by Mack on 9/24/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import SwiftDate
import RxSwift
import RxCocoa
import GradientLoadingBar
import Eureka
import RxEureka
import Kingfisher

protocol EditChallengeDelegate: class {
    func challengeEdited(challenge: Challenge)
}

class EditChallengeViewController: FormViewController, Special {
    
    let challenge: Challenge
    
    init(challenge: Challenge) {
        self.challenge = challenge
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: EditChallengeDelegate?
    
    let disposeBag = DisposeBag()
    
    let name = BehaviorRelay<String?>(value: nil)
    let startDate = BehaviorRelay<Date?>(value: nil)
    let endDate = BehaviorRelay<Date?>(value: nil)
    let photo = BehaviorRelay<UIImage?>(value: nil)
    
    let submitButton: UIButton = .primary(text: "Submit")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Challenge"
//        view.backgroundColor = .white
        
        LabelRow.defaultCellUpdate = nil
        
        navigationItem.leftBarButtonItem = UIBarButtonItem (
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(UIViewController.dismissSelf)
        )
        
        let nameRow = TextRow("name") {
            $0.title = "Name"
            $0.placeholder = "Beast Rats"
            $0.value = challenge.name
        }.cellSetup { cell, _ in
            cell.tintColor = .primaryText
            cell.textLabel?.font = .body
            cell.titleLabel?.font = .body
        }
        
        let pictureRow = ImageRow("photo") {
            $0.title = "Picture"
            $0.placeholderImage = UIImage(named: "photo")
            $0.sourceTypes = [.Camera, .PhotoLibrary]
            
            if let pic = challenge.profilePictureUrl {
                $0.value = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: pic)
            }
        }.cellSetup { cell, _ in
            cell.textLabel?.font = .body
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        let startDateRow = DateRow() {
            $0.value = challenge.startDate
            $0.title = "Start Date"
            $0.dateFormatter = dateFormatter
        }.cellSetup { cell, row in
            cell.datePicker.timeZone = .utc
        }
        
        let endDateRow = DateRow() {
            $0.value = Date() + 30.days
            $0.title = "End Date"
            $0.value = challenge.endDate
            $0.dateFormatter = dateFormatter
        }.cellSetup { cell, row in
            cell.datePicker.timeZone = .utc
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
        
        submitButton.onTouchUpInside { [weak self] in
            self?.createChallenge()
        }.disposed(by: disposeBag)
    }

    func createChallenge() {
        let difference = startDate.value!.getInterval(toDate: endDate.value!, component: .day)
        
        guard difference > 0 else {
            presentAlert(title: "Number of Days Error", message: "The ending date must be further ahead in time than the starting date.")
            return
        }
        
        showLoadingBar(disallowUserInteraction: true)
        
        let start = DateInRegion(startDate.value!, region: .UTC).dateAtStartOf(.day).date
        let end = DateInRegion(endDate.value!, region: .UTC).dateAtStartOf(.day).date
        
        gymRatsAPI.editChallenge (
            id: challenge.id,
            startDate: start,
            endDate: end,
            challengeName: name.value!,
            photo: self.photo.value
        ).subscribe(onNext: { [weak self] challenge in
            self?.hideLoadingBar()
            self?.dismissSelf()
            self?.delegate?.challengeEdited(challenge: challenge)
        }, onError: { [weak self] error in
            self?.presentAlert(with: error)
            self?.hideLoadingBar()
        }).disposed(by: disposeBag)
    }
    
}
