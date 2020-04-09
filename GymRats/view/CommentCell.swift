//
//  CommentCell.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
  @IBOutlet private weak var commentLabel: UILabel! {
    didSet {
      commentLabel.textColor = .primaryText
      commentLabel.font = .details
    }
  }
  
  @IBOutlet private weak var accountNameLabel: UILabel! {
    didSet {
      accountNameLabel.textColor = .primaryText
      accountNameLabel.font = .detailsBold
    }
  }
  
  @IBOutlet private weak var accountImageView: UserImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    selectionStyle = .none
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, comment: Comment) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: CommentCell.self, for: indexPath).apply {
      $0.commentLabel.text = comment.content
      $0.accountImageView.load(comment.account)
      $0.accountNameLabel.text = comment.account.fullName
    }
  }
}
