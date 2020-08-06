//
//  SmartLabel.swift
//  GymRats
//
//  Created by mack on 8/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import CoreLocation

class SmartLabel: TTTAttributedLabel {

  override init(frame: CGRect) {
    super.init(frame: frame)
  
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    setup()
  }
  
  private func setup() {
    let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showCopy(recognizer:)))

    delegate = self
    font = .body
    textColor = .primaryText
    activeLinkAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.brand,
    ]
    
    linkAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.brand.darker,
    ]

    enabledTextCheckingTypes =
      NSTextCheckingResult.CheckingType.link.rawValue
      | NSTextCheckingResult.CheckingType.phoneNumber.rawValue
      | NSTextCheckingResult.CheckingType.address.rawValue
    
    addObserver(self, forKeyPath: "font", options: .new, context: nil)
    addGestureRecognizer(gestureRecognizer)
  }
    
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    switch keyPath {
    case "font":
      activeLinkAttributes = [
        NSAttributedString.Key.font: font ?? .body,
        NSAttributedString.Key.foregroundColor: UIColor.brand,
      ]
      
      linkAttributes = [
        NSAttributedString.Key.font: font ?? .body,
        NSAttributedString.Key.foregroundColor: UIColor.brand.darker,
      ]
    default:
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }
  
  func tapToCopy() {
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showCopy(recognizer:)))

    addGestureRecognizer(gestureRecognizer)
  }
  
  @objc private func showCopy(recognizer: UIGestureRecognizer) {
    guard let recognizerView = recognizer.view, let recognizerSuperView = recognizerView.superview else { return }
    
    let menuController = UIMenuController.shared
    menuController.setTargetRect(recognizerView.frame, in: recognizerSuperView)
    menuController.setMenuVisible(true, animated:true)
    recognizerView.becomeFirstResponder()
  }
  
  override var canBecomeFirstResponder: Bool { true }
  
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return (action == #selector(UIResponderStandardEditActions.copy(_:)))
  }

  override func copy(_ sender: Any?) {
    UIPasteboard.general.string = (text as? String) ?? ""
  }
}

extension SmartLabel: TTTAttributedLabelDelegate {
  func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
  
  func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithPhoneNumber phoneNumber: String!) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let copy = UIAlertAction(title: "Copy", style: .default) { _ in
      UIPasteboard.general.string = phoneNumber
    }
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alert.addAction(copy)
    alert.addAction(cancel)
    
    UIViewController.topmost().present(alert, animated: true, completion: nil)
  }

  func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithAddress addressComponents: [AnyHashable : Any]!) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let address = [addressComponents["Street"] as? String, addressComponents["City"] as? String, addressComponents["State"] as? String, addressComponents["ZIP"] as? String]
      .compactMap { $0 }.joined(separator: " ")

    let maps = UIAlertAction(title: "Open in Maps", style: .default) { _ in
      let geoCoder = CLGeocoder()
      
      geoCoder.geocodeAddressString(address) { placemarks, error in
        guard let placemarks = placemarks?.first else { return }
        
        let location = placemarks.location?.coordinate ?? CLLocationCoordinate2D()
        
        guard let url = URL(string:"http://maps.apple.com/?daddr=\(location.latitude),\(location.longitude)") else { return }
        
        UIApplication.shared.open(url)
      }
    }
    
    let copy = UIAlertAction(title: "Copy", style: .default) { _ in
      UIPasteboard.general.string = address
    }

    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alert.addAction(copy)
    alert.addAction(maps)
    alert.addAction(cancel)
    
    UIViewController.topmost().present(alert, animated: true, completion: nil)
  }
}
