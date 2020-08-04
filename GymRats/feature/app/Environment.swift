//
//  Environment.swift
//  GymRats
//
//  Created by mack on 3/18/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

extension GymRats {
  static var environment: Environment {
    return .production
    
    guard let info = Bundle.main.infoDictionary     else { fatalError("Info.plist not found.") }
    guard let env = info["GYM_RATS_ENV"] as? String else { fatalError("GYM_RATS_ENV not found in Info.plist") }
    
    return Environment(rawValue: env)!
  }

  enum Environment: String {
    case production
    case preProduction
    case development
    
    var networkProvider: NetworkProvider {
      switch self {
      case .production:    return ProductionNetworkProvider()
      case .preProduction: return PreProductionNetworkProvider()
      case .development:   return DevelopmentNetworkProvider()
      }
    }
    
    var ws: String {
      switch self {
      case .production:    return "wss://www.gymratsapi.com/chat/websocket"
      case .preProduction: return "wss://gym-rats-api-pre-production.gigalixirapp.com/chat/websocket"
      case .development:   return "ws://localhost:4000/chat/websocket"
      }
    }
  }
}
