//
//  ChallengeMode.swift
//  GymRats
//
//  Created by mack on 4/13/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

enum ChallengeMode: CaseIterable {
  case classic
  case custom
  
  var title: String {
    switch self {
    case .classic: return "Classic"
    case .custom: return "Custom"
    }
  }
  
  var subtitle: String {
    switch self {
    case .classic: return "The award winning mode."
    case .custom: return "Pick and choose your settings."
    }
  }
}
