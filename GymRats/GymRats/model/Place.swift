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
    
    init?(from gPlace: GMSPlace) {
        guard let name = gPlace.name, let id = gPlace.placeID else { return nil }
        
        self.name = name
        self.id = id
        self.latitude = gPlace.coordinate.latitude
        self.longitude = gPlace.coordinate.longitude
    }
    
}
