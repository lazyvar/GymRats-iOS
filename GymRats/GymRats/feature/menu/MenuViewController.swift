//
//  MenuViewController.swift
//  GymRats
//
//  Created by mack on 3/12/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

typealias MenuSection = SectionModel<Bool, MenuRow>

class MenuViewController: BindableViewController {

  static let width: CGFloat = { UIScreen.main.bounds.width - 133 }()

  private let viewModel = MenuViewModel()
  private let disposeBag = DisposeBag()

  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.rx.setDelegate(self).disposed(by: disposeBag)
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
      tableView.registerCellNibForClass(UserProfileCell.self)
      tableView.registerCellNibForClass(ItemCell.self)
      tableView.separatorStyle = .none
      tableView.backgroundColor = .brand
      tableView.rx.itemSelected
        .do(onNext: { [weak self] indexPath in
          self?.tableView.deselectRow(at: indexPath, animated: true)
        })
        .bind(to: viewModel.input.tappedRow)
        .disposed(by: disposeBag)
    }
  }
  
  private let dataSource = RxTableViewSectionedReloadDataSource<MenuSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    switch row {
    case .profile(let account):
      return UserProfileCell.configure(tableView: tableView, indexPath: indexPath, account: account)
    case .challenge(let challenge):
      return ItemCell.configure(tableView: tableView, indexPath: indexPath, challenge: challenge)
    case .item(let item):
      return tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath).apply {
        $0.textLabel?.font = .bodyBold
        $0.backgroundColor = .clear
        $0.imageView?.tintColor = .white
        $0.textLabel?.textColor = .white
        $0.textLabel?.text = item.title
        $0.imageView?.image = item.image
      }
    case .home:
      return tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath).apply {
        $0.textLabel?.font = .bodyBold
        $0.backgroundColor = .clear
        $0.imageView?.tintColor = .white
        $0.textLabel?.textColor = .white
        $0.textLabel?.text = "Home"
        $0.imageView?.image = .activity
      }
    }
  })

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .brand
    
    viewModel.input.viewDidLoad.trigger()
  }
  
  override func bindViewModel() {
    viewModel.output.sections
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    viewModel.output.navigation
      .subscribe(onNext: { [weak self] (navigation, screen) in
        self?.navigate(navigation, to: screen.viewController)
      })
      .disposed(by: disposeBag)
  }
}

extension MenuViewController: UITableViewDelegate {
    
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard dataSource.sectionModels.indices.contains(section), dataSource[section].model else { return nil }
    
    return UIView().apply {
      $0.backgroundColor = .brand
      $0.constrainHeight(section == 2 ? 20 : .zero)
    }
  }
    
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard dataSource.sectionModels.indices.contains(section), dataSource[section].model else { return .zero }

    return 25
  }
}
