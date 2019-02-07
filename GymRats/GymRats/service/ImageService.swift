//
//  ImageService.swift
//  GymRats
//
//  Created by Mack Hasz on 2/7/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import FirebaseStorage

class ImageService {
    
    static func uploadImageToFirebase(image: UIImage) -> Observable<String> {
        return Observable.create { subscriber in
            let uuid = UUID().uuidString
            
            let data: Data = image.jpegData(compressionQuality: 0.55)!
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let photoRef = storageRef.child("workout/\(uuid).jpg")
            
            // Create file metadata including the content type
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            // Upload the file to the path "images/rivers.jpg"
            photoRef.putData(data, metadata: metadata) { metadata, error in
                if let error = error {
                    // Uh-oh, an error occurred!
                    subscriber.onError(error)
                    subscriber.onCompleted()
                    return
                }
                
                photoRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        subscriber.onError(error!)
                        subscriber.onCompleted()
                        return
                    }
                    
                    subscriber.onNext(downloadURL.absoluteString)
                    subscriber.onCompleted()
                }
            }
            
            return Disposables.create()
        }
    }
    
}
