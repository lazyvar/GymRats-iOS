//
//  Either.swift
//  GymRats
//
//  Created by mack on 4/14/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

enum Either<Left, Right> {
  case left(Left)
  case right(Right)
  
  var left: Left? {
    switch self {
    case .left(let left):
      return left
    case .right:
      return nil
    }
  }
  
  var right: Right? {
    switch self {
    case .left:
      return nil
    case .right(let right):
      return right
    }
  }
}

extension Either: Equatable where Left: Equatable, Right: Equatable {
  static func == (lhs: Either<Left, Right>, rhs: Either<Left, Right>) -> Bool {
    switch (lhs, rhs) {
    case (.left(let a), .left(let b)):
      return a == b
    case (.right(let a), .right(let b)):
      return a == b
    default:
      return false
    }
  }
}
