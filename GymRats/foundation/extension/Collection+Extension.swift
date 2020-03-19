//
//  Collection+Extension.swift
//  GymRats
//
//  Created by Mack Hasz on 2/6/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

extension Array {

    subscript (safe index: Index) -> Element? {
      return indices.contains(index) ? self[index] : nil
    }
    func first<T>(ofType: T.Type) -> T? {
        return first(where: { $0 is T }) as? T
    }
    
}
