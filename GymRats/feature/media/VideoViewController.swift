//
//  VideoViewController.swift
//  GymRats
//
//  Created by mack on 12/6/20.
//

import UIKit
import AVFoundation
import Kingfisher
import RxSwift
import AVKit
import RxGesture

class VideoViewController: UIViewController {
  private let disposeBag = DisposeBag()
  
  private let medium: Workout.Medium
  private let player: AVPlayer
  private let playerLayer: AVPlayerLayer
  private let imageView = UIImageView()
  private let videoView = UIView()
  
  var isMuted = true
  
  init(medium: Workout.Medium) {
    self.medium = medium
    
    if let url = URL(string: medium.url) {
      let asset = AVURLAsset(url: url)
      let playerItem = AVPlayerItem(asset: asset)
      
      player = AVPlayer(playerItem: playerItem)
    } else {
      player = AVPlayer()
    }

    playerLayer = AVPlayerLayer(player: player)
    playerLayer.videoGravity = .resizeAspectFill

    super.init(nibName: nil, bundle: nil)
    
    player.isMuted = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLayoutSubviews() {
    playerLayer.frame = videoView.bounds
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(imageView)

    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true

    imageView.inflate(in: view)
    videoView.inflate(in: view)
    
    if let thumbnail = medium.thumbnailUrl, let thumbnailURL = URL(string: thumbnail) {
      imageView.kf.setImage(with: thumbnailURL)
    }
    
    videoView.layer.addSublayer(playerLayer)
    
    videoView.rx.tapGesture()
      .subscribe { [self] _ in
        if player.isPlaying {
          player.pause()
        } else {
          player.play()
        }
      }
      .disposed(by: disposeBag)
    
    let expandButton = UIButton()
    expandButton.translatesAutoresizingMaskIntoConstraints = false
    expandButton.setImage(.expand, for: .normal)
    expandButton.tintColor = .primaryText
    expandButton.layer.cornerRadius = 8
    expandButton.clipsToBounds = true
    expandButton.contentEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
    expandButton.backgroundColor = UIColor.foreground.withAlphaComponent(0.75)
    expandButton.rx.tap
      .subscribe { [self] _ in
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        present(playerViewController, animated: true) { [self] in
          player.play()
        }
      }
      .disposed(by: disposeBag)
    
    videoView.addSubview(expandButton)
    
    expandButton.bottomAnchor.constraint(equalTo: videoView.bottomAnchor, constant: -10).isActive = true
    expandButton.leftAnchor.constraint(equalTo: videoView.leftAnchor, constant: 10).isActive = true

    let soundButton = UIButton()
    soundButton.translatesAutoresizingMaskIntoConstraints = false
    soundButton.setImage(.muted, for: .normal)
    soundButton.tintColor = .primaryText
    soundButton.layer.cornerRadius = 8
    soundButton.clipsToBounds = true
    soundButton.contentEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
    soundButton.backgroundColor = UIColor.foreground.withAlphaComponent(0.75)
    soundButton.rx.tap
      .subscribe { [self] _ in
        if isMuted {
          soundButton.setImage(.soundOn, for: .normal)
        } else {
          soundButton.setImage(.muted, for: .normal)
        }
        
        isMuted.toggle()
        player.isMuted = isMuted
      }
      .disposed(by: disposeBag)

    videoView.addSubview(soundButton)
    
    soundButton.bottomAnchor.constraint(equalTo: videoView.bottomAnchor, constant: -10).isActive = true
    soundButton.rightAnchor.constraint(equalTo: videoView.rightAnchor, constant: -10).isActive = true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    playFromBeginning()
    
    NotificationCenter.default.addObserver (
      self,
      selector: #selector(playerItemDidReachEnd),
      name: Notification.Name.AVPlayerItemDidPlayToEndTime,
      object: nil
    )
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    stop()
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func playerItemDidReachEnd() {
    playFromBeginning()
  }
  
  func stop() {
    guard let item = player.currentItem else { return }
    
    item.seek(to: .zero, completionHandler: nil)
    player.pause()
  }

  func playFromBeginning() {
    guard let item = player.currentItem else { return }

    item.seek(to: .zero, completionHandler: nil)
    player.play()
  }
}

extension AVPlayer {
  var isPlaying: Bool {
    return rate != 0 && error == nil
  }
}
