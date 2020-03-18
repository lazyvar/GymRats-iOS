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

class ChatViewController: MessagesViewController {
  private let challenge: Challenge
  private let socket: Socket
  private var channel: Channel!
  private var chats: [ChatMessage] = []
  private let disposeBag = DisposeBag()
  private var currentPage = 0
  private var canLoadMorePosts = true
  private var loading = true

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

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .background
    messagesCollectionView.backgroundColor = .background
    title = challenge.name

    setupBackButton()
    
    scrollsToBottomOnKeyboardBeginsEditing = true
    messageInputBar.tintColor = .brand
    messageInputBar.backgroundView.backgroundColor = .background
    messageInputBar.sendButton.setTitleColor(.brand, for: .normal)
    messageInputBar.sendButton.setTitleColor(.brand, for: .highlighted)
    messageInputBar.delegate = self

    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messageCellDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(refresh),
      name: .chatNotification,
      object: nil
    )

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
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    socket.connect()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    socket.disconnect()
  }

  @objc private func refresh() {
    canLoadMorePosts = true
    loadChats(page: 0, clear: true)
  }
    
  private func loadNextPage() {
    loadChats(page: currentPage + 1)
  }

  private func loadChats(page: Int, clear: Bool = false) {
    guard canLoadMorePosts else { return /* hide loading bar */ }
    
    // TODO showLoadingBar()
        
    gymRatsAPI.getChatMessages(for: challenge, page: page)
      .subscribe(onNext: { result in
        // self.hideLoadingBar()

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
        
        if chat.account.id == GymRats.currentAccount.id {
          self?.messageInputBar.inputTextView.text = nil
        }
      }
  
      self?.messagesCollectionView.reloadData()
      self?.messageInputBar.sendButton.stopAnimating()
      self?.messagesCollectionView.scrollToBottom(animated: true)
    }
    
    channel.onError { [weak self] _ in
      self?.messageInputBar.sendButton.stopAnimating()
      self?.presentAlert(title: "Uh-oh", message: "Something went wrong. Please try again.")
    }
    
    channel.join()
      .receive("ok") { message in print("Channel Joined", message.payload) }
      .receive("error") { message in print("Failed to join", message.payload) }
  }
}

extension ChatViewController: MessagesDataSource {
  func currentSender() -> SenderType {
    return GymRats.currentAccount.asSender
  }
    
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return chats[indexPath.section]
  }
    
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return chats.count
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
}

extension ChatViewController: MessagesLayoutDelegate { }

extension ChatViewController: MessagesDisplayDelegate {
  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    let userImageView = UserImageView()
    userImageView.tag = 888
    
    let chat = chats[indexPath.section]
    
    avatarView.subviews.first(where: { $0.tag == 888 })?.removeFromSuperview()
    avatarView.addSubview(userImageView)
    avatarView.addConstraintsWithFormat(format: "H:|[v0]|", views: userImageView)
    avatarView.addConstraintsWithFormat(format: "V:|[v0]|", views: userImageView)
      
    userImageView.load(avatarInfo: chat.account)
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
      guard let dataSource = messagesCollectionView.messagesDataSource else { return .newWhite }
      
      return dataSource.isFromCurrentSender(message: message) ? .newWhite : .primaryText
    }
  }
}
