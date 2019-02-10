//
//  Place.swift
//  GymRats
//
//  Created by Mack Hasz on 2/10/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import GooglePlaces

struct Place: Codable, Equatable, CustomStringConvertible {
    
    let name: String
    let id: String
    let latitude: Double
    let longitude: Double
    
    var description: String {
        return name
    }
    
    init(from gPlace: GMSPlace) {
        self.name = gPlace.name!
        self.id = gPlace.placeID!
        self.latitude = gPlace.coordinate.latitude
        self.longitude = gPlace.coordinate.longitude
    }
    
}
