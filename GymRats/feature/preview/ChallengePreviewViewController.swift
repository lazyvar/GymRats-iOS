//
//  ChallengePreviewViewController.swift
//  GymRats
//
//  Created by mack on 3/28/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class ChallengePreviewViewController: BindableViewController {
  private let viewModel = ChallengePreviewViewModel()
  private let disposeBag = DisposeBag()
  
  init(code: String) {
    self.viewModel.configure(code: code)
    
    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    viewModel.input.viewDidLoad.trigger()
  }
  
  override func bindViewModel() {
    
  }
}
