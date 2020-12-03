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
import UnsplashPhotoPicker

typealias ChallengeBannerSection = SectionModel<Void, ChallengeBannerChoice>

class ChallengeBannerViewController: BindableViewController {
  private let disposeBag = DisposeBag()
  private var newChallenge: NewChallenge
  
  init(_ newChallenge: NewChallenge) {
    self.newChallenge = newChallenge
    
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  
    Track.screen(.challengeBanner)
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
        case 2: self?.skip()
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
  
  private func skip() {
    newChallenge.banner = nil
    
    push(EnableTeamsViewController(newChallenge), animated: true)
  }
}

extension ChallengeBannerViewController: UnsplashPhotoPickerDelegate {
  func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
    guard let photo = photos.first else { return }
    
    newChallenge.banner = .right(photo.urls[.regular]?.absoluteString ?? "")

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      self.push(EnableTeamsViewController(self.newChallenge), animated: true)
    }
  }
  
  func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) {
    // ...
  }
}

extension ChallengeBannerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismissSelf()

    guard let image = info[.originalImage] as? UIImage else { return }
    
    newChallenge.banner = .left(image)
    
    push(EnableTeamsViewController(newChallenge), animated: true)
  }
}

extension ChallengeBannerViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let container = UIView().apply {
      $0.backgroundColor = .clear
      $0.constrainHeight(60)
    }
    
    let text = UILabel().apply {
      $0.text = """
      Optionally upload a banner image. Pick your own or choose from one of the presets.
      """
      $0.textColor = .primaryText
      $0.font = .body
      $0.numberOfLines = 0
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    container.addSubview(text)
    
    text.topAnchor.constraint(equalTo: container.topAnchor, constant: 0).isActive = true
    text.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 20).isActive = true
    text.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -20).isActive = true
    
    text.sizeToFit()

    return container
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 60
  }
}
