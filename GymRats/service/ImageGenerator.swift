//
//  ImageGenerator.swift
//  GymRats
//
//  Created by Mack on 12/22/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import UIKit

enum ImageGenerator {
  private static let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    
    return formatter
  }()

  static func generateStepImage(steps: StepCount) -> UIImage? {
    guard let steps = numberFormatter.string(from: NSDecimalNumber(value: steps)) else { return nil }

    let view = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 600))
    view.backgroundColor = .brand
    
    let text = UILabel(frame: CGRect(x: 0, y: 0, width: 600, height: 600))
    text.text = steps
    text.textColor = .white
    text.font = .proRoundedBold(size: 100)
    text.textAlignment = .center
    
    view.addSubview(text)
    
    return view.imageFromContext()
  }
}
