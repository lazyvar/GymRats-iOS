//
//  Secrets.swift
//  GymRats
//
//  Created by mack on 4/13/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

enum Secrets {
  enum Unsplash {
    static let accessKey = "<UNSPLASH_ACCESS_KEY>"
    static let secretKey = "<UNSPLASH_SECRET_KEY>"
  }
  
  enum Segment {
    static let writeKey: String = {
      switch GymRats.environment {
      case .production:
        return "<SEGMENT_PRODUCTION_WRITE_KEY>"
      default:
        return "<SEGMENT_PRE_PRODUCTION_WRITE_KEY>"
      }
    }()
  }
}
