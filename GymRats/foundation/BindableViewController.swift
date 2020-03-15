//
//  BindableViewController.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class BindableViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupBackButton()
    view.backgroundColor = .background

    bindViewModel()
  }
  
  func bindViewModel() {
    fatalError("Abstract method.")
  }
}
