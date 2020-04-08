//
//  GymRatsswift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class GymRatsNavigationController: UINavigationController {
  override func viewDidLoad() {
    super.viewDidLoad()

    navigationBar.tintColor = .primaryText
    navigationBar.barTintColor = .background
//    navigationBar.backgroundColor = .background
//    navigationBar.isTranslucent = false
//    navigationBar.isOpaque = true
//    navigationBar.setBackgroundImage(UIImage(color: .background), for: .default)
    navigationBar.shadowImage = UIImage(color: .clear)
    navigationBar.prefersLargeTitles = true
    
    navigationBar.largeTitleTextAttributes = [
      NSAttributedString.Key.font: UIFont.h1Bold,
      NSAttributedString.Key.foregroundColor: UIColor.primaryText
    ]
    
    navigationBar.titleTextAttributes = [
      NSAttributedString.Key.font: UIFont.h4,
      NSAttributedString.Key.foregroundColor: UIColor.primaryText
    ]
  }
}
