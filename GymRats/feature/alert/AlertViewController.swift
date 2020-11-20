//
//  AlertViewController.swift
//  PanModal
//
//  Created by Stephen Sowole on 2/26/19.
//  Copyright © 2019 PanModal. All rights reserved.
//

import UIKit
import PanModal

class AlertViewController: UIViewController, PanModalPresentable {
  var height: CGFloat { 0 }
  
  let alertView: AlertView = {
    let alertView = AlertView()
    alertView.layer.cornerRadius = 8
    alertView.backgroundColor = .foreground
    return alertView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
  }

  private func setupView() {
    view.addSubview(alertView)
    alertView.translatesAutoresizingMaskIntoConstraints = false
    alertView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    alertView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
    alertView.constrainHeight(height)
  }

  // MARK: - PanModalPresentable

  var allowsDragToDismiss: Bool {
    return true
  }
  
  var allowsTapToDismiss: Bool {
    return true
  }
  
  var panScrollable: UIScrollView? {
      return nil
  }
  
  var panModalBackgroundColor: UIColor {
    return UIColor.black.withAlphaComponent(0.1)
  }

  var shortFormHeight: PanModalHeight {
    return .contentHeight(height)
  }

  var longFormHeight: PanModalHeight {
    return .contentHeight(height)
  }

  var shouldRoundTopCorners: Bool {
    return false
  }

  var showDragIndicator: Bool {
    return true
  }

  var anchorModalToLongForm: Bool {
    return false
  }

  var isUserInteractionEnabled: Bool {
    return true
  }
}
