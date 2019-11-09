//
//  NewWorkoutViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/6/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import GooglePlaces
import Eureka
import RxEureka

protocol NewWorkoutDelegate: class {
    func newWorkoutController(_ newWorkoutController: NewWorkoutViewController, created workouts: [Workout])
}

class NewWorkoutViewController: FormViewController, Special {
    
    weak var delegate: NewWorkoutDelegate?

    let disposeBag = DisposeBag()
    
    let placeLikelihoods = BehaviorRelay<[Place]>(value: [])
    let place = BehaviorRelay<Place?>(value: nil)
    let photo = BehaviorRelay<UIImage?>(value: nil)
    let workoutDescription = BehaviorRelay<String?>(value: nil)
    let workoutTitle = BehaviorRelay<String?>(value: nil)

    var challenges: [Int: BehaviorRelay<Bool>] = [:]
    
    lazy var submitButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(postWorkout))
    lazy var cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissSelf))

    let placeRow = PushRow<Place>() {
        $0.title = "Current Location"
        $0.selectorTitle = "Where are you?"
    }
    .cellSetup { cell, _ in
        cell.height = { return 48 }
    }
    .onPresent { _, selector in
        selector.enableDeselection = false
    }
    
    lazy var placeButtonRow = ButtonRow("place") {
        $0.title = "Check In Location"
    }.cellSetup { cell, _ in
        cell.textLabel?.font = .body
        cell.height = { return 48 }
    }.onCellSelection { [weak self] _, _ in
        self?.pickPlace()
        self?.showLoadingBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = submitButton
        navigationItem.leftBarButtonItem = cancelButton

        title = "Log Workout"
        
        LabelRow.defaultCellUpdate = nil

        let titleRow = TextRow("name") {
            $0.title = "Title"
            $0.placeholder = "Leg day."
        }.cellSetup { cell, _ in
            cell.textLabel?.font = .body
            cell.titleLabel?.font = .body
            cell.height = { return 48 }
            DispatchQueue.main.async {
                cell.textField.becomeFirstResponder()
            }
        }
        
        let descriptionRow = TextAreaRow("description") {
            $0.placeholder = "Description...\n3x8 squats\n3x6 deadlifts\n3x4 rows"
        }.cellSetup { cell, _ in
            cell.textLabel?.font = .body
            cell.textView.font = .body
        }
        
        let photoRow = ImageRow("photo") {
            $0.title = "Take Photo"
            $0.placeholderImage = UIImage(named: "photo")
            $0.sourceTypes = [.Camera, .SavedPhotosAlbum]
            $0.validatePhotoWasTakenToday = false
        }.cellSetup { cell, _ in
            cell.height = { return 48 }
            cell.textLabel?.font = .body
        }
        
        let activeChallenges = GymRatsApp.coordinator.menu.activeChallenges
        let challengeSection = Section("Challenges")
        
        let last = Section() {
            let footerBuilder = { () -> UIView in
                let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
                let textLabel = UILabel()
                textLabel.font = .details
                textLabel.numberOfLines = 0
                textLabel.textAlignment = .center
                textLabel.text = "Title and photo are required to post a workout."
                textLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
                
                container.addSubview(textLabel)
                
                return container
            }
            
            var footer = HeaderFooterView<UIView>(.callback(footerBuilder))
            footer.height = { 30 }
            
            $0.footer = footer
        }
        
        form +++ Section() {
            $0.tag = "the-form"
        }
            <<< titleRow
            <<< descriptionRow
            <<< photoRow
            <<< placeButtonRow
        
        activeChallenges.forEach { challenge in
            let row = SwitchRow("challenge_\(challenge.id)") {
                $0.title = "\(challenge.name)"
                $0.value = true
            }.cellSetup { cell, _ in
                cell.height = { return 48 }
            }
            
            let relay = BehaviorRelay(value: true)
            row.rx.value.map { $0 ?? true }.bind(to: relay).disposed(by: disposeBag)
            self.challenges[challenge.id] = relay
            
            challengeSection <<< row
        }
        
        form +++ challengeSection
        form +++ last
        
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
        
        let atLeastOneChallenge = Observable<Bool>.combineLatest(self.challenges.values) { vals in
            return vals.reduce(false) { $0 || $1 }
        }
        
        Observable<Bool>.combineLatest(titlePresent, photoPresent, atLeastOneChallenge) { titlePresent, photoPresent, atLeastOneChallenge in
            return titlePresent && photoPresent && atLeastOneChallenge
        }
        .bind(to: self.submitButton.rx.isEnabled).disposed(by: disposeBag)
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
                let places = placeLikelihoods?.sorted(by: { $0.likelihood > $1.likelihood }).map({ Place(from: $0.place) }).compacted()
            else { return }

            self.form.sectionBy(tag: "the-form")?.remove(at: 3) // yikes
            var section = self.form.sectionBy(tag: "the-form")
            section?.insert(self.placeRow, at: 3)
  
            self.placeLikelihoods.accept(places.unique())
        })
    }
    
    @objc func postWorkout() {
        showLoadingBar(disallowUserInteraction: true)
        
        let challenges = self.challenges
            .filter { $0.value.value }
            .map { $0.key }
        
        gymRatsAPI.postWorkout (
            title: workoutTitle.value!,
            description: workoutDescription.value,
            photo: photo.value,
            googlePlaceId: place.value?.id,
            challenges: challenges
        ).subscribe(onNext: { [weak self] workouts in
            guard let self = self else { return }
            
            self.hideLoadingBar()
            self.navigationController?.popViewController(animated: true)
            self.delegate?.newWorkoutController(self, created: workouts)
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
            presentAlert(title: "Location Permission Required", message: "To check in a location, please enable the permission in settings.")
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

protocol OptionalParasite {
    associatedtype WrappedParasite
    
    func toArray() -> [WrappedParasite]
}

extension Optional: OptionalParasite {
    typealias WrappedParasite = Wrapped
    
    func toArray() -> [WrappedParasite] {
        return flatMap { [$0] } ?? []
    }
}

extension Sequence where Iterator.Element: OptionalParasite {
    func compacted() -> [Iterator.Element.WrappedParasite] {
        return flatMap { element in
            return element.toArray()
        }
    }
}
