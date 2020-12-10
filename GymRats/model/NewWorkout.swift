//
//  NewWorkout.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import YPImagePicker

protocol LocalMedium {
  var photo: UIImage? { get }
  var thumbnail: UIImage? { get }
  var videoURL: URL? { get }
  var mediumType: Workout.Medium.MediumType { get }
}

struct NewWorkout {
  var title: String
  var description: String?
  var media: Either<[LocalMedium], [NewWorkout.Medium]>
  var googlePlaceId: String?
  var duration: Int?
  var distance: String?
  var steps: Int?
  var calories: Int?
  var points: Int?
  var appleDeviceName: String?
  var appleSourceName: String?
  var appleWorkoutUuid: String?
  var activityType: Workout.Activity?
  var occurredAt: Date?
  
  struct Medium: Codable {
    let url: String
    let thumbnailUrl: String?
    let mediumType: Workout.Medium.MediumType
  }
}

extension UIImage: LocalMedium {
  var photo: UIImage? {
    return self
  }
  
  var thumbnail: UIImage? {
    return nil
  }
  
  var videoURL: URL? {
    return nil
  }
  
  var mediumType: Workout.Medium.MediumType {
    return .image
  }
}

extension YPMediaItem: LocalMedium {
  var photo: UIImage? {
    switch self {
    case .photo(let p): return p.image
    case .video: return nil
    }
  }
  
  var thumbnail: UIImage? {
    switch self {
    case .photo: return nil
    case .video(let v): return v.thumbnail
    }
  }
  
  var videoURL: URL? {
    switch self {
    case .photo: return nil
    case .video(let v): return v.url
    }
  }
  
  var mediumType: Workout.Medium.MediumType {
    switch self {
    case .photo: return .image
    case .video: return .video
    }
  }
}
