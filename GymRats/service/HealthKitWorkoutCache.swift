//
//  HealthKitWorkoutCache.swift
//  GymRats
//
//  Created by mack on 12/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import Cache
import HealthKit

enum HealthKitWorkoutCache {
  private enum Constants {
    static let storageKey = "health-kit-workouts-storage-key"
  }

  typealias UniversalIdentifier = String
  typealias UploadedStatus = Bool
  typealias CachedWorkouts = [UniversalIdentifier: UploadedStatus]
  
  static private let storage: Storage<CachedWorkouts> = {
    let dir = try! FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    .appendingPathComponent("HealthKitWorkouts")

    let disk = DiskConfig(
      name: "com.gr.health.kit.workouts",
      expiry: .never,
      maxSize: 0,
      directory: dir,
      protectionType: nil
    )
    
    let storage = try! Storage(
      diskConfig: disk,
      memoryConfig: MemoryConfig(),
      transformer: TransformerFactory.forCodable(ofType: CachedWorkouts.self)
    )

    do {
      if try !storage.existsObject(forKey: Constants.storageKey) {
        try storage.setObject([:], forKey: Constants.storageKey)
      }
    } catch let error {
      print(error)
    }
    
    return storage
  }()
  
  static func clearStorage() {
    do {
      if try storage.existsObject(forKey: Constants.storageKey) {
        try storage.removeObject(forKey: Constants.storageKey)
      }
    } catch let error {
      print(error)
    }
  }
  
  static func insert(_ healthKitWorkouts: [HKWorkout]) throws {
    var workouts = try storage.object(forKey: Constants.storageKey)
    
    for workout in healthKitWorkouts {
      workouts[workout.uuid.uuidString] = true
    }

    try storage.setObject(workouts, forKey: Constants.storageKey)
  }
  
  static func filterNotStored(_ healthKitWorkouts: [HKWorkout]) throws -> [HKWorkout] {
    do {
      let workouts = try storage.object(forKey: Constants.storageKey)
      
      return healthKitWorkouts.filter { workouts[$0.uuid.uuidString] == nil }
    } catch let error {
      print(error)

      throw error
    }
  }
}
