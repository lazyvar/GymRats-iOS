//
//  ChatViewController.swift
//  GymRats
//
//  Created by mack on 3/15/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import MessageKit
import RxSwift
import SwiftPhoenixClient
import InputBarAccessoryView
import ImageViewer_swift

class ChatViewController: MessagesViewController {
  private let challenge: Challenge
  private let socket: Socket
  private var channel: Channel!
  private var chats: [ChatMessage] = []
  private let disposeBag = DisposeBag()
  private var currentPage = 0
  private var canLoadMorePosts = true
  private var loading = true
  private var retries = 3

  init(challenge: Challenge) {
    self.challenge = challenge
    self.socket = Socket(GymRats.environment.ws, params: ["token": GymRats.currentAccount.token ?? ""])
    
    super.init(nibName: nil, bundle: nil)

    self.socket.onOpen { self.onSocketOpen() }
    self.socket.onError { error in
      print("Error connecting to socket: \(error)")
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    
    return formatter
  }()

  private let noChatLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .details
    label.text = "No chat messages to display."
    label.textColor = .secondaryText
    label.isHidden = true
    
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .background
    messagesCollectionView.backgroundColor = .background
    title = challenge.name

    view.addSubview(noChatLabel)
    
    noChatLabel.center(in: view)
    
    navigationItem.largeTitleDisplayMode = .never
    
    setupBackButton()
    
    scrollsToBottomOnKeyboardBeginsEditing = true
    messageInputBar.tintColor = .brand
    messageInputBar.backgroundView.backgroundColor = .background
    messageInputBar.sendButton.setTitleColor(.brand, for: .normal)
    messageInputBar.sendButton.setTitleColor(.brand, for: .highlighted)
    messageInputBar.delegate = self

    let photoButton = InputBarButtonItem()
      .configure {
        $0.spacing = .fixed(10)
        $0.image = .photoLibrary
        $0.setSize(CGSize(width: 25, height: 25), animated: false)
        $0.tintColor = .primaryText
      }.onSelected {
        $0.tintColor = .brand
      }.onDeselected {
        $0.tintColor = .primaryText
      }.onTouchUpInside { _ in
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
      }
    
    messageInputBar.setStackViewItems([photoButton, .flexibleSpace], forStack: .bottom, animated: false)
    
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messageCellDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    
    NotificationCenter.default.addObserver(self, selector: #selector(appEnteredForeground), name: .appEnteredForeground, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(disconnectSocket), name: .appEnteredBackground, object: nil)

    messagesCollectionView.alpha = 0
    
    refresh()
    
    messagesCollectionView.rx.contentOffset
      .subscribe(onNext: { [unowned self] offset in
        if offset.y < 0 && !self.loading {
          self.loading = true
          self.loadNextPage()
        }
      })
      .disposed(by: disposeBag)
    
    gymRatsAPI.seeChatNotifications(for: challenge)
      .ignore(disposedBy: disposeBag)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  
    Track.screen(.chat)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    NotificationCenter.default.post(name: .sawChat, object: challenge)
    connectSocket()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    disconnectSocket()
  }
  
  @objc private func appEnteredForeground() {
    // 😭
    if UIViewController.topmost() == self {
      refresh()
      connectSocket()
    }
  }
  
  @objc private func connectSocket() {
    socket.connect()
  }
  
  @objc private func disconnectSocket() {
    channel?.leave()
    socket.disconnect()
  }

  @objc private func refresh() {
    canLoadMorePosts = true
    showLoadingBar()
    loadChats(page: 0, clear: true)
  }
    
  private func loadNextPage() {
    loadChats(page: currentPage + 1)
  }

  private func loadChats(page: Int, clear: Bool = false) {
    guard canLoadMorePosts else { return }
            
    gymRatsAPI.getChatMessages(for: challenge, page: page)
      .subscribe(onNext: { [weak self] result in
        guard let self = self else { return }
        
        self.hideLoadingBar()
        
        switch result {
        case .success(let messages):
          self.handleFetchResponse(loadedMessages: messages, page: page, clear: clear)
        case .failure(let error):
          self.presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)
  }

  private func handleFetchResponse(loadedMessages: [ChatMessage], page: Int, clear: Bool) {
    let beforeContentSize = messagesCollectionView.contentSize

    if loadedMessages.isEmpty {
      canLoadMorePosts = false
        
      if page > 0 { return }
    }
    
    if clear { chats = [] }
    
    noChatLabel.isHidden = page != 0 || loadedMessages.isNotEmpty
    currentPage = page
    chats = loadedMessages.reversed() + chats
    messagesCollectionView.reloadData()

    if currentPage == 0 {
      messagesCollectionView.scrollToBottom(animated: false)
    } else {
      let afterContentSize = messagesCollectionView.collectionViewLayout.collectionViewContentSize
      let afterContentOffset = messagesCollectionView.contentOffset
      let newContentOffset = CGPoint(x: afterContentOffset.x, y: afterContentOffset.y + afterContentSize.height - beforeContentSize.height)
      
      messagesCollectionView.contentOffset = newContentOffset
    }

    if messagesCollectionView.alpha == 0 {
      UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
        self.messagesCollectionView.alpha = 1
      }, completion: nil)
    }
    
    loading = false
  }

  private func onSocketOpen() {
    channel = socket.channel("room:challenge:\(challenge.id)")
    channel.on("new_msg") { [weak self] message in
      if let data = message.payload.data(), let chat = try? JSONDecoder.gymRatsAPIDecoder.decode(ChatMessage.self, from: data) {
        self?.chats.append(chat)
        self?.noChatLabel.isHidden = true
        
        if chat.account.id == GymRats.currentAccount.id {
          self?.messageInputBar.inputTextView.text = nil
        }
      }
  
      self?.messagesCollectionView.reloadData()
      self?.messageInputBar.sendButton.stopAnimating()
      self?.messagesCollectionView.scrollToBottom(animated: true)
    }
    
    channel.onError { [weak self] error in
      self?.navigationController?.popViewController(animated: true)
      self?.messageInputBar.sendButton.stopAnimating()
    }
    
    channel.join()
      .receive("ok") { message in print("Channel Joined", message.payload) }
      .receive("error") { message in print("Failed to join", message.payload) }
  }
}

extension ChatViewController: MessagesDataSource {
  func currentSender() -> SenderType {
    return GymRats.currentAccount
  }
    
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return chats[indexPath.section]
  }
    
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return chats.count
  }
  
  func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    let show = indexPath.section == 0 || abs(chats[indexPath.section - 1].sentDate.utcDateIsDaysApartFromUtcDate(chats[indexPath.section].sentDate)) >= 1
    
    if show {
      return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate),
       attributes: [
        .font: UIFont.detailsBold,
        .foregroundColor: UIColor.secondaryText
      ])
    }

    return nil
  }

  func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    let name = message.sender.displayName

    return NSAttributedString(string: name, attributes: [
      .font: UIFont.details,
      .foregroundColor: UIColor.secondaryText
    ])
  }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    messageInputBar.sendButton.startAnimating()
    channel?.push("new_msg", payload: ["message": text.trimmingCharacters(in: .whitespacesAndNewlines)])
  }
}

