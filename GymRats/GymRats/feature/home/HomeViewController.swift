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
  
    view.backgroundColor = .background
    viewModel.input.viewDidLoad.trigger()
  }
  
  override func bindViewModel() {
    viewModel.output.error
      .debug()
      .flatMap { UIAlertController.present($0) }
      .ignore(disposedBy: disposeBag)
    
    viewModel.output.replaceCenter
      .next { [weak self] screen in
        self?.mm_drawerController.setCenterView(screen.viewController, withFullCloseAnimation: false, completion: nil)
      }
      .disposed(by: disposeBag)
  }
}
