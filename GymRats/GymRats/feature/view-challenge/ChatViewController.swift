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
    
    /* paging info */
    var currentPage = 0
    var canLoadMorePosts = true
    var loading = true
    
    init(challenge: Challenge) {
        self.challenge = challenge
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title = challenge.name
        
        setupBackButton()
        
        scrollsToBottomOnKeyboardBeginsEditing = true
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        NotificationCenter.default.addObserver (
            self,
            selector: #selector(refresh),
            name: .chatNotification,
            object: nil
        )

        messagesCollectionView.alpha = 0
        
        refresh()
        
        messagesCollectionView.rx.contentOffset
            .subscribe { event in
                switch event {
                case .next(let offset):
                    if offset.y < 0 && !self.loading {
                        self.loading = true
                        self.loadNextPage()
                    }
                default: break
                }
            }.disposed(by: disposeBag)
    }
    
    @objc func refresh() {
        canLoadMorePosts = true
        loadChats(page: 0, clear: true)
    }
    
    private func loadNextPage() {
        loadChats(page: currentPage + 1)
    }
    
    private func loadChats(page: Int, clear: Bool = false) {
        guard canLoadMorePosts else {
            self.hideLoadingBar()
            return
        }
        
        self.showLoadingBar()
        
        gymRatsAPI.getAllChats(for: challenge, page: page)
            .subscribe { event in
                self.hideLoadingBar()
                
                switch event {
                case .next(let messages):
                    self.handleFetchResponse(loadedMessages: messages, page: page, clear: clear)
                case .error(let error):
                    self.presentAlert(with: error)
                default: break
                }
            }.disposed(by: disposeBag)
    }
    
    private func handleFetchResponse(loadedMessages: [ChatMessage], page: Int, clear: Bool) {
        if loadedMessages.count == 0 {
            canLoadMorePosts = false
            
            guard page == 0 else {
                return
            }
        }
        
        currentPage = page
        
        if clear {
            chats = []
        }
        
        chats = loadedMessages.reversed() + chats
        
        let beforeContentSize = messagesCollectionView.contentSize
        
        self.messagesCollectionView.reloadData()

        if currentPage == 0 {
            self.messagesCollectionView.scrollToBottom(animated: false)
        } else {
            let afterContentSize = self.messagesCollectionView.collectionViewLayout.collectionViewContentSize
            let afterContentOffset = self.messagesCollectionView.contentOffset
            let newContentOffset = CGPoint(x: afterContentOffset.x, y: afterContentOffset.y + afterContentSize.height - beforeContentSize.height)
            
            self.messagesCollectionView.contentOffset = newContentOffset
        }
        
        if self.messagesCollectionView.alpha == 0 {
            UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
                self.messagesCollectionView.alpha = 1
            }, completion: nil)
        }
        self.loading = false
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
                case .next(let message):
                    self.chats.append(message)
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
        
        push(ProfileViewController(user: chat.gymRatsUser, challenge: challenge))
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
        
        userImageView.load(avatarInfo: chat.gymRatsUser)
    }
    
    func backgroundColor(for message: MessageType, at  indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        switch message.kind {
        case .emoji:
            return .clear
        default:
            guard let dataSource = messagesCollectionView.messagesDataSource else { return .white }
            return dataSource.isFromCurrentSender(message: message) ? .primary : .incomingGray
        }
    }

}