extension ChatViewController: MessageCellDelegate {
  func didTapAvatar(in cell: MessageCollectionViewCell) {
    guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
    guard let chat = chats[safe: indexPath.section] else { return }
      
    push(ProfileViewController(account: chat.account, challenge: challenge))
  }
  
  func didTapImage(in cell: MessageCollectionViewCell) {
    guard let cell = cell as? MediaMessageCell else { return }
    
    let image = SingleImage(image: cell.imageView.image, url: cell.imageView.kf.webURL)
    let imageCarousel = ImageCarouselViewController.create(
      sourceView: cell.imageView,
      imageDataSource: image,
      options: [{
        switch UIDevice.contentMode {
        case .light:
          return .theme(.light)
        case .dark:
          return .theme(.dark)
        }
      }()],
      initialIndex: 0
    )
    
    self.present(imageCarousel, animated: false, completion: nil)
  }
}

extension ChatViewController: MessagesLayoutDelegate {
  func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    let show = indexPath.section == 0 || abs(chats[indexPath.section - 1].sentDate.utcDateIsDaysApartFromUtcDate(chats[indexPath.section].sentDate)) >= 1

    return show ? 30 : 0
  }

  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 25
  }
}

extension ChatViewController: MessagesDisplayDelegate {
  func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
    let chat = chats[indexPath.section]
    
