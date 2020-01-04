//
//  ShareCodeViewController.swift
//  GymRats
//
//  Created by Mack on 9/28/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import MessageUI
import RxGesture
import RxSwift

class ShareCodeViewController: UIViewController {
    
    let disposeBag = DisposeBag()

    var challenge: Challenge!
    
    weak var delegate: CreateChallengeDelegate?
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Invite"
        view.backgroundColor = .background
        let closeButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(close))
        
        navigationItem.rightBarButtonItem = closeButton

        label.text = "Challenge created! Others can join by using the code above. Copy it to your clipboard or tap the share button to send via text message. You can always do this later."
        label.font = .body
        label.numberOfLines = 0
        textView.text = challenge.code
        textView.font = UIFont(name: "SFProRounded-Regular", size: 44)!
        textView.isEditable = false
        textView.isScrollEnabled = false
        
        textView.rx.tapGesture().when(.recognized).subscribe { [weak self] e in
            guard let self = self else { return }
            
            if case .next = e {
                self.textView.selectAll(nil)
                UIMenuController.shared.isMenuVisible = true
            }
        }.disposed(by: disposeBag)
        
        button.onTouchUpInside { [weak self] in
            self?.invite()
        }.disposed(by: disposeBag)
        
        button.clipsToBounds = true
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        button.titleLabel?.font = .h4
        button.setTitleColor(UIColor.primaryText, for: .normal)
        button.setTitleColor(UIColor.primaryText.darker, for: .highlighted)
        button.setBackgroundImage(.init(color: .foreground), for: .normal)
        button.setBackgroundImage(.init(color: UIColor.foreground.darker), for: .highlighted)
    }

    @objc func close() {
        self.dismissSelf()
        self.delegate?.challengeCreated(challenge: challenge)
    }
    
    func invite() {
        guard MFMessageComposeViewController.canSendText() else {
            self.presentAlert(title: "Uh-oh", message: "This device cannot send text message.")
            return
        }
        
        let messageViewController = MFMessageComposeViewController()
        messageViewController.body = "Let's workout together! Join my GymRats challenge using invite code \"\(challenge.code)\" https://apps.apple.com/us/app/gymrats-group-challenge/id1453444814"
        messageViewController.messageComposeDelegate = self
        
        self.present(messageViewController, animated: true, completion: nil)
    }
    
}

extension ShareCodeViewController: MFMessageComposeViewControllerDelegate {
 
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismissSelf()
        
        if result == .sent {
            Track.event(.smsInviteSent)
        }
    }
    
}
