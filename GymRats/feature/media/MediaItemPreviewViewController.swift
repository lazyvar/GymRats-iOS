//
//  MediaItemPreviewViewController.swift
//  GymRats
//
//  Created by mack on 12/16/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import YPImagePicker
import AVFoundation
import RxSwift

class MediaItemPreviewViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let items: [YPMediaItem]
  
  private weak var videoView: UIView?
  private weak var playerLayer: AVPlayerLayer?

  var onAcceptance: ((MediaItemPreviewViewController) -> Void)?
  var isMuted = false

  init(items: [YPMediaItem]) {
    self.items = items
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupBackButton()
    
    view.backgroundColor = .background
    
    let cancelButton = UIButton()
    let acceptButton = UIButton()

    cancelButton.translatesAutoresizingMaskIntoConstraints = false
    acceptButton.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(cancelButton)
    view.addSubview(acceptButton)
    
    cancelButton.setImage(.close, for: .normal)
    cancelButton.tintColor = .primaryText
    cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
    cancelButton.constrainHeight(144)
    cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 20).isActive = true
    cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    cancelButton.rx.tap
      .subscribe { [self] _ in
        navigationController?.popViewController(animated: false)
      }
      .disposed(by: disposeBag)

    acceptButton.setImage(.checkTemplate, for: .normal)
    acceptButton.tintColor = .primaryText
    acceptButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
    acceptButton.constrainHeight(144)
    acceptButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 20).isActive = true
    acceptButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    acceptButton.rx.tap
      .subscribe { [self] _ in
        onAcceptance?(self)
      }
      .disposed(by: disposeBag)

    if let photo = items.singlePhoto {
      let imageView = UIImageView(image: photo.image)
      imageView.contentMode = .scaleAspectFill
      imageView.translatesAutoresizingMaskIntoConstraints = false
      
      view.addSubview(imageView)
      
      imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
      imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
      imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
      imageView.bottomAnchor.constraint(equalTo: acceptButton.topAnchor).isActive = true
    }
    
    if let video = items.singleVideo {
      let videoView = UIView()
      videoView.backgroundColor = .foreground
      videoView.translatesAutoresizingMaskIntoConstraints = false
      
      view.addSubview(videoView)
      
      videoView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
      videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
      videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
      videoView.bottomAnchor.constraint(equalTo: acceptButton.topAnchor).isActive = true
      
      let asset = AVURLAsset(url: video.url)
      let playerItem = AVPlayerItem(asset: asset)
      let player = AVPlayer(playerItem: playerItem)
      
      let playerLayer = AVPlayerLayer(player: player)
      playerLayer.videoGravity = .resizeAspectFill
      
      videoView.layer.addSublayer(playerLayer)
      
      self.videoView = videoView
      self.playerLayer = playerLayer
            
      player.play()
      
      let soundButton = UIButton()
      soundButton.translatesAutoresizingMaskIntoConstraints = false
      soundButton.setImage(.soundOn, for: .normal)
      soundButton.tintColor = .primaryText
      soundButton.layer.cornerRadius = 15
      soundButton.clipsToBounds = true
      soundButton.contentEdgeInsets = .init(top: 7, left: 7, bottom: 7, right: 7)
      soundButton.constrainWidth(30)
      soundButton.constrainHeight(30)
      soundButton.backgroundColor = UIColor.foreground.withAlphaComponent(0.8)
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
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let playerLayer = playerLayer {
      NotificationCenter.default.addObserver (
        self,
        selector: #selector(playerItemDidReachEnd),
        name: Notification.Name.AVPlayerItemDidPlayToEndTime,
        object: nil
      )

      playerLayer.player?.play()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    NotificationCenter.default.removeObserver(self)
    playerLayer?.player?.pause()
  }
  
  override func viewDidLayoutSubviews() {
    if let videoView = videoView {
      playerLayer?.frame = videoView.bounds
    }
  }
  
  @objc private func playerItemDidReachEnd() {
    guard let player = playerLayer?.player else { return }

    player.currentItem?.seek(to: .zero, completionHandler: nil)
    player.play()
  }
}
