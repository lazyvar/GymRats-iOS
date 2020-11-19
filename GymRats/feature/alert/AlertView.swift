//
//  AlertView.swift
//  PanModal
//
//  Created by Stephen Sowole on 3/1/19.
//  Copyright © 2019 Detail. All rights reserved.
//

import UIKit

class AlertView: UIView {

  // MARK: - Views

  let titleLabel: UILabel = {
    let label = UILabel()
    
    label.font = .bodyBold
    label.textColor = .primaryText

    return label
  }()

  let message: UILabel = {
    let label = UILabel()
    
    label.font = .body
    label.textColor = .primaryText
    label.numberOfLines = 0
    
    return label
  }()

  private lazy var alertStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [titleLabel, message])
  
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.spacing = 4.0
  
    return stackView
  }()

  init() {
    super.init(frame: .zero)
  
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  private func setupView() {
    backgroundColor = .foreground
    
    layoutStackView()
  }

  private func layoutStackView() {
    addSubview(alertStackView)
    alertStackView.translatesAutoresizingMaskIntoConstraints = false
    alertStackView.verticallyCenter(in: self)
    alertStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
    alertStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
  }
}
