//
//  MediaPageViewController.swift
//  TestSlider
//
//  Created by mack on 12/6/20.
//

import UIKit
import RxGesture
import RxSwift

class MediaPageViewController: UIPageViewController {
  private let disposeBag = DisposeBag()
  private let mediaViewControllers: [UIViewController]
  private let pageControl = UIPageControl()

  init(media: [Workout.Medium]) {
    mediaViewControllers = media.map { medium in
      switch medium.mediumType {
      case .image: return ImageViewController(medium: medium)
      case .video: return VideoViewController(medium: medium)
      }
    }
    
    super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    delegate = self
    dataSource = self
    
    if let first = mediaViewControllers.first {
      setViewControllers([first], direction: .forward, animated: true, completion: nil)
    }
    
    if mediaViewControllers.count > 1 {
      pageControl.translatesAutoresizingMaskIntoConstraints = false
      pageControl.numberOfPages = mediaViewControllers.count
      
      view.addSubview(pageControl)
      
      pageControl.rx.tapGesture()
        .subscribe { [self] _ in
          let direction: NavigationDirection = pageControl.currentPage < (currentIndex ?? 0) ? .reverse : .forward
          
          setViewControllers([mediaViewControllers[pageControl.currentPage]], direction: direction, animated: true, completion: nil)
        }
        .disposed(by: disposeBag)
      
      pageControl.constrainHeight(40)
      pageControl.horizontallyCenter(in: view)
      pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
  }
  
  var currentIndex: Int? {
    guard let vc = viewControllers?.first else { return nil }
    guard let index = mediaViewControllers.firstIndex(of: vc) else { return nil }

    return index
  }
}

extension MediaPageViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    pageControl.currentPage = currentIndex ?? 0
  }
}

extension MediaPageViewController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let index = mediaViewControllers.firstIndex(of: viewController)?.advanced(by: -1) else { return nil }
    
    print("before \(index)")
    
    return mediaViewControllers[safe: index]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let index = mediaViewControllers.firstIndex(of: viewController)?.advanced(by: 1) else { return nil }

    print("after \(index)")
    
    return mediaViewControllers[safe: index]
  }
}
