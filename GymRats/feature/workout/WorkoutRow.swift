//
//  WorkoutRow.swift
//  GymRats
//
//  Created by mack on 4/8/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxDataSources

enum WorkoutRow: Equatable, IdentifiableType {
  case image(url: String)
  case account(Workout)
  case details(Workout)
  case comment(Comment, onMenuTap: (Comment) -> Void)
  case newComment(onSubmit: (String) -> Void)

  static func == (lhs: WorkoutRow, rhs: WorkoutRow) -> Bool {
    switch (lhs, rhs) {
    case (.image(let url1), .image(url: let url2)):
      return url1 == url2
    case (.account(let w1), .account(let w2)):
      return w1 == w2
    case (.details(let w1), .details(let w2)):
      return w1 == w2
    case (.comment(let c1, _), .comment(let c2, _)):
      return c1 == c2
    default: return false
    }
  }
  
  var identity: String {
    switch self {
    case .image(let url): return "image-\(url)"
    case .account(let workout): return "account-\(workout.id)"
    case .details(let workout): return "details-\(workout.id)"
    case .comment(let comment, _): return "comment-\(comment.id)"
    case .newComment: return "new-comment"
    }
  }
}

struct Nothing: Hashable {
  static let instance: Nothing = .init()
  
  private init() { }
}

extension Nothing: IdentifiableType {
  var identity: Nothing { return .instance }
}
