//
//  Collection+Extension.swift
//  GymRats
//
//  Created by Mack Hasz on 2/6/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

extension Array {

    subscript (safe index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
    
}
