//
//  TabBarController.swift
//  GymRats
//
//  Created by Mack on 9/9/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class TabBarController: ESTabBarController {
    
    static func doIt(viewController: UIViewController) -> UIViewController {
        viewController.hidesBottomBarWhenPushed = true
        
        let tabBarController = ESTabBarController()
        // tabBarController.delegate = delegate
        // tabBarController.title = "Irregularity"
        tabBarController.shouldHijackHandler = { _, _, _ in return true }
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.shadowImage = UIImage()
        tabBarController.tabBar.backgroundImage = UIImage()

        tabBarController.didHijackHandler = { a, b, index in
            if index == 0 {
                GymRatsApp.coordinator.toggleMenu()
            } else if index == 1 {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                let WOO = NewWorkoutViewController()
                WOO.modalPresentationStyle = .pageSheet
                
                let nav = GRNavigationController(rootViewController: WOO)
                nav.modalPresentationStyle = .pageSheet
                tabBarController.modalPresentationStyle = .pageSheet
                
                tabBarController.present(nav, animated: true, completion: nil)
            } else if index == 2 {
                // TODO: open chat
            }
        }
        
        let v1 = UIViewController()
        let v2 = GRNavigationController(rootViewController: viewController)
        let v3 = UIViewController()

        let menu = UIImage(named: "menu")!.withRenderingMode(.alwaysOriginal)
        let chat = UIImage(named: "chat")!.withRenderingMode(.alwaysOriginal)
        let plus = UIImage(named: "activity-large-white")!

        v1.tabBarItem = UITabBarItem(title: nil, image: menu, selectedImage: menu)
        v2.tabBarItem = ESTabBarItem.init(ExampleIrregularityContentView(), title: nil, image: plus, selectedImage: plus)
        v3.tabBarItem = UITabBarItem(title: nil, image: chat, selectedImage: chat)

        tabBarController.viewControllers = [v1, v2, v3]
        tabBarController.selectedIndex = 1
        tabBarController.tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBarController.tabBar.layer.shadowRadius = 8
        tabBarController.tabBar.layer.shadowColor = UIColor.gray.withAlphaComponent(0.7).cgColor
        tabBarController.tabBar.layer.shadowOpacity = 0.5
        
        return tabBarController
    }
    
}

class ExampleBasicContentView: ESTabBarItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = UIColor.init(white: 175.0 / 255.0, alpha: 1.0)
        highlightTextColor = UIColor.init(red: 254/255.0, green: 73/255.0, blue: 42/255.0, alpha: 1.0)
        iconColor = UIColor.init(white: 175.0 / 255.0, alpha: 1.0)
        highlightIconColor = UIColor.init(red: 254/255.0, green: 73/255.0, blue: 42/255.0, alpha: 1.0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ExampleBouncesContentView: ExampleBasicContentView {
    
    public var duration = 0.3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }
    
    override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }
    
    func bounceAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = CAAnimationCalculationMode.cubic
        imageView.layer.add(impliesAnimation, forKey: nil)
    }
}


class ExampleIrregularityBasicContentView: ExampleBouncesContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textColor = .clear
        highlightTextColor = UIColor.init(red: 23/255.0, green: 149/255.0, blue: 158/255.0, alpha: 1.0)
        iconColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
        highlightIconColor = UIColor.init(red: 23/255.0, green: 149/255.0, blue: 158/255.0, alpha: 1.0)
        backdropColor = .brand
        highlightBackdropColor = .brand
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ExampleIrregularityContentView: ESTabBarItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.imageView.layer.shadowRadius = 8
        self.imageView.layer.shadowColor = UIColor.gray.withAlphaComponent(0.7).cgColor
        self.imageView.layer.shadowOpacity = 0.5

        
        self.imageView.backgroundColor = .brand
        // self.imageView.layer.borderWidth = 3.0
        //self.imageView.layer.borderColor = UIColor.init(white: 235 / 255.0, alpha: 1.0).cgColor
        self.imageView.layer.cornerRadius = 35
        self.insets = UIEdgeInsets.init(top: -32, left: 0, bottom: 0, right: 0)
        let transform = CGAffineTransform.identity
        self.imageView.transform = transform
        self.superview?.bringSubviewToFront(self)
        
        textColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
        highlightTextColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
        iconColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
        highlightIconColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
        backdropColor = .clear
        highlightBackdropColor = .clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let p = CGPoint.init(x: point.x - imageView.frame.origin.x, y: point.y - imageView.frame.origin.y)
        return sqrt(pow(imageView.bounds.size.width / 2.0 - p.x, 2) + pow(imageView.bounds.size.height / 2.0 - p.y, 2)) < imageView.bounds.size.width / 2.0
    }
    
    override func updateLayout() {
        super.updateLayout()
        self.imageView.sizeToFit()
        self.imageView.center = CGPoint.init(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
    }
    
    public override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
    public override func deselectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
    public override func highlightAnimation(animated: Bool, completion: (() -> ())?) {
        UIView.beginAnimations("small", context: nil)
        UIView.setAnimationDuration(0.2)
        let transform = self.imageView.transform.scaledBy(x: 0.8, y: 0.8)
        self.imageView.transform = transform
        UIView.commitAnimations()
        completion?()
    }
    
    public override func dehighlightAnimation(animated: Bool, completion: (() -> ())?) {
        UIView.beginAnimations("big", context: nil)
        UIView.setAnimationDuration(0.2)
        let transform = CGAffineTransform.identity
        self.imageView.transform = transform
        UIView.commitAnimations()
        completion?()
    }
    
}
