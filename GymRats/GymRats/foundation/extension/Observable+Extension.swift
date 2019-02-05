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
import PKHUD

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
            .then { _ in
                action()
            }
    }
    
}

extension Collection {
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
}

extension UITextField {
    
    var requiredValidation: Observable<Bool> {
        return rx.text.map { ($0 ?? "").isNotEmpty }.share(replay: 1)
    }
    
}

extension Observable {
    
    func standardServiceResponse(_ onSuccess: @escaping (Element) -> Void) -> Disposable {
        return self.subscribe(onNext: { element in
                // ...
                HUD.hide()
                onSuccess(element)
            }, onError: { error in
                HUD.show(.labeledError(title: "Error", subtitle: error.localizedDescription))
                HUD.hide(afterDelay: 1.5)
            })
    }
    
}

extension Observable {
    
    func then(_ function: @escaping (Element) -> Void) -> Disposable {
        return subscribe(onNext: { element in
            function(element)
        })
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
        return Observable<T>.create { observer in
            return self.subscribe { event in
                switch event {
                case .next(let data):
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    
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
                    decoder.dateDecodingStrategy = .secondsSince1970
                    
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
