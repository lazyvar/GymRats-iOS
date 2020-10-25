//
//  UpdateTeam.swift
//  GymRats
//
//  Created by mack on 10/16/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import UIKit

struct UpdateTeam {
  let id: Int
  let name: String?
  let photo: Either<UIImage, String>?
}
