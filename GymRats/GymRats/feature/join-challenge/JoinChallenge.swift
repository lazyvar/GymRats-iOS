//
//  JoinChallenge.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

enum JoinChallenge {
    
    static func presentJoinChallengeModal(on viewController: UIViewController) -> Observable<Group> {
        return Observable<Group>.create({ [weak viewController] subscriber -> Disposable in
            guard let viewController = viewController else {
                
                return Disposables.create()
            }
            
            let disposeBag = DisposeBag()
            
            let alert = UIAlertController (
                title: "Join Challenge",
                message: "Enter the 6 character challenge code",
                preferredStyle: .alert
            )
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: { _ in
                let code = alert.textFields?.first?.text ?? ""
                
                gymRatsAPI.joinChallenge(code: code)
                    .subscribe(subscriber)
                    .disposed(by: disposeBag)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { _ in
                subscriber.onError(SimpleError(message: "User canceled."))
                subscriber.onCompleted()
            })
            
            alert.addTextField { (textField: UITextField!) -> Void in
                textField.placeholder = "Code"
            }
            
            alert.addAction(ok)
            alert.addAction(cancelAction)

            viewController.present(alert, animated: true, completion: nil)
        
            return Disposables.create()
        })
    }
    
}
