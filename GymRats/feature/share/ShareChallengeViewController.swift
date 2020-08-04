//
//  ShareChallengeViewController.swift
//  GymRats
//
//  Created by mack on 8/3/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import NVActivityIndicatorView
import Kingfisher

class ShareChallengeViewController: UIViewController {
  private let challenge: Challenge
  private let disposeBag = DisposeBag()
  private var allWorkouts: [Workout] = []
  private var selectedWorkouts: [Workout] = [] {
    didSet {
      fetchSelectedWorkouts()
    }
  }
  
  private var selectedGridSize = ShareChallengeView.Size.allCases.count - 1
  private var shareChallengeView: ShareChallengeView!
  private lazy var picker: UIPickerView = {
    let picker = UIPickerView()
    picker.delegate = self
    picker.dataSource = self
    
    return picker
  }()
  
  @IBOutlet private weak var preview: UIView! {
    didSet {
      preview.layer.cornerRadius = 4
      preview.clipsToBounds = true
    }
  }

  @IBOutlet private weak var previewImageView: UIImageView!
  
  @IBOutlet private weak var gridSizeTextField: UITextField! {
    didSet {
      gridSizeTextField.inputView = picker
      gridSizeTextField.textColor = .primaryText
      gridSizeTextField.font = .body
      let toolBar = UIToolbar()
      toolBar.barStyle = .default
      toolBar.isTranslucent = true
      toolBar.tintColor = .brand
      toolBar.sizeToFit()

      let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(donePicker))
      let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
      let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelPicker))

      toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
      toolBar.isUserInteractionEnabled = true
      
      gridSizeTextField.inputAccessoryView = toolBar
    }
  }
  
  @IBOutlet private weak var numberOfWorkoutsHeader: UILabel! {
    didSet {
      numberOfWorkoutsHeader.font = .h4
      numberOfWorkoutsHeader.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var shuffleButton: SecondaryButton! {
    didSet {
      shuffleButton.tintColor = .primaryText
    }
  }

  @IBOutlet private weak var loadingBackground: UIView! {
    didSet {
      loadingBackground.backgroundColor = .asbestos
      loadingBackground.isSkeletonable = true
      loadingBackground.showAnimatedSkeleton()
      
      let spinner = NVActivityIndicatorView(frame: .init(x: 0, y: 0, width: 100, height: 100), type: .ballPulseSync, color: .brand, padding: 20)
      spinner.translatesAutoresizingMaskIntoConstraints = false
      spinner.startAnimating()
      
      loadingBackground.addSubview(spinner)
      
      spinner.center(in: loadingBackground)
      spinner.constrainWidth(100)
      spinner.constrainHeight(100)
    }
  }

  init(challenge: Challenge) {
    self.challenge = challenge
    
    super.init(nibName: Self.xibName, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    shareChallengeView = ShareChallengeView(frame: CGRect(x: 1000, y: 1000, width: 600, height: 600))
    shareChallengeView.challenge = challenge
    
    navigationItem.largeTitleDisplayMode = .never
    view.backgroundColor = .background
    view.addSubview(shareChallengeView)
    
    Observable.combineLatest(gymRatsAPI.getAllWorkouts(for: challenge), gymRatsAPI.challengeInfo(challenge))
      .subscribe(onNext: { [weak self] a, b in
        guard let self = self else { return }
        guard let workouts = a.object, let challengeInfo = b.object else { self.presentAlert(with: (a.error ?? b.error)!); return }

        self.shareChallengeView.size = ShareChallengeView.Size(rawValue: min(Int(sqrt(Double(workouts.count))), 7)) ?? .four
        self.gridSizeTextField.text = "\(self.shareChallengeView.size.rawValue)"
        self.selectedGridSize = ShareChallengeView.Size.allCases.firstIndex(of: self.shareChallengeView.size)!
        self.picker.selectRow(ShareChallengeView.Size.allCases.firstIndex(of: self.shareChallengeView.size)!, inComponent: 0, animated: false)
        self.shareChallengeView.memberCount = challengeInfo.memberCount
        self.shareChallengeView.score = "\(workouts.count) workouts"
        self.shareChallengeView.days = self.challenge.days.count
        self.allWorkouts = workouts
        self.selectedWorkouts = Array(self.allWorkouts.shuffled().prefix(self.shareChallengeView.size.total))
      })
      .disposed(by: disposeBag)
  }

  private func fetchSelectedWorkouts() {
    KingfisherManager.shared.cache.clearMemoryCache()
    shuffleButton.isEnabled = false
    shuffleButton.isUserInteractionEnabled = false
    
    UIView.animate(withDuration: 0.1) {
      self.loadingBackground.alpha = 1
      self.shareChallengeView.workoutImages = []
    }

    Observable.merge(self.selectedWorkouts.map { self.fetchImage(from: $0) })
      .toArray()
      .subscribe(onSuccess: { [weak self] images in
        guard let self = self else { return }
        
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          
          self.shareChallengeView.workoutImages = images.compactMap { $0 }

          DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            UIView.animate(withDuration: 0.1, animations:  {
              self.loadingBackground.alpha = 0
              self.previewImageView.image = self.shareChallengeView.imageFromContext()
            }, completion: { _ in
              self.shuffleButton.isEnabled = true
              self.shuffleButton.isUserInteractionEnabled = true
            })
          }
        }
      }, onError: { _ in
        // ...
      })
      .disposed(by: self.disposeBag)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
    KingfisherManager.shared.cache.clearMemoryCache()
  }
  
  @objc private func donePicker() {
    view.endEditing(true)
    
    shareChallengeView.size = ShareChallengeView.Size.allCases[selectedGridSize]
    gridSizeTextField.text = "\(shareChallengeView.size.rawValue)"
    selectedWorkouts = Array(allWorkouts.shuffled().prefix(shareChallengeView.size.total))
  }
  
  @objc private func cancelPicker() {
    view.endEditing(true)
    
    picker.selectRow(ShareChallengeView.Size.allCases.firstIndex(of: self.shareChallengeView.size)!, inComponent: 0, animated: false)
    selectedGridSize = ShareChallengeView.Size.allCases.firstIndex(of: self.shareChallengeView.size)!
  }

  private func fetchImage(from workout: Workout) -> Observable<UIImage?> {
    return Observable.create { subscriber -> Disposable in
      DispatchQueue.global().async {
        guard let photoUrl = workout.photoUrl, let url = URL(string: photoUrl) else {
          subscriber.on(.next(nil))
          subscriber.onCompleted()
          
          return
        }
        
        KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { image, _, _, _ in
          subscriber.on(.next(image))
          subscriber.onCompleted()
        }
      }
      
      return Disposables.create()
    }
  }
  
  @IBAction private func share(_ sender: Any) {
    let previewImage = shareChallengeView.imageFromContext()
    let activityViewController = UIActivityViewController(activityItems: [previewImage as Any], applicationActivities: nil)
    
    present(activityViewController, animated: true)
  }
  
  @IBAction private func shuffle(_ sender: Any) {
    self.selectedWorkouts = Array(self.allWorkouts.shuffled().prefix(self.shareChallengeView.size.total))
  }
}

extension ShareChallengeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return ShareChallengeView.Size.allCases.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return "\(ShareChallengeView.Size.allCases[row].rawValue)"
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedGridSize = row
  }
}
