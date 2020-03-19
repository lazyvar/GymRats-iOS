//
//  Coding.swift
//  GymRats
//
//  Created by mack on 3/19/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
  func data() -> Data? {
    return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
  }
}
