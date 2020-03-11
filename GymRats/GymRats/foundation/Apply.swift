//
//  Apply.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

protocol Applicable { }

extension Applicable {
  @inline(__always) func apply(block: (Self) -> Void) -> Self { block(self); return self }
}

extension NSObject: Applicable { }
