//
//  DevLog.swift
//  GymRats
//
//  Created by mack on 12/1/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import HealthKit
import UIKit

enum DevLog {
  private static let file = "auto-sync.log"
  private static let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  private static let fileURL = dir.appendingPathComponent(file)
  private static let dispatchQueue = DispatchQueue(label: "gym-rats-dev-log")
  
  static var enabled: Bool = true
  
  static func autoSyncInitiated() {
    log("Auto sync initiated")
  }
  
  static func fetchingSamples(lastSync: Date) {
    log("Fetching samples, last sync was \(lastSync)")
  }
  
  static func foundError(_ error: Error) {
    log("Found error: \(error)")
  }

  static func foundSamples(samples: [HKWorkout], lastSync: Date) {
    log("Found \(samples.count) sample\(samples.count == 1 ? "" : "s")")

    for sample in samples {
      log("{id: \(sample.uuid), type: \(sample.workoutActivityType.name), start: \(sample.startDate), end: \(sample.endDate) }")
    }
    
    log("New last sync is \(lastSync)")
  }
  
  static func shareLog() {
    let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

    UIViewController.topmost().present(activityViewController, animated: true, completion: nil)
  }

  private static func log(_ text: String) {
    guard enabled else { return }

    dispatchQueue.async {
      let log = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""

      try? (log + "[\(Date())] \(text)\n").write(to: fileURL, atomically: false, encoding: .utf8)
    }
  }
}
