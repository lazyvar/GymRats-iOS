//
//  NewCommentCell.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class NewCommentCell: UITableViewCell {
  @IBOutlet private weak var accountImageView: UserImageView!
  
  @IBOutlet private weak var commentTextField: UITextField! {
    didSet {
      commentTextField.placeholder = "Enter comment"
      commentTextField.textColor = .primaryText
      commentTextField.font = .body
      commentTextField.delegate = self
      commentTextField.returnKeyType = .send
      commentTextField.autocorrectionType = .default
      commentTextField.spellCheckingType = .yes
    }
  }
  
  private var onSubmit: ((String) -> Void)?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    backgroundColor = .foreground
    separatorInset = .init(top: .zero, left: .zero, bottom: .zero, right: .greatestFiniteMagnitude)
    clipsToBounds = true
    layer.cornerRadius = 4
    layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    selectionStyle = .none
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    commentTextField.text = nil
  }
  
  static func configure(tableView: UITableView, indexPath: IndexPath, account: Account, onSubmit: @escaping (String) -> Void) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: NewCommentCell.self, for: indexPath).apply {
      $0.accountImageView.load(account)
      $0.onSubmit = onSubmit
    }
  }
}

extension NewCommentCell: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    
    if text.isNotEmpty {
      onSubmit?(text)
    }
    
    return true
  }
}
