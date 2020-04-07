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
    
    view.backgroundColor = .background
    
    setupBackButton()
    bindViewModel()
  }
  
  func bindViewModel() {
    fatalError("Abstract method.")
  }
}
