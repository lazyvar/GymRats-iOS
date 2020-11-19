//
//  TransientAlertViewController.swift
//  PanModal
//
//  Created by Stephen Sowole on 3/1/19.
//  Copyright © 2019 Detail. All rights reserved.
//

import UIKit
import PanModal

class TransientAlertViewController: AlertViewController {

    private weak var timer: Timer?
    private var countdown: Int = 5

    override func viewDidLoad() {
      super.viewDidLoad()
      
      alertView.titleLabel.text = "Shake for support"
      alertView.message.text = "Shake your phone at any time to get help if you run into an issue."
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
          guard let self = self else { return }
          
          self.countdown -= 1
          
          if self.countdown <= 0 {
            self.invalidateTimer()
            self.dismiss(animated: true, completion: nil)
          }
        }
    }

    func invalidateTimer() {
        timer?.invalidate()
    }

    deinit {
        invalidateTimer()
    }

    // MARK: - Pan Modal Presentable

  
    override var showDragIndicator: Bool {
        return false
    }

    override var anchorModalToLongForm: Bool {
        return true
    }

    override var isUserInteractionEnabled: Bool {
        return true
    }
}
