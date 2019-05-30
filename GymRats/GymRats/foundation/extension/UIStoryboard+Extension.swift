//
//  UIStoryboard+Extension.swift
//  GymRats
//
//  Created by Mack on 5/29/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static let challenge = UIStoryboard(name: "Challenge", bundle: nil)
}

protocol StoryboardIdentifiable: class {
    static var storyboardIdentifier: String { get }
}

extension UIViewController: StoryboardIdentifiable {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static func loadFromNib(from storyboard: UIStoryboard) -> Self {
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}
