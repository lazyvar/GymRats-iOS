//
//  MapCell.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class MapCell: UITableViewCell {
  private let disposeBag = DisposeBag()
  
  @IBOutlet private weak var chevronImageView: UIImageView! {
    didSet {
      chevronImageView.tintColor = .primaryText
    }
  }
  
  @IBOutlet private weak var mapImageView: UIImageView! {
    didSet {
      mapImageView.tintColor = .primaryText
    }
  }
  
  @IBOutlet private weak var locationLabel: UILabel! {
    didSet {
      locationLabel.textColor = .primaryText
      locationLabel.font = .body
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    
    backgroundColor = .foreground
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    locationLabel.text = ""
  }
  
  private func loadPlace(_ placeID: String) {
    GService.getPlaceInformation(forPlaceId: placeID)
      .subscribe { [weak self] event in
        guard let self = self else { return }
          
        if let place = event.element {
          self.locationLabel.text = place.name
        }
    }
    .disposed(by: disposeBag)
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, placeID: String) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: MapCell.self, for: indexPath).apply {
      $0.loadPlace(placeID)
    }
  }
}
