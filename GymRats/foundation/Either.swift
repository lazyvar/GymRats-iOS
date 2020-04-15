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
