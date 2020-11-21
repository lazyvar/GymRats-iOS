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

  private lazy var bgView = SpookyView()
  
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
    bgView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(bgView)

    NSLayoutConstraint.activate(
      [
        bgView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
        bgView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
        bgView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
        bgView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
      ]
    )

    alertStackView.translatesAutoresizingMaskIntoConstraints = false
    bgView.addSubview(alertStackView)

    NSLayoutConstraint.activate(
      [
        alertStackView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 12),
        alertStackView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -12),
      ]
    )
    
    alertStackView.verticallyCenter(in: self)
  }
}
