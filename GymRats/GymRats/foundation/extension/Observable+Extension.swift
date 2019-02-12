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
import RxOptional

func requireAll(_ boolValues: Observable<Bool>...) -> Observable<Bool> {
    return Observable<Bool>.combineLatest(boolValues) { collection in
        return collection.reduce(true) { whole, part in
            return whole && part
        }
    }
}

extension UIButton {
    
    /// life should be this easy
    func onTouchUpInside(_ action: @escaping () -> Void) -> Disposable {
        return self.rx.controlEvent(.touchUpInside)
            .asObservable()
            .subscribe(onNext: { _ in
                action()
            })
    }
    
}

extension Collection {
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
}

extension UITextField {
    
    var requiredValidation: Observable<Bool> {
        return rx.text.map { !($0 ?? "").isEmpty }.share(replay: 1)
    }
    
}

extension Observable where Element: OptionalType {

    var isPresent: Observable<Bool> {
        return map { $0.value != nil }.share(replay: 1)
    }

}

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
        return map { data in
            do {
                let serviceResponse = try JSONDecoder.gymRatsAPIDecoder.decode(ServiceResponse<T>.self, from: data)
                
                switch serviceResponse.status {
                case .success:
                    return serviceResponse.response!
                case .failure:
                    throw SimpleError(message: serviceResponse.errorMessage!)
                }
            } catch let error {
                print(error)
                throw error
            }
        }
    }
    
    @discardableResult
    func decodeArray<T: Decodable>() -> Observable<[T]> {
        return map { data in
            do {
                let serviceResponse = try JSONDecoder.gymRatsAPIDecoder.decode(ServiceResponse<[T]>.self, from: data)
                
                switch serviceResponse.status {
                case .success:
                    return serviceResponse.response!
                case .failure:
                    throw SimpleError(message: serviceResponse.errorMessage!)
                }
            } catch let error {
                print(error)
                throw error
            }
        }
    }
    
}

extension JSONDecoder {
    
    static let gymRatsAPIDecoder: JSONDecoder = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }()
    
}
