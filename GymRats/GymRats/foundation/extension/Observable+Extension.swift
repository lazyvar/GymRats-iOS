//
//  Observable+Extension.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Kingfisher

extension Variable where Element == String {
    
    func bind(to label: UILabel) -> Disposable {
        return self.asObservable().bind(to: label.rx.text)
    }
    
}

extension Observable where Element == URL {
    
    func fetchImage() -> Observable<UIImage> {
        return Observable<UIImage>.create { observer in
            return self.subscribe { event in
                switch event {
                case .next(let url):
                    ImageDownloader.default.downloadImage(with: url) { image, error, _, _ in
                        if let image = image {
                            observer.on(.next(image))
                        } else if let error = error {
                            observer.on(.error(error))
                        }
                    }
                case .error(let error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            }
        }
    }
    
}

extension Observable where Element == Data {
    
    @discardableResult
    func decodeObject<T: Decodable>() -> Observable<T> {
        return Observable<T>.create { observer in
            return self.subscribe { event in
                switch event {
                case .next(let data):
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase // assuming true for all NASA API requests
                    
                    do {
                        observer.on(.next(try decoder.decode(T.self, from: data)))
                    } catch let error {
                        return observer.on(.error(error))
                    }
                case .error(let error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            }
        }
    }
    
    @discardableResult
    func decodeArray<T: Decodable>() -> Observable<[T]> {
        return Observable<[T]>.create { observer in
            return self.subscribe { event in
                switch event {
                case .next(let data):
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase // assuming true for all NASA API requests
                    
                    do {
                        observer.on(.next(try decoder.decode([T].self, from: data)))
                    } catch let error {
                        return observer.on(.error(error))
                    }
                case .error(let error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            }
        }
    }
    
}
