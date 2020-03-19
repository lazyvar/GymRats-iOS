//
//  WorkoutHeaderView.swift
//  GymRats
//
//  Created by Mack on 7/7/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import MapKit
import SkeletonView
import Kingfisher

protocol WorkoutHeaderViewDelegate: class {
    func tappedHeader()
    func layoutTableView()
}

class WorkoutHeaderView: UIView {
    
    weak var height: NSLayoutConstraint?
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        let stackViewHeight = stackView.frame.height
        
        if height == nil {
            height = self.constrainHeight(stackViewHeight)
        }
    
        height?.constant = stackViewHeight
    }
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var userImageView: UserImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = .background
        }
    }
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var headerStackView: UIStackView!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var durationLabelLabel: UILabel!
    @IBOutlet weak var distanceLabelLabel: UILabel!
    @IBOutlet weak var stepsLabelLabel: UILabel!
    @IBOutlet weak var caloriesLabelLabel: UILabel!
    @IBOutlet weak var pointsLabelLabel: UILabel!
    
    @IBOutlet weak var firstStack: UIStackView!
    @IBOutlet weak var secondStack: UIStackView!
    
    private let disposeBag = DisposeBag()

    class func instanceFromNib() -> WorkoutHeaderView {
        return UINib(nibName: "WorkoutHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WorkoutHeaderView
    }
    
    weak var delegate: WorkoutHeaderViewDelegate?
    @objc func tappedHeader() {
        self.delegate?.tappedHeader()
    }
    
    enum WorkoutData: String, CaseIterable {
        case duration
        case distance
        case steps
        case calories
        case points
    }
    
    func configure(workout: Workout, challenge: Challenge?, width: CGFloat) {
        constrainWidth(width)
        
        userImageView.load(avatarInfo: workout.account)
        timeLabel.text = workout.createdAt.challengeTime
        usernameLabel.text = workout.account.fullName

        durationLabel.text = nil
        distanceLabel.text = nil
        stepsLabel.text = nil
        caloriesLabel.text = nil
        pointsLabel.text = nil

        durationLabelLabel.text = nil
        distanceLabelLabel.text = nil
        stepsLabelLabel.text = nil
        caloriesLabelLabel.text = nil
        pointsLabelLabel.text = nil
        
        firstStack.isHidden = false
        secondStack.isHidden = false
        
        let datas: [(WorkoutData, String?)] = [
            (.duration, workout.duration?.stringify),
            (.distance, workout.distance),
            (.steps, workout.steps?.stringify),
            (.calories, workout.calories?.stringify),
            (.points, workout.points?.stringify),
        ]
        let newDatas = datas.compactMap { d -> (WorkoutData, String)? in
            guard let stang = d.1 else { return nil }
                
            return (d.0, stang)
        }

        for o in newDatas.enumerated() {
            let text1 = o.element.0.rawValue.capitalized
            let text2 = o.element.1
            
            switch o.offset {
            case 0:
                durationLabelLabel.text = text1
                durationLabel.text = text2
            case 1:
                distanceLabelLabel.text = text1
                distanceLabel.text = text2
            case 2:
                stepsLabelLabel.text = text1
                stepsLabel.text = text2
            case 3:
                caloriesLabelLabel.text = text1
                caloriesLabel.text = text2
            case 4:
                pointsLabelLabel.text = text1
                pointsLabel.text = text2
            default: break
            }
        }
        
        if newDatas.isEmpty {
            firstStack.isHidden = true
            secondStack.isHidden = true
        }
        
        if newDatas.count < 4 {
            secondStack.isHidden = true
        }
        
//        durationLabel.text = workout.duration?.stringify ?? "-"
//        distanceLabel.text = workout.distance ?? "-"
//        stepsLabel.text =  ?? "-"
//        caloriesLabel.text =  ?? "-"
//        pointsLabel.text =  ?? "-"

        if let pictureUrl = workout.photoUrl, let url = URL(string: pictureUrl) {
            if let image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: pictureUrl) ?? KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: pictureUrl) {
                self.imageView.image = image
                let width = image.size.width
                let height = image.size.height
                let aspectRatio = height / width
                
                self.imageViewHeight.constant = self.imageView.frame.width * aspectRatio
                self.delegate?.layoutTableView()
            } else {
                imageView.startAnimating()
                imageView.kf.setImage(with: url) { image, _, _, _ in
                    self.imageView.stopAnimating()
                    guard let image = image else { return }
                    
                    let width = image.size.width
                    let height = image.size.height
                    let aspectRatio = height / width
                    
                    UIView.animate(withDuration: 0.15) {
                        self.imageViewHeight.constant = self.imageView.frame.width * aspectRatio
                        self.setNeedsLayout()
                        self.delegate?.layoutTableView()
                    }
                }
            }
        } else {
            imageView.isHidden = true
        }

        if let placeId = workout.googlePlaceId {
            GService.getPlaceInformation(forPlaceId: placeId)
                .subscribe { [weak self] event in
                    guard let self = self else { return }
                    
                    switch event {
                    case .next(let place):
                        let initialLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
                        let coordinateRegion = MKCoordinateRegion (
                            center: initialLocation.coordinate,
                            latitudinalMeters: 500, longitudinalMeters: 500
                        )
                        let annotation = PlaceAnnotation (
                            title: place.name,
                            coordinate: CLLocationCoordinate2D (
                                latitude: place.latitude,
                                longitude: place.longitude
                            )
                        )

                        self.mapView.setRegion(coordinateRegion, animated: false)
                        self.mapView.mapType = .standard
                        self.mapView.isUserInteractionEnabled = false
                        self.mapView.addAnnotation(annotation)
                    default: break
                    }
                }.disposed(by: disposeBag)
        } else {
            mapView.isHidden = true
        }
        
        titleLabel.text = workout.title
        
        if let description = workout.description {
            descriptionLabel.text = description
            descriptionLabel.numberOfLines = 0
            descriptionLabel.font = .body
        } else {
            descriptionLabel.isHidden = true
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedHeader))
        headerStackView.addGestureRecognizer(tap)
    }
}

extension Int {
    var stringify: String {
        return String(self)
    }
}
