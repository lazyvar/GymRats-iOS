//
//  StorageSerice.swift
//  GymRats
//
//  Created by Mack Hasz on 2/7/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import FirebaseStorage
import YPImagePicker

class StorageService {
  typealias FractionCompleted = Double
  typealias ProgressBlock = (FractionCompleted) -> Void
  
  static func upload(localMedium: LocalMedium, progress: ProgressBlock? = nil) -> Observable<NewWorkout.Medium> {
    switch localMedium.mediumType {
    case .image: return upload(photo: localMedium, progress: progress)
    case .video: return upload(video: localMedium, progress: progress)
    }
  }
  
  static func upload(video: LocalMedium, progress: ProgressBlock? = nil) -> Observable<NewWorkout.Medium> {
    return Observable.from([video.videoURL as Any, video.thumbnail as Any])
      .concatMap { obj -> Observable<String> in
        if let url = obj as? URL {
          return upload(video: url, progress: progress)
        }
        
        if let image = obj as? UIImage {
          return upload(image, progress: progress)
        }
        
        fatalError()
      }
      .toArray()
      .map { urls in
        return NewWorkout.Medium(url: urls[0], thumbnailUrl: urls[1], mediumType: .video)
      }
      .asObservable()
  }

  static func upload(video fileURL: URL, progress: ProgressBlock? = nil) -> Observable<String> {
    return Observable.create { subscriber in
      let uuid = UUID().uuidString

      let storage = Storage.storage()
      let storageRef = storage.reference()
      let photoRef = storageRef.child("\(uuid).mp4")

      let metadata = StorageMetadata()
      metadata.contentType = "video/mp4"

      let task = photoRef.putFile(from: fileURL, metadata: metadata) { _, error in
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

      task.observe(.progress) { snapshot in
        guard let fractionCompleted = snapshot.progress?.fractionCompleted else { return }
  
        progress?(fractionCompleted)
      }
      
      return Disposables.create()
    }
  }

  static func upload(photo: LocalMedium, progress: ProgressBlock? = nil) -> Observable<NewWorkout.Medium> {
    if GymRats.environment == .development {
      return .just(.init(url: "https://picsum.photos/\((300...500).randomElement()!)/\((300...500).randomElement()!)", thumbnailUrl: nil, mediumType: .image))
    }
    
    return upload(photo.photo!, progress: progress)
      .map { url in
        return NewWorkout.Medium(url: url, thumbnailUrl: nil, mediumType: .image)
      }
  }

  static func upload(_ image: UIImage, progress: ProgressBlock? = nil) -> Observable<String> {
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
      let task = photoRef.putData(data, metadata: metadata) { metadata, error in
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
      
      task.observe(.progress) { snapshot in
        guard let fractionCompleted = snapshot.progress?.fractionCompleted else { return }
  
        progress?(fractionCompleted)
      }
      
      return Disposables.create()
    }
  }
}
