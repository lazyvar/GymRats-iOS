//
//  InviteToChallengeCell.swift
//  GymRats
//
//  Created by Mack on 5/3/21.
//  Copyright © 2021 Mack Hasz. All rights reserved.
//

import UIKit

class InviteToChallengeCell: UITableViewCell {
  private var challenge: Challenge?

  @IBOutlet private weak var inviteButton: PrimaryButton! {
    didSet {
      inviteButton.addTarget(self, action: #selector(tappedInvite), for: .touchUpInside)
    }
  }

  @objc private func tappedInvite() {
    guard let challenge = challenge else { return }

    ChallengeFlow.invite(to: challenge)
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    selectionStyle = .none
  }

  static func configure(tableView: UITableView, indexPath: IndexPath, challenge: Challenge) -> UITableViewCell {
    return tableView.dequeueReusableCell(withType: InviteToChallengeCell.self, for: indexPath).apply {
      $0.challenge = challenge
    }
  }
}
