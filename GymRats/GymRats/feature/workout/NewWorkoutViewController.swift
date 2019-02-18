//
//  NewWorkoutViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/6/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import RxSwift
import RxCocoa
import GooglePlaces
import Eureka
import RxEureka

protocol NewWorkoutDelegate: class {
    func workoutCreated(workouts: [Workout])
}

class NewWorkoutViewController: FormViewController {
    
    weak var delegate: NewWorkoutDelegate?

    let disposeBag = DisposeBag()
    
    let placeLikelihoods = BehaviorRelay<[Place]>(value: [])
    let place = BehaviorRelay<Place?>(value: nil)
    let photo = BehaviorRelay<UIImage?>(value: nil)
    let workoutDescription = BehaviorRelay<String?>(value: nil)
    let workoutTitle = BehaviorRelay<String?>(value: nil)

    let submitButton: UIButton = .primary(text: "Submit")
    
    let placeRow = PushRow<Place>() {
        $0.title = "Current Location"
        $0.selectorTitle = "Where are you?"
    }.onPresent { _, selector in
        selector.enableDeselection = false
    }
    
    lazy var placeButtonRow = ButtonRow("place") {
        $0.title = "Check In Location"
    }.cellSetup { cell, _ in
        cell.textLabel?.font = .body
        cell.tintColor = .brandDark
    }.onCellSelection { [weak self] _, _ in
        self?.pickPlace()
        self?.showLoadingBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "New Workout"
        tableView.backgroundColor = .whiteSmoke
        
        LabelRow.defaultCellSetup = nil
        setupBackButton()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem (
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(UIViewController.dismissSelf)
        )

        let titleRow = TextRow("name") {
            $0.title = "Title"
            $0.placeholder = "Leg day."
        }.cellSetup { cell, _ in
            cell.tintColor = .brand
            cell.textLabel?.font = .body
            cell.titleLabel?.font = .body
        }
        
        let descriptionRow = TextAreaRow("description") {
            $0.placeholder = "Description...\n3x8 squats\n3x6 deadlifts\n3x4 rows"
        }.cellSetup { cell, _ in
            cell.tintColor = .brand
            cell.textLabel?.font = .body
            cell.textView.font = .body
        }
        
        let photoRow = ImageRow("photo") {
            $0.title = "Take Photo"
            $0.placeholderImage = UIImage(named: "photo")
        }.cellSetup { cell, _ in
            cell.textLabel?.font = .body
        }
        
        form +++ Section() {
            let footerBuilder = { () -> UIView in
                let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
                self.submitButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
                self.submitButton.layer.cornerRadius = 0
                
                container.addSubview(self.submitButton)
                
                let textLabel = UILabel()
                textLabel.font = .details
                textLabel.textColor = .fog
                textLabel.numberOfLines = 0
                textLabel.textAlignment = .center
                textLabel.text = "Either a photo or a location is required to post a workout."
                textLabel.frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: 20)
                
                container.addSubview(textLabel)
                
                return container
            }
            
            var footer = HeaderFooterView<UIView>(.callback(footerBuilder))
            footer.height = { 70 }
            
            $0.tag = "the-form"
            $0.footer = footer
        }
            <<< titleRow
            <<< descriptionRow
            <<< photoRow
            <<< placeButtonRow

        placeLikelihoods.asObservable()
            .subscribe { [weak self] event in
                switch event {
                case .next(let val):
                    self?.placeRow.options = val
                    self?.placeRow.value = val.first
                    self?.placeRow.reload()
                case .error:
                    // TODO
                    break
                default:
                    break
                }
            }.disposed(by: disposeBag)
        
        titleRow.rx.value.bind(to: self.workoutTitle).disposed(by: disposeBag)
        descriptionRow.rx.value.bind(to: self.workoutDescription).disposed(by: disposeBag)
        photoRow.rx.value.bind(to: self.photo).disposed(by: disposeBag)
        placeRow.rx.value.bind(to: self.place).disposed(by: disposeBag)
        
        let titlePresent = self.workoutTitle.asObservable().isPresent
        let photoPresent = self.photo.asObservable().isPresent
        let placePresent = self.place.asObservable().isPresent
        
        Observable<Bool>.combineLatest(titlePresent, photoPresent, placePresent) { titlePresent, photoPresent, placePresent in
            return titlePresent && (photoPresent || placePresent)
        }
        .bind(to: self.submitButton.rx.isEnabled).disposed(by: disposeBag)
        
        submitButton.onTouchUpInside { [weak self] in
            self?.postWorkout()
        }.disposed(by: disposeBag)
    }
    
    var locationManager: CLLocationManager?
    
    func pickPlace() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func getPlacesForCurrentLocation() {
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        
        GMSPlacesClient.shared().findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: { [weak self] placeLikelihoods, error in
            self?.hideLoadingBar()
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            guard
                let self = self,
                let places = placeLikelihoods?.sorted(by: { $0.likelihood > $1.likelihood }).map({ Place(from: $0.place) })
            else { return }

            self.form.sectionBy(tag: "the-form")?.remove(at: 3) // yikes
            self.form.sectionBy(tag: "the-form")?.append(self.placeRow)
  
            self.placeLikelihoods.accept(places.unique())
        })
    }
    
    func postWorkout() {
        showLoadingBar(disallowUserInteraction: true)
        
        gymRatsAPI.postWorkout (
            title: workoutTitle.value!,
            description: workoutDescription.value,
            photo: photo.value,
            googlePlaceId: place.value?.id
        ).subscribe(onNext: { [weak self] workouts in
            self?.hideLoadingBar()
            self?.dismissSelf()
            self?.delegate?.workoutCreated(workouts: workouts)
        }, onError: { [weak self] error in
            self?.presentAlert(with: error)
            self?.hideLoadingBar()
        }).disposed(by: disposeBag)
    }
    
}

extension NewWorkoutViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            getPlacesForCurrentLocation()
        case .denied, .restricted:
            self.hideLoadingBar()
            presentAlert(title: "Location Settings Requires", message: "This feature requires the location settings yada yada")
        case .notDetermined:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // mt
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        presentAlert(title: "Error Getting Location", message: "Please try again.")
    }
    
}

extension Bool {
    
    var toggled: Bool {
        return !self
    }
    
}

extension Array where Element == Place {
    
    func unique() -> [Place] {
        var seen: [String: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0.name) == nil }
    }
    
}
