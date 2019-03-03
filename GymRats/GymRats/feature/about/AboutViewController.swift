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
        view.backgroundColor = .whiteSmoke
        title = "About"
        
        let text = "Hello there! Thank you for using GymRats group challenge workout app. Hopefuly you are finding it useful. The app is is undergoing active development and welcomes any changes you feel necessary. Feel free to reach out to gymratsapp@gmail.com for any feedback."
        let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 150))
        let label = TTTAttributedLabel(frame: CGRect(x: 24, y: 24, width: self.view.frame.width-48, height: 150))
        let range = (text as NSString).range(of: "gymratsapp@gmail.com")
        let url = URL(string: "mailto:gymratsapp@gmail.com")!
        
        label.font = .body
        label.textColor = .brand
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.delegate = self
        label.text = text
        label.addLink(to: url, with: range)
        
        container.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
        
        container.addSubview(label)
        view.addSubview(container)
    }
    
}

extension AboutViewController: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.openURL(url)
    }
    
}
