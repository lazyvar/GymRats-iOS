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

  private let disposeBag = DisposeBag()
  
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
      return tableView.dequeueReusableCell(withType: UserProfileCell.self, for: indexPath).apply {
        $0.textLabel?.font = .bodyBold
        $0.backgroundColor = .clear
        $0.imageView?.tintColor = .white
        $0.textLabel?.textColor = .white
        $0.textLabel?.text = "Home"
        $0.imageView?.image = UIImage(named: "activity")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
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

extension MenuViewController: CreateChallengeDelegate {
  func challengeCreated(challenge: Challenge) {
    
  }
}

//UserDefaults.standard.set(challenge.id, forKey: "last_opened_challenge")
//
//if let nav = GymRatsApp.coordinator.drawer.centerViewController as? UINavigationController {
//    if let home = nav.children.first as? HomeViewController {
//        // home.fetchAllChallenges()
//
//        GymRatsApp.coordinator.drawer.closeDrawer(animated: true, completion: nil)
//    } else {
//        let center = HomeViewController()
//        let nav = UINavigationController(rootViewController: center)
//
//        GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
//    }
//} else {
//    let center = HomeViewController()
//    let nav = UINavigationController(rootViewController: center)
//
//    GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
//}
//
//override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    tableView.deselectRow(at: indexPath, animated: true)
//
//    if indexPath.section == 0 {
//        let profile = ProfileViewController(user: GymRats.currentAccount, challenge: nil)
//        let nav = UINavigationController(rootViewController: profile)
//
//        profile.setupMenuButton()
//        profile.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"), style: .plain, target: profile, action: #selector(ProfileViewController.transitionToSettings))
//
//        GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
//    } else if indexPath.section == 1 {
//        if activeChallenges.count == 0 {
//            let center = HomeViewController()
//            let nav = UINavigationController(rootViewController: center)
//
//            GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
//
//            return
//        }
//        let challenge = activeChallenges[indexPath.row]
//
//        UserDefaults.standard.set(challenge.id, forKey: "last_opened_challenge")
//
//        GymRatsApp.coordinator.centerActiveOrUpcomingChallenge(challenge)
//    } else if indexPath.section == 2 {
//        switch indexPath.row {
//        case 0:
//            let archived = ArchivedChallengesTableViewController().inNav()
//
//            GymRatsApp.coordinator.drawer.setCenterView(archived, withCloseAnimation: true, completion: nil)
//        case 1:
//            JoinChallenge.presentJoinChallengeModal(on: self)
//                .subscribe(onNext: { _ in
//                    if let nav = GymRatsApp.coordinator.drawer.centerViewController as? UINavigationController {
//                        if let home = nav.children.first as? HomeViewController {
//                            // home.fetchAllChallenges()
//
//                            GymRatsApp.coordinator.drawer.closeDrawer(animated: true, completion: nil)
//                        } else {
//                            let center = HomeViewController()
//                            let nav = UINavigationController(rootViewController: center)
//
//                            GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
//                        }
//                    } else {
//                        let center = HomeViewController()
//                        let nav = UINavigationController(rootViewController: center)
//
//                        GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
//                    }
//                }, onError: { [weak self] error in
//                    self?.presentAlert(with: error)
//                }).disposed(by: self.disposeBag)
//        case 2:
//            let createChallengeViewController = CreateChallengeViewController()
//            createChallengeViewController.delegate = self
//
//            let nav = UINavigationController(rootViewController: createChallengeViewController)
//            nav.navigationBar.turnSolidWhiteSlightShadow()
//
//            self.present(nav, animated: true, completion: nil)
//        case 3:
//            let settings = SettingsViewController()
//            settings.setupMenuButton()
//
//            GymRatsApp.coordinator.drawer.setCenterView(settings.inNav(), withCloseAnimation: true, completion: nil)
//        case 4:
//            let center = AboutViewController()
//            let nav = UINavigationController(rootViewController: center)
//
//            GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
//        default:
//            break
//        }
//    }
//}
