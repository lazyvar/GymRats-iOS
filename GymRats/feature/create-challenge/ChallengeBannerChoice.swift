//
//  ChallengeBannerChoice.swift
//  GymRats
//
//  Created by mack on 4/13/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

enum ChallengeBannerChoice: CaseIterable {
  case upload
  case preset
  case skip
  
  var title: String {
    switch self {
    case .upload: return "Upload my own"
    case .preset: return "Choose a preset"
    case .skip: return "Skip"
    }
  }

  var titleForChange: String {
    switch self {
    case .upload: return "Upload my own"
    case .preset: return "Choose a preset"
    case .skip: return "Remove banner"
    }
  }
}
