//
//  Alert.swift
//  GymRats
//
//  Created by mack on 3/13/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

enum Alert {
  static func presentAlert(title: String, message: String) {
    DispatchQueue.main.async {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      
      alertController.addAction(okAction)
      UIViewController.topmost().present(alertController, animated: true, completion:  nil)
    }
  }

  static func presentAlert(error: Error) {
    presentAlert(title: "Uh-oh", message: error.localizedDescription)
  }
}
