//
//  CreateAccountViewController.swift
//  GymRats
//
//  Created by mack on 4/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import Eureka
import TTTAttributedLabel

class CreateAccountViewController: GRFormViewController {
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.backgroundColor = .background
    title = "Create an account"
  }
}
