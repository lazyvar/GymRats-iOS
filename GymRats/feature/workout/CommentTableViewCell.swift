//
//  CommentTableViewCell.swift
//  GymRats
//
//  Created by Mack on 3/16/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class CommentTableViewCell: UITableViewCell {
  private let disposeBag = DisposeBag()

  @IBOutlet private weak var userImageView: UserImageView!
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var commentLabel: UILabel!
  @IBOutlet private weak var menu: UIImageView!
  
  var menuTappedBlock: (() -> Void)?
    
  override func awakeFromNib() {
    super.awakeFromNib()
    
    nameLabel.font = .detailsBold
    commentLabel.font = .details
    menu.image = menu.image?.withRenderingMode(.alwaysTemplate)
    menu.tintColor = .primaryText
    
    menu.rx.tapGesture().subscribe { [weak self] _ in
      self?.menuTappedBlock?()
    }.disposed(by: disposeBag)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    userImageView.clear()
    nameLabel.text = nil
    commentLabel.text = nil
    menuTappedBlock = nil
    menu.isHidden = true
  }
}
