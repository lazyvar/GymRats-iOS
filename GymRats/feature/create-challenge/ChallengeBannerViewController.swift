//
//  ChallengeBannerViewController.swift
//  GymRats
//
//  Created by mack on 4/13/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

typealias ChallengeBannerSection = SectionModel<Void, ChallengeBannerChoice>

class ChallengeBannerViewController: BindableViewController {
  private let disposeBag = DisposeBag()
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.separatorStyle = .none
      tableView.showsVerticalScrollIndicator = false
      tableView.registerCellNibForClass(ChoiceCell.self)
      tableView.delegate = self
    }
  }

  private let dataSource = RxTableViewSectionedReloadDataSource<ChallengeBannerSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    return ChoiceCell.configure(tableView: tableView, indexPath: indexPath, choice: row)
  })

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Banner image"
  }

  override func bindViewModel() {
    Observable<[ChallengeBannerSection]>
      .just([.init(model: (), items: ChallengeBannerChoice.allCases)])
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0: self?.uploadOwn()
        case 1: self?.choosePreset()
        case 2: self?.push(UIViewController())
        default: fatalError("Unhandled row.")
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func uploadOwn() {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let photoLibrary = UIAlertAction(title: "Choose from photo library", style: .default) { _ in
      imagePicker.sourceType = .photoLibrary
      self.present(imagePicker, animated: true, completion: nil)
    }
    
    let camera = UIAlertAction(title: "Take photo from camera", style: .default) { _ in
      imagePicker.sourceType = .camera
      self.present(imagePicker, animated: true, completion: nil)
    }
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alert.addAction(photoLibrary)
    alert.addAction(camera)
    alert.addAction(cancel)
    
    present(alert, animated: true, completion: nil)
  }
  
  private func choosePreset() {
    
  }
}

extension ChallengeBannerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismissSelf()

    guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else { return }
    
    
  }
}

extension ChallengeBannerViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let container = UIView().apply {
      $0.backgroundColor = .clear
      $0.constrainHeight(75)
    }
    
    let text = UILabel().apply {
      $0.text = """
      Last step is to upload an optional banner image. Pick your own or choose from one of the presets.
      """
      $0.textColor = .primaryText
      $0.font = .body
      $0.numberOfLines = 0
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    container.addSubview(text)
    
    text.fill(in: container, top: 5, bottom: -5, left: 20, right: -20)
    
    return container
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 75
  }
}
