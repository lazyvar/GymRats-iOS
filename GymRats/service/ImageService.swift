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
import YPImagePicker

class ImageService {
  static func upload(_ video: YPMediaVideo) -> Observable<NewWorkout.Medium> {
    return Observable.zip(upload(video: video.url), upload(video.thumbnail))
      .map { videoUrl, thumbnailUrl in
        return NewWorkout.Medium(url: videoUrl, thumbnailUrl: thumbnailUrl, mediumType: .video)
      }
  }

  static func upload(video fileURL: URL) -> Observable<String> {
    return Observable.create { subscriber in
      let uuid = UUID().uuidString

      let storage = Storage.storage()
      let storageRef = storage.reference()
      let photoRef = storageRef.child("\(uuid).mp4")

      let metadata = StorageMetadata()
      metadata.contentType = "video/mp4"

      photoRef.putFile(from: fileURL, metadata: metadata) { _, error in
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

  static func upload(_ photo: YPMediaPhoto) -> Observable<NewWorkout.Medium> {
    if GymRats.environment == .development {
      return .just(.init(url: "https://picsum.photos/\((300...500).randomElement()!)/\((300...500).randomElement()!)", thumbnailUrl: nil, mediumType: .image))
    }
    
    return upload(photo.image)
      .map { url in
        return NewWorkout.Medium(url: url, thumbnailUrl: nil, mediumType: .image)
      }
  }

  static func upload(_ image: UIImage) -> Observable<String> {
    if GymRats.environment == .development {
      return .just("https://picsum.photos/\((300...500).randomElement()!)/\((300...500).randomElement()!)")
    }

    return Observable.create { subscriber in
      let uuid = UUID().uuidString
      
      let data: Data = image.jpegData(compressionQuality: 0.55)!
      let storage = Storage.storage()
      let storageRef = storage.reference()
      let photoRef = storageRef.child("\(uuid).jpg")
      
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
