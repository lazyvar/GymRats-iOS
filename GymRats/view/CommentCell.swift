//
//  CommentCell.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import SwiftDate

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
  
  @IBOutlet private weak var menuButton: UIButton! {
    didSet {
      menuButton.imageView?.image = menuButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
      menuButton.imageView?.tintColor = .secondaryText
    }
  }
  
  @IBOutlet private weak var dateLabel: UILabel! {
    didSet {
      dateLabel.textColor = .secondaryText
      dateLabel.font = .proRoundedRegular(size: 10)
    }
  }
  
  private var comment: Comment!
  private var onMenuTap: ((Comment) -> Void)?
  
  @IBAction private func tappedMenuButton(_ sender: Any) {
    onMenuTap?(comment)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    backgroundColor = .foreground
    menuButton.isHidden = true
    selectionStyle = .none
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, comment: Comment, onMenuTap: @escaping (Comment) -> Void) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: CommentCell.self, for: indexPath).apply {
      $0.comment = comment
      $0.commentLabel.text = comment.content
      $0.accountImageView.load(comment.account)
      $0.accountNameLabel.text = comment.account.fullName
      $0.menuButton.isHidden = comment.account.id != GymRats.currentAccount.id
      $0.onMenuTap = onMenuTap
      $0.dateLabel.text = comment.createdAt.in(region: .current).toRelative(since: Date().in(region: .current), style: RelativeFormatter.twitterStyle(), locale: nil)
    }
  }
}
