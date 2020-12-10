//
//  LogWorkoutModalViewController.swift
//  GymRats
//
//  Created by mack on 1/5/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import PanModal
import HealthKit
import RxSwift
import YPImagePicker

protocol LogWorkoutModalViewControllerDelegate: class {
  func didImportSteps(_ logWorkoutModalViewController: LogWorkoutModalViewController, steps: StepCount)
  func didImportWorkout(_ logWorkoutModalViewController: LogWorkoutModalViewController, workout: HKWorkout)
  func didPickMedia(_ logWorkoutModalViewController: LogWorkoutModalViewController, media: [YPMediaItem])
}

class LogWorkoutModalViewController: UIViewController, UINavigationControllerDelegate {
  private enum Constant {
    static let id = "TitleCellId"
  }
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.allowsSelection = false
      tableView.separatorStyle = .none
      tableView.backgroundColor = .background
      tableView.registerCellNibForClass(SecondaryButtonTableViewCell.self)
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constant.id)
    }
  }
  
  private let disposeBag = DisposeBag()
  private let healthService: HealthServiceType = HealthService.shared

  weak var delegate: LogWorkoutModalViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .background
  }
  
  @objc private func healthAppTapped() {
    healthService.requestWorkoutAuthorization()
      .subscribe(onSuccess: { _ in
        DispatchQueue.main.async {
          let importWorkoutViewController = ImportWorkoutViewController()
          importWorkoutViewController.delegate = self
          
          self.presentInNav(importWorkoutViewController)
        }
      }, onError: { error in
        DispatchQueue.main.async {
          let importWorkoutViewController = ImportWorkoutViewController()
          importWorkoutViewController.delegate = self
          
          self.presentInNav(importWorkoutViewController)
        }
      })
      .disposed(by: disposeBag)
  }

  @objc private func photoOrVideoTapped() {
    let picker = YPImagePicker()
    picker.didFinishPicking { [self] items, cancelled in
      picker.dismiss(animated: true) {
        if !cancelled {
          self.delegate?.didPickMedia(self, media: items)
        }
      }
    }
    
    present(picker, animated: true, completion: nil)
  }
}

extension LogWorkoutModalViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 4
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.row {
    case 0:
      let cell = tableView.dequeueReusableCell(withIdentifier: Constant.id, for: indexPath)
      cell.textLabel?.text = "Log workout"
      cell.textLabel?.font = .h4
      cell.textLabel?.textColor = .primaryText
      cell.selectionStyle = .none
      cell.backgroundColor = .clear
      cell.contentView.backgroundColor = .clear
      
      return cell
    case 1:
      let cell = tableView.dequeueReusableCell(withType: SecondaryButtonTableViewCell.self, for: indexPath)
      cell.button.addTarget(self, action: #selector(healthAppTapped), for: .touchUpInside)
      cell.button.setTitle("Health app", for: .normal)
      cell.button.setImage(.heart, for: .normal)
      cell.selectionStyle = .none

      return cell
    case 2:
      let cell = tableView.dequeueReusableCell(withType: SecondaryButtonTableViewCell.self, for: indexPath)
      cell.button.addTarget(self, action: #selector(photoOrVideoTapped), for: .touchUpInside)
      cell.button.setTitle("Photo or video", for: .normal)
      cell.button.setImage(.image, for: .normal)
      cell.selectionStyle = .none

      return cell
    case 3:
      return UITableViewCell().apply {
        $0.isUserInteractionEnabled = false
        $0.selectionStyle = .none
        $0.backgroundColor = .clear
        $0.contentView.backgroundColor = .clear
      }
    default:
      fatalError()
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.row == 3 {
      return 20
    } else {
      return UITableView.automaticDimension
    }
  }
}

extension LogWorkoutModalViewController: ImportWorkoutViewControllerDelegate {
  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, importedSteps steps: StepCount) {
    importWorkoutViewController.dismiss(animated: true) { [self] in
      delegate?.didImportSteps(self, steps: steps)
    }
  }

  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, imported workout: HKWorkout) {
    importWorkoutViewController.dismiss(animated: true) { [self] in
      delegate?.didImportWorkout(self, workout: workout)
    }
  }
}

extension LogWorkoutModalViewController: PanModalPresentable {
  var panScrollable: UIScrollView? {
    return tableView
  }
  
  var showDragIndicator: Bool {
    return false
  }
}
