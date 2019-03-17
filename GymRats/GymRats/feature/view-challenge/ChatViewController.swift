//
//  ChatViewController.swift
//  GymRats
//
//  Created by Mack on 3/16/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import MessageKit
import RxSwift
import MessageInputBar

class ChatViewController: MessagesViewController {
    
    var chats: [ChatMessage] = []
    let disposeBag = DisposeBag()
    let challenge: Challenge
    
    init(challenge: Challenge) {
        self.challenge = challenge
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = challenge.name
        
        setupBackButton()
        
        scrollsToBottomOnKeyboardBeginsEditing = true
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        NotificationCenter.default.addObserver (
            self,
            selector: #selector(getAllChats),
            name: .chatNotification,
            object: nil
        )
        
        getAllChats()
    }
    
    @objc func getAllChats() {
        gymRatsAPI.getAllChats(for: challenge)
            .subscribe { event in
                switch event {
                case .next(let messages):
                    self.chats = messages
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: true)
                case .error(let error):
                    self.presentAlert(with: error)
                default: break
                }
            }.disposed(by: disposeBag)
        
        gymRatsAPI.markChatRead(for: challenge)
            .subscribe { _ in
                // ...
            }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        GymRatsApp.coordinator.openChallengeChatId = challenge.id
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        GymRatsApp.coordinator.openChallengeChatId = nil
    }
    
}

extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        self.showLoadingBar(disallowUserInteraction: true)
        
        gymRatsAPI.postChatMessage(text, for: challenge)
            .subscribe { event in
                self.hideLoadingBar()
                
                switch event {
                case .next(let messages):
                    self.chats = messages
                    self.messagesCollectionView.reloadData()
                    self.messageInputBar.inputTextView.text = nil
                    self.messagesCollectionView.scrollToBottom(animated: true)
                case .error(let error):
                    self.presentAlert(with: error)
                default: break
                }
            }.disposed(by: disposeBag)
    }
    
}

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return GymRatsApp.coordinator.currentUser.asSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return chats[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return chats.count
    }
    
}

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let chat = chats[safe: indexPath.section] else { return }
        guard let user = Cache.users[chat.gymRatsUserId] else { return }
        
        push(ProfileViewController(user: user, challenge: challenge))
    }

}

extension ChatViewController: MessagesLayoutDelegate { }

extension ChatViewController: MessagesDisplayDelegate {
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let userImageView = UserImageView()
        userImageView.tag = 888
        
        let chat = chats[indexPath.section]
        let user: User = Cache.users[chat.gymRatsUserId] ?? GymRatsApp.coordinator.currentUser
        
        avatarView.subviews.first(where: { $0.tag == 888 })?.removeFromSuperview()
        avatarView.addSubview(userImageView)
        avatarView.addConstraintsWithFormat(format: "H:|[v0]|", views: userImageView)
        avatarView.addConstraintsWithFormat(format: "V:|[v0]|", views: userImageView)
        
        userImageView.load(avatarInfo: user)
    }
    
    func backgroundColor(for message: MessageType, at  indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        switch message.kind {
        case .emoji:
            return .clear
        default:
            guard let dataSource = messagesCollectionView.messagesDataSource else { return .white }
            return dataSource.isFromCurrentSender(message: message) ? .brand : .incomingGray
        }
    }

}

