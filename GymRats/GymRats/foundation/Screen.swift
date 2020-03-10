//
//  Screen.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import UIKit

struct Screen {
  static let noChallenges = Screen(viewController: NoChallengesViewController())
  static let home = Screen(viewController: HomeViewController())

  let viewController: UIViewController
}
