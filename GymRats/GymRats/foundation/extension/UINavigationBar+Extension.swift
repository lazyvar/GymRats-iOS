//
//  UINavigationBar+Extension.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    func turnBrandColorSlightShadow() {
        isTranslucent = false
        setBackgroundImage(.brand, for: .default)
        shadowImage = UIImage()
    }
    
}
