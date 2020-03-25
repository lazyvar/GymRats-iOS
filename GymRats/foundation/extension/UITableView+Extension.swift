//
//  UITableView+Extension.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

extension UITableView {
  func registerCellNibForClass<CellClass: UITableViewCell> (_ cellClass: CellClass.Type) {
    let name = classNameWithoutModule(cellClass)

    register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
  }

  func dequeueReusableCell<CellClass: UITableViewCell>(withType cellClass: CellClass.Type, for indexPath: IndexPath) -> CellClass {
    let name = classNameWithoutModule(cellClass)

    return dequeueReusableCell(withIdentifier: name, for: indexPath) as! CellClass
  }
  
  func registerSkeletonCellNibForClass<CellClass: UITableViewCell> (_ cellClass: CellClass.Type) {
    let name = classNameWithoutModule(cellClass)

    register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name + "-Skeleton")
  }

  func dequeueSkeletonCell<CellClass: UITableViewCell>(withType cellClass: CellClass.Type, for indexPath: IndexPath) -> CellClass {
    let name = classNameWithoutModule(cellClass) + "-Skeleton"

    return dequeueReusableCell(withIdentifier: name, for: indexPath) as! CellClass
  }
}
