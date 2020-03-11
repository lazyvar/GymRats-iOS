//
//  HomeViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: BindableViewController {

  private let viewModel = HomeViewModel()
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    viewModel.input.viewDidLoad.trigger()
  }
  
  override func bindViewModel() {
    viewModel.output.error
      .flatMap { UIAlertController.present($0) }
      .ignore(disposedBy: disposeBag)
    
    viewModel.output.installScreen
      .next { [weak self] screen in
        self?.install(screen.viewController)
      }
      .disposed(by: disposeBag)
  }
}
