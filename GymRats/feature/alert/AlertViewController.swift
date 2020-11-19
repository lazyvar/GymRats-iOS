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

    private let alertViewHeight: CGFloat = 100

    let alertView: AlertView = {
        let alertView = AlertView()
        alertView.layer.cornerRadius = 8
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
        alertView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        alertView.heightAnchor.constraint(equalToConstant: alertViewHeight).isActive = true
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
      return .clear
  }

    var shortFormHeight: PanModalHeight {
        return .contentHeight(alertViewHeight)
    }

    var longFormHeight: PanModalHeight {
        return shortFormHeight
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
