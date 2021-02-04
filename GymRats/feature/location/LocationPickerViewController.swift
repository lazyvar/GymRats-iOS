//
//  LocationPickerViewController.swift
//  GymRats
//
//  Created by mack on 12/3/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

protocol LocationPickerViewControllerDelegate: class {
  func didPickLocation(_ locationPickerViewController: LocationPickerViewController, place: Place)
}

class LocationPickerViewController: UIViewController {
  private enum Constant {
    static let id = "LocationCellID"
  }
  
  private var places: [Place] = [] {
    didSet {
      DispatchQueue.main.async { [self] in
        tableView.reloadData()
        updateMap()
      }
    }
  }

  @IBOutlet private weak var mapView: MKMapView! {
    didSet {
      mapView.delegate = self
    }
  }

  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constant.id)
    }
  }
  
  weak var delegate: LocationPickerViewControllerDelegate?
  private var locationManager: CLLocationManager!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Tag a location"
    
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
  }
  
  private func updateMap() {
    guard let initialLocation = locationManager.location else { return }
    
    let coordinateRegion = MKCoordinateRegion (
      center: initialLocation.coordinate,
      latitudinalMeters: 500, longitudinalMeters: 500
    )
    
    mapView.setRegion(coordinateRegion, animated: false)
    mapView.mapType = .standard
    mapView.removeAnnotations(mapView.annotations)
    
    let annotations = places.map { place in
      return PlaceAnnotation(place: place)
    }
    
    mapView.addAnnotations(annotations)
  }
  
  private func getPlacesForCurrentLocation() {
    let fields: GMSPlaceField = GMSPlaceField(rawValue:
      UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue)
    )!

    self.showLoadingBar()
    
    GMSPlacesClient.shared().findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: { [weak self] placeLikelihoods, error in
      self?.hideLoadingBar()
      
      if let error = error { print("An error occurred: \(error.localizedDescription)"); return }
      guard let self = self else { return }
      guard let placeLikelihoods = placeLikelihoods else { return }
      
      var seen: [String: Bool] = [:]

      self.places = placeLikelihoods
        .sorted(by: { $0.likelihood > $1.likelihood })
        .compactMap { Place(from: $0.place) }
        .filter { seen.updateValue(true, forKey: $0.name) == nil }
    })
  }
}

extension LocationPickerViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    guard let annotation = view.annotation as? PlaceAnnotation else { return }
    
    delegate?.didPickLocation(self, place: annotation.place)
  }
}

extension LocationPickerViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.id, for: indexPath)
    cell.backgroundColor = .foreground
    cell.textLabel?.text = places[indexPath.row].name
    cell.textLabel?.font = .body
    cell.textLabel?.textColor = .primaryText
    
    return cell
  }
}

extension LocationPickerViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    delegate?.didPickLocation(self, place: places[indexPath.row])
  }
}

extension LocationPickerViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      getPlacesForCurrentLocation()
    break
    case .denied, .restricted:
      hideLoadingBar()
      presentAlert(title: "Location permission required", message: "To tag a location, please enable the permission in settings.")
    case .notDetermined:
      break
    @unknown default:
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