    if chat.account.id == GymRats.currentAccount.id {
      return .bubbleTail(.bottomRight, .pointedEdge)
    } else {
      return .bubbleTail(.bottomLeft, .pointedEdge)
    }
  }
  
  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    let userImageView = UserImageView()
    userImageView.tag = 888
    
    let chat = chats[indexPath.section]
    
    avatarView.subviews.first(where: { $0.tag == 888 })?.removeFromSuperview()
    avatarView.addSubview(userImageView)
    avatarView.addConstraintsWithFormat(format: "H:|[v0]|", views: userImageView)
    avatarView.addConstraintsWithFormat(format: "V:|[v0]|", views: userImageView)
      
    userImageView.load(chat.account)
  }

  func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    switch message.kind {
    case .photo(let mediaItem):
      if let url = mediaItem.url {
        let skeletonView = UIView()
        skeletonView.isSkeletonable = true
        skeletonView.showAnimatedSkeleton()
        skeletonView.showSkeleton()

        imageView.kf.setImage(with: url, placeholder: skeletonView, options: [.transition(.fade(0.2))])
      }
    default:
      break
    }
  }

  func backgroundColor(for message: MessageType, at  indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    switch message.kind {
    case .emoji:
      return .clear
    default:
      guard let dataSource = messagesCollectionView.messagesDataSource else { return .foreground }
      
      return dataSource.isFromCurrentSender(message: message) ? .brand : .foreground
    }
  }
  
  func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    switch message.kind {
    case .emoji:
      return .clear
    default:
      guard let dataSource = messagesCollectionView.messagesDataSource else { return .white }
      
      return dataSource.isFromCurrentSender(message: message) ? .white : .primaryText
    }
  }
  
  func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
    return [.url]
  }
  
  func didSelectURL(_ url: URL) {
    let code = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first(where: { $0.name == "code" })?.value

    if url.absoluteString.contains("share.gymrats.app/join"), let code = code {
      ChallengeFlow.join(code: code)
    } else {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
    if chats[indexPath.section].account.id == GymRats.currentAccount.id {
      return [
        .foregroundColor: UIColor.white,
        .underlineColor: UIColor.white,
        .underlineStyle: NSUnderlineStyle.single.rawValue
      ]
    } else {
      return [
        .foregroundColor: UIColor.brand,
        .underlineColor: UIColor.brand,
        .underlineStyle: NSUnderlineStyle.single.rawValue
      ]
    }
  }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismissSelf()
    
    guard let image = info[.originalImage] as? UIImage else { return }
    
    let showAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 250, height: 250))
    imageView.image = image
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 4
    
    showAlert.view.addSubview(imageView)
    
    let height = NSLayoutConstraint(item: showAlert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
    showAlert.view.addConstraint(height)
    
    showAlert.addAction(UIAlertAction(title: "Send", style: .default, handler: { action in
      self.showLoadingBar()
        
      StorageService.upload(image)
        .subscribe { event in
          self.hideLoadingBar()
          
          if let url = event.element {
            self.channel?.push("new_msg", payload: ["image_url": url])
          } else if let error = event.error {
            self.presentAlert(with: error)
          }
        }
      .disposed(by: self.disposeBag)
    }))
    showAlert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
    
    present(showAlert, animated: true, completion: nil)
  }
}

extension UIView {
  func addConstraintsWithFormat(format: String, views: UIView...) {
    var viewsDictionary = [String: UIView]()
    
    for (index, view) in views.enumerated() {
      let key = "v\(index)"
      
      viewsDictionary[key] = view
      view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
  }
}


class SingleImage: ImageDataSource {
  let image: UIImage?
  let url: URL?
  
  init(image: UIImage?, url: URL?) {
    self.image = image
    self.url = url
  }
  
  func numberOfImages() -> Int {
    return 1
  }
  
  func imageItem(at index:Int) -> ImageItem {
    if let image = image {
      return .image(image)
    } else if let url = url {
      return .url(url, placeholder: UIImage(color: .lightGray))
    } else {
      return .image(nil)
    }
  }
}
