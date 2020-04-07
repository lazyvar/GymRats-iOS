//
//  UserDefaults+Extension.swift
//  GymRats
//
//  Created by mack on 3/14/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

extension UserDefaults {
  func setCodable<Element: Codable>(_ value: Element, forKey key: String) {
    let encoder = JSONEncoder()
    let data = try! encoder.encode(value)
    
    UserDefaults.standard.setValue(data, forKey: key)
  }

  func codable<Element: Codable>(forKey key: String) -> Element? {
    guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
    let element = try? JSONDecoder().decode(Element.self, from: data)
    
    return element
  }
}
