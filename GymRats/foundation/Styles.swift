//
//  Styles.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

extension UIFont {
  static let body        = UIFont(name: "SFProRounded-Regular", size: 14)!
  static let bodyBold    = UIFont(name: "SFProRounded-Bold",    size: 14)!
  static let details     = UIFont(name: "SFProRounded-Regular", size: 12)!
  static let detailsBold = UIFont(name: "SFProRounded-Bold",    size: 12)!
  static let h1          = UIFont(name: "SFProRounded-Regular", size: 32)!
  static let h1Bold      = UIFont(name: "SFProRounded-Bold",    size: 32)!
  static let h4Bold      = UIFont(name: "SFProRounded-Bold",    size: 18)!
  static let sixteenBold = UIFont(name: "SFProRounded-Bold",    size: 16)!
  static let h2          = UIFont(name: "SFProRounded-Regular", size: 24)!
  static let h2Bold      = UIFont(name: "SFProRounded-Bold",    size: 24)!
  static let h3          = UIFont(name: "SFProRounded-Regular", size: 20)!
  static let h4          = UIFont(name: "SFProRounded-Regular", size: 18)!
  static let title       = UIFont(name: "SFProRounded-Bold",    size: 28)!
  static let twenty      = UIFont(name: "SFProRounded-Bold",    size: 20)!

  static func proRoundedRegular(size: CGFloat) -> UIFont {
    return UIFont(name: "SFProRounded-Regular", size: size)!
  }

  static func proRoundedBold(size: CGFloat) -> UIFont {
    return UIFont(name: "SFProRounded-Bold", size: size)!
  }

  static func proRoundedSemibold(size: CGFloat) -> UIFont {
    return UIFont(name: "SFProRounded-Semibold", size: size)!
  }

  static func proRoundedBlack(size: CGFloat) -> UIFont {
    return UIFont(name: "SFProRounded-Black", size: size)!
  }
}
