//
//  Workout.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

struct Workout: Codable, Hashable {
  let id: Int
  let account: Account
  let challengeId: Int
  let title: String
  let description: String?
  let photoUrl: String?
  let googlePlaceId: String?
  let duration: Int?
  let distance: String?
  let steps: Int?
  let calories: Int?
  let points: Int?
  let appleDeviceName: String?
  let appleSourceName: String?
  let appleWorkoutUuid: String?
  let activityType: Activity?
  let occurredAt: Date
  let media: [Medium]
  
  var thumbnailUrl: String? {
    guard let medium = media.first else { return photoUrl }
    
    return medium.thumbnailUrl ?? medium.url
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  struct Medium: Codable, Equatable {
    let id: Int
    let url: String
    let thumbnailUrl: String?
    let mediumType: MediumType
    
    enum MediumType: String, Codable {
      case image = "image/jpg"
      case video = "video/mp4"
    }
  }

  enum Activity: String, Codable {
    case walking
    case running
    case cycling
    case hiit
    case yoga
    case hiking
    case baseketball
    case rowing
    case climbing
    case stairs
    case crossTraining = "cross_training"
    case dance
    case cooldown
    case elliptical
    case wheelchair
    case functionalStrengthTraining = "functional_strength_training"
    case traditionalStrengthTraining = "traditional_strength_training"
    case coreTraining = "core_training"
    case swimming
    case volleyball
    case other
    
    var title: String {
      switch self {
      case .hiit: return "HIIT"
      case .crossTraining: return "Cross training"
      case .functionalStrengthTraining: return "Functional strength training"
      case .traditionalStrengthTraining: return "Traditional strength training"
      case .coreTraining: return "Core training"
      case .baseketball: return "Basketball"
      
      default: return rawValue
      }
    }
    
    var rat: String {
      switch self {
      case .yoga: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/yoga.png?alt=media&token=48839caa-9a94-4b1d-a052-ef642f7d3902"
      case .wheelchair: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/wheelchair.png?alt=media&token=a319a614-ac54-4a49-b3f9-9020c37886d1"
      case .walking: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/walking.png?alt=media&token=50349de6-a530-4221-a517-f82df5da424a"
      case .swimming: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/swimming.png?alt=media&token=6cf35d2c-5bf6-4991-89d5-37938cae62bb"
      case .stairs: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/stairs.png?alt=media&token=563681fd-36bc-48c7-9e3f-880dbc6c469d"
      case .running: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/running.png?alt=media&token=a35a174b-d1ce-45fe-a759-c9c39d910762"
      case .rowing: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/rowing.png?alt=media&token=ccafea8d-95c5-418a-aa19-9dd480278c07"
      case .hiking: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/hiking.png?alt=media&token=8e05af11-48ef-41e4-8e95-aeb93d6337d7"
      case .hiit: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/hiit.png?alt=media&token=23609314-e08f-4c57-9e3d-a4883a853a92"
      case .functionalStrengthTraining, .crossTraining: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/fst.png?alt=media&token=55dd8146-cb7e-4729-a577-e4b8a315c91d"
      case .elliptical: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/elliptical.png?alt=media&token=8c90e4a0-be7b-448d-b830-bb2f27664e4c"
      case .dance: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/dancing.png?alt=media&token=a1a52b15-9380-4c96-bdb4-b11f9e52680f"
      case .cycling: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/cycling.png?alt=media&token=3447c0ea-f6f7-409d-8318-3f75837a2266"
      case .coreTraining: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/core.png?alt=media&token=0c036ad3-0705-4138-8860-628041c6d116"
      case .cooldown: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/cooldown.png?alt=media&token=712c7642-1fa3-4da9-9adc-530b2718393a"
        
      default: return "https://firebasestorage.googleapis.com/v0/b/gymrats-1549569453212.appspot.com/o/other.png?alt=media&token=75b4cbf1-6eff-41fa-b86b-7ac8044b381f"
      }
    }
  }
}

extension Workout: Avatar {
  var avatarName: String? { return title }
  var avatarImageURL: String? { return photoUrl }
}
