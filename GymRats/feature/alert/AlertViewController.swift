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
  let alertView: AlertView = {
    let alertView = AlertView()
    alertView.layer.cornerRadius = 8
    alertView.backgroundColor = .foreground
    return alertView
  }()
  
  var height: CGFloat { 0 }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
  }

  private func setupView() {
    let hasTopNotch: Bool = {
      if #available(iOS 11.0, tvOS 11.0, *) {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
      }
      
      return false
    }()
    
    let constant: CGFloat = {
      return 10 + (hasTopNotch ? 30 : 0)
    }()
    
    view.addSubview(alertView)
    alertView.translatesAutoresizingMaskIntoConstraints = false
    alertView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
    alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
    alertView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -constant).isActive = true
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
    return false
  }
  
  var anchorModalToLongForm: Bool {
    return true
  }
  
  var isUserInteractionEnabled: Bool {
    return true
  }
}
