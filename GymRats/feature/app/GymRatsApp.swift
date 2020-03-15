//
//  GymRatsApp.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class GymRatsApp {
  static var delegate: AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }
  
  static var coordinator: AppCoordinator {
    return delegate.appCoordinator
  }
}
