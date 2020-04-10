//
//  UpcomingChallengeViewController.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift

enum UpcomingChallengeRow {
  case banner(Challenge)
  case account(Account)
  case invite(Challenge)
}

typealias UpcomingChallengeSection = SectionModel<String, UpcomingChallengeRow>

class UpcomingChallengeViewController: BindableViewController {
  private let viewModel = UpcomingChallengeViewModel()
  private let disposeBag = DisposeBag()
  private let challenge: Challenge
  
  init(challenge: Challenge) {
    self.challenge = challenge
    self.viewModel.configure(challenge: challenge)

    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @IBOutlet private weak var collectionView: UICollectionView! {
    didSet {
      collectionView.backgroundColor = .background
      collectionView.registerCellNibForClass(AccountCell.self)
      collectionView.registerCellNibForClass(InviteCell.self)
      collectionView.setCollectionViewLayout(UpcomingChallengeFlowLayout(), animated: false)
      collectionView.delegate = self
    }
  }

  private let dataSource = RxCollectionViewSectionedReloadDataSource<UpcomingChallengeSection>(configureCell: { _, collectionView, indexPath, row -> UICollectionViewCell in
    switch row {
    case .account(let account): return AccountCell.configure(collectionView: collectionView, indexPath: indexPath, account: account)
    case .banner(let challenge): return UICollectionViewCell()
    case .invite(let challenge): return InviteCell.configure(collectionView: collectionView, indexPath: indexPath)
    }
  })
  
  override func viewDidLoad() {
    super.viewDidLoad()

    title = challenge.name
    
    viewModel.input.viewDidLoad.trigger()
  }
  
  override func bindViewModel() {
    viewModel.output.error
      .do(onNext: { _ in self.hideLoadingBar() })
      .flatMap { UIAlertController.present($0) }
      .ignore(disposedBy: disposeBag)

    viewModel.output.navigation
      .subscribe(onNext: { [weak self] (navigation, screen) in
        self?.navigate(navigation, to: screen.viewController)
      })
      .disposed(by: disposeBag)

    viewModel.output.sections
      .bind(to: collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
}

extension UpcomingChallengeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
      
    viewModel.input.selectedItem.onNext(indexPath)
  }
}
