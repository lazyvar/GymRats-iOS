//
//  AboutViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 3/3/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class AboutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMenuButton()
        title = "About"
        
        let text = """
        Hello!
        
        This app's goal is to act as a social motivator for fitness and health. Whether it's a personal or group challenge, it is important to track workouts and hold yourself accountable. I hope it is finding use. If you have any ideas on how to improve the app, please send me an email. Also, if you are interested in following the development process you can check out the public trello board.
        
        Happy ratting,

        Mack
        CPO (Chief Protein Officer)
        """
        let label = TTTAttributedLabel(frame: CGRect(x: 15, y: 15, width: self.view.frame.width-30, height: 500))
        let range = (text as NSString).range(of: "email")
        let url = URL(string: "mailto:suggestion@gymrats.app")!
        let range2 = (text as NSString).range(of: "trello board")
        let url2 = URL(string: "https://trello.com/b/P5ibjXHs/development")!
            
        label.font = .body
        label.textAlignment = .left
        label.textColor = .primaryText
        label.lineSpacing = 2
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.delegate = self
        label.text = text
        label.addLink(to: url, with: range)
        label.addLink(to: url2, with: range2)
        label.sizeToFit()
        
        view.isUserInteractionEnabled = true
        
        view.addSubview(label)
    }
    
}

extension AboutViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.openURL(url)
    }
}
