//
//  GService.swift
//  GymRats
//
//  Created by Mack Hasz on 2/9/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import GooglePlaces
import Cache
import RxSwift

class GService {
    
    static let placeCache: Storage<Place> = {
        let diskConfig = DiskConfig(name: "gr.place.cache", expiry: .seconds(2592000))
        let memoryConfig = MemoryConfig(expiry: .never)
        
        return try! Storage (
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: Place.self)
        )
    }()
    
    static func getPlaceInformation(forPlaceId placeId: String) -> Observable<Place> {
        return Observable<Place>.create { subscriber  in
            if let place = try? placeCache.entry(forKey: placeId) {
                subscriber.onNext(place.object)
                subscriber.onCompleted()
            } else {
                let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.name.rawValue) |
                    UInt(GMSPlaceField.coordinate.rawValue))!
                
                GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: nil, callback: { gPlace, error in
                    if let error = error {
                        subscriber.onError(error)
                        subscriber.onCompleted()
                    }
                    
                    if let gPlace = gPlace {
                        let place = Place(from: gPlace)
                        
                        try? placeCache.setObject(place, forKey: placeId)
                        subscriber.onNext(place)
                        subscriber.onCompleted()
                    }
                })
            }
            
            return Disposables.create()
        }
    }
    
}
