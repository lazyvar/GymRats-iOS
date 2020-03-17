//
//  ChallengeTabBarController.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class ChallengeTabBarController: ESTabBarController {

  // MARK: Init

  private let challenge: Challenge
  private let challengeViewController: ChallengeViewController

  init(challenge: Challenge) {
    self.challenge = challenge
    self.challengeViewController = ChallengeViewController(challenge: challenge)
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewControllers = [
      UIViewController().apply {
        $0.tabBarItem = UITabBarItem(title: nil, image: .standings, selectedImage: .standings)
      },
      challengeViewController.inNav().apply {
        $0.tabBarItem = ESTabBarItem(BigContentView(), title: nil, image: .activityLargeWhite, selectedImage: .activityLargeWhite)
      },
      UIViewController().apply {
        $0.tabBarItem = UITabBarItem(title: nil, image: .chatGray, selectedImage: .chatGray)
        $0.tabBarItem?.badgeColor = .brand
      }
    ]
    
    configureTabBar()
    selectedIndex = 1
    didHijackHandler = hijack
    shouldHijackHandler = { _, _, _ in return true }
  }
}

private extension ChallengeTabBarController {

  private func hijack(tabBar: UITabBarController, viewController: UIViewController, index: Int) {
    switch index {
    case 0: pushStats()
    case 1: presentCreateWorkout()
    case 2: pushChat()
    default: fatalError("Unexpected index.")
    }
  }
  
  private func pushStats() {
    challengeViewController.push(
      ChallengeStatsViewController(challenge: challenge, members: [], workouts: [])
    )
  }
  
  private func presentCreateWorkout() {
    WorkoutFlow.logWorkout()
  }
  
  private func pushChat() {
    challengeViewController.push(
      ChatViewController(challenge: challenge)
    )
  }
  
  private func configureTabBar() {
    let pxWhiteThing = UIView(frame: CGRect(x: 0, y: -1, width: tabBar.frame.width, height: 1)).apply {
      $0.backgroundColor = .background
    }

    tabBar.isTranslucent = false
    tabBar.shadowImage = UIImage()
    tabBar.backgroundImage = UIImage()
    tabBar.layer.shadowOffset = .zero
    tabBar.layer.shadowRadius = 10
    tabBar.layer.shadowColor = UIColor.shadow.cgColor
    tabBar.layer.shadowOpacity = 0.5
    tabBar.barTintColor = .background
    tabBar.addSubview(pxWhiteThing)
    tabBar.sendSubviewToBack(pxWhiteThing)
  }
}

//    var chatItem: UITabBarItem? {
//      return tabBarViewController?.tabBar.items?[safe: 2]
//    }
//
//    @objc func refreshChatIcon() {
////        guard let challenge = artistViewController?.challenge else { return }
//
////        gymRatsAPI.getUnreadChats(for: challenge)
////            .subscribe { event in
////                switch event {
////                case .next(let chats):
////                  guard let chats = chats.object else { return }
////                    if chats.isEmpty {
////                        self.chatItem?.badgeValue = nil
////                    } else {
////                        self.chatItem?.badgeValue = String(chats.count)
////                    }
////                default: break
////                }
////            }.disposed(by: disposeBag)
//    }
//
//func proPicImage(_ image: UIImage) -> UIImage {
//    let imageView = UIImageView(frame: .init(x: 0, y: 0, width: 27, height: 27))
//    imageView.layer.cornerRadius = 13.5
//    imageView.image = image
//    imageView.clipsToBounds = true
//    imageView.contentMode = .scaleAspectFill
//
//    let ringView = RingView(frame: .zero, ringWidth: 0.5, ringColor: UIColor.black.withAlphaComponent(0.1))
//
//    imageView.addSubview(ringView)
//
//    let frame = imageView.frame
//    let scale: CGFloat = 1.16
//    let newWidth = frame.width * scale
//    let newHeight = frame.height * scale
//
//    let diffY = newWidth - frame.width
//    let diffX = newHeight - frame.height
//
//    ringView.frame = CGRect(x: -diffX/2, y: -diffY/2, width: newWidth, height: newHeight)
//
//    return imageView.imageFromContext().withRenderingMode(.alwaysOriginal)
//}
//
//func updateUser(_ user: Account) {
//    self.currentUser = user
//
//    Track.currentUser()
//
//    NotificationCenter.default.post(name: .updatedCurrentUser, object: user)
//
//    // update pic on tab
//    if let proPicUrl = user.pictureUrl, let url = URL(string: proPicUrl) {
//        KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { image, _, _, _ in
//            if let image = image {
//                let proPicImage = self.proPicImage(image)
//                NotificationCenter.default.post(name: .updatedCurrentUserPic, object: image)
//                if let tabBar = self.tabBarViewController, let first = tabBar.viewControllers?.first {
//                    first.tabBarItem = UITabBarItem(title: nil, image: proPicImage, selectedImage: proPicImage)
//                }
//            }
//        }
//    }
//
//    if let artist = artistViewController {
//        // artist.fetchUserWorkouts()
//    }
//
//    switch Keychain.gymRats.storeObject(user, forKey: .currentUser) {
//    case .success:
//        print("Woohoo!")
//    case .error(let error):
//        print("Bummer! \(error.description)")
//    }
//}
