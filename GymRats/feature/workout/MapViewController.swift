//
//  MapViewController.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

class MapViewController: UIViewController {
  @IBOutlet private weak var mapView: MKMapView!

  private let disposeBag = DisposeBag()
  private let placeID: String
  
  init(placeID: String) {
    self.placeID = placeID
    
    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    navigationItem.largeTitleDisplayMode = .never
    
    showLoadingBar()

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: .close,
      style: .plain,
      target: self,
      action: #selector(dismissSelf)
    )
    
    GService.getPlaceInformation(forPlaceId: placeID)
      .subscribe { [weak self] event in
        guard let self = self else { return }
        
        self.hideLoadingBar()
        
        if let error = event.error {
          self.presentAlert(with: error)
        }
        
        if let place = event.element {
          let initialLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
          let coordinateRegion = MKCoordinateRegion (
            center: initialLocation.coordinate,
            latitudinalMeters: 500, longitudinalMeters: 500
          )
          
          let annotation = PlaceAnnotation(place: place)
          
          self.mapView.setRegion(coordinateRegion, animated: false)
          self.mapView.mapType = .standard
          self.mapView.addAnnotation(annotation)
        }
      }
    .disposed(by: disposeBag)
  }
}

class PlaceAnnotation: NSObject, MKAnnotation {
  let title: String?
  let coordinate: CLLocationCoordinate2D
  let place: Place
  
  init(place: Place) {
    self.place = place
    self.title = place.name
    self.coordinate = CLLocationCoordinate2D (
      latitude: place.latitude,
      longitude: place.longitude
    )

    super.init()
  }
    
  var subtitle: String? {
    return nil
  }
}
