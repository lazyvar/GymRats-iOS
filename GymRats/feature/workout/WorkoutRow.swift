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
  case singleImage(url: String)
  case media(media: [Workout.Medium])
  case account(Workout)
  case details(Workout)
  case location(placeID: String)
  case comment(Comment, onMenuTap: (Comment) -> Void)
  case newComment(onSubmit: (String) -> Void)
  case space

  static func == (lhs: WorkoutRow, rhs: WorkoutRow) -> Bool {
    switch (lhs, rhs) {
    case (.singleImage(let singleImage1), .singleImage(let singleImage2)):
      return singleImage1 == singleImage2
    case (.media(let media1), .media(let media2)):
      return media1 == media2
    case (.account(let w1), .account(let w2)):
      return w1 == w2
    case (.location(let p1), .location(placeID: let p2)):
      return p1 == p2
    case (.details(let w1), .details(let w2)):
      return w1 == w2
    case (.comment(let c1, _), .comment(let c2, _)):
      return c1 == c2
    case (.space, .space):
      return true
    default: return false
    }
  }
  
  var identity: String {
    switch self {
    case .singleImage(url: let url): return "single-image-\(url)"
    case .location(placeID: let place): return "location-\(place)"
    case .media(let media): return "media-\(media.count)"
    case .account(let workout): return "account-\(workout.id)"
    case .details(let workout): return "details-\(workout.id)"
    case .comment(let comment, _): return "comment-\(comment.id)"
    case .newComment: return "new-comment"
    case .space: return "space"
    }
  }
}
