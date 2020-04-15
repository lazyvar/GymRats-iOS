//
//  ChangeBannerViewController.swift
//  GymRats
//
//  Created by mack on 4/15/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import UnsplashPhotoPicker

class ChangeBannerViewController: BindableViewController {
  private let disposeBag = DisposeBag()
  private var challenge: Challenge
  
  init(challenge: Challenge) {
    self.challenge = challenge
    
    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.backgroundColor = .background
      tableView.separatorStyle = .none
      tableView.showsVerticalScrollIndicator = false
      tableView.registerCellNibForClass(ChoiceCell.self)
    }
  }

  private let dataSource = RxTableViewSectionedReloadDataSource<ChallengeBannerSection>(configureCell: { _, tableView, indexPath, row -> UITableViewCell in
    return ChoiceCell.configureForChange(tableView: tableView, indexPath: indexPath, choice: row)
  })

  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: .close, style: .plain, target: self, action: #selector(dismissSelf))
    
    title = "Change banner image"
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
        case 2: self?.remove()
        default: fatalError("Unhandled row.")
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func uploadOwn() {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let photoLibrary = UIAlertAction(title: "Photo library", style: .default) { _ in
      imagePicker.sourceType = .photoLibrary
      self.present(imagePicker, animated: true, completion: nil)
    }
    
    let camera = UIAlertAction(title: "Camera", style: .default) { _ in
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
    let configuration = UnsplashPhotoPickerConfiguration(
      accessKey: Secrets.Unsplash.accessKey,
      secretKey: Secrets.Unsplash.secretKey,
      allowsMultipleSelection: false
    )
    
    let unsplashPhotoPicker = UnsplashPhotoPicker(configuration: configuration)
    unsplashPhotoPicker.photoPickerDelegate = self

    present(unsplashPhotoPicker, animated: true, completion: nil)
  }
  
  private func remove() {
    changeBanner(to: nil)
  }
  
  private func changeBanner(to imageOrURL: Either<UIImage, String>?) {
    showLoadingBar()
    
    gymRatsAPI.changeBanner(challenge: challenge, imageOrURL: imageOrURL)
      .subscribe(onNext: { [weak self] result in
        self?.hideLoadingBar()
        
        switch result {
        case .success:
          self?.dismissSelf()
        case .failure(let error):
          self?.presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)
  }
}

extension ChangeBannerViewController: UnsplashPhotoPickerDelegate {
  func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
    guard let photo = photos.first else { return }

    changeBanner(to: .right(photo.urls[.regular]?.absoluteString ?? ""))
  }
  
  func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) {
    // ...
  }
}

extension ChangeBannerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismissSelf()

    guard let image = info[.originalImage] as? UIImage else { return }

    changeBanner(to: .left(image))
  }
}
