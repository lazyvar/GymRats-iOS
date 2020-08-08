//
//  ClassicChallengeViewController.swift
//  GymRats
//
//  Created by mack on 4/14/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import Eureka
import SwiftDate

class ClassicChallengeViewController: GRFormViewController {
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Classic challenge"
    
    tableView.backgroundColor = .background
    tableView.separatorStyle = .none
    
    setupBackButton()
    
    form = form
      +++ mainSection
        <<< nameRow
        <<< descriptionRow
        <<< startDateRow
  }
    
  @objc private func nextTapped() {
    let values = form.values()
    
    guard form.validate().count == 0 else { return }
    guard let start1 = values["start_date"] as? Date else { return }
    let start = start1.in(region: .current).dateAtStartOf(.day).date.dateAtStartOf(.day)
    
    let newChallenge = NewChallenge(
      name: values["name"] as? String ?? "",
      description: values["description"] as? String,
      startDate: start,
      endDate: (start + 29.days).dateAtStartOf(.day),
      scoreBy: .workouts,
      banner: nil
    )
    
    push(ChallengeBannerViewController(newChallenge), animated: true)
  }
    
  // MARK: Eurekah

  private lazy var mainSection: Section = {
    return Section() { section in
      section.footer = self.sectionFooter
    }
  }()
  
  private lazy var nameRow: TextFieldRow = {
    return TextFieldRow() { textRow in
      textRow.placeholder = "Group name"
      textRow.tag = "name"
      textRow.icon = .people
      textRow.add(rule: RuleRequired(msg: "Name is required."))
    }
    .onRowValidationChanged(self.handleRowValidationChange)
  }()

  private lazy var startDateRow: PickDateRow = {
    return PickDateRow() { textRow in
      textRow.placeholder = "Start date"
      textRow.tag = "start_date"
      textRow.icon = .cal
      textRow.add(rule: RuleRequired(msg: "Start date is required."))
      textRow.value = Date()
      textRow.startDate = Date()
    }
  }()

  private lazy var descriptionRow: TextViewRow = {
    return TextViewRow() { textRow in
      textRow.placeholder = "Descripton (optional)"
      textRow.tag = "description"
      textRow.icon = .clipboard
    }
  }()

  private lazy var sectionFooter: HeaderFooterView<UIView> = {
    let footerBuilder = { () -> UIView in
      let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
      let goButton = PrimaryButton().apply {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Next", for: .normal)
      }

      container.addSubview(goButton)

      goButton.addTarget(self, action: #selector(self.nextTapped), for: .touchUpInside)
      goButton.constrainWidth(UIScreen.main.bounds.width - 40)
      goButton.constrainHeight(48)
      goButton.horizontallyCenter(in: container)
      goButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 10).isActive = true

      return container
    }
    
    var footer = HeaderFooterView<UIView>(.callback(footerBuilder))
    footer.height = { 100 }
    
    return footer
  }()
  
  private func handleRowValidationChange(cell: UITableViewCell, row: TextFieldRow) {
    guard let textRowNumber = row.indexPath?.row, var section = row.section else { return }
    
    let validationLabelRowNumber = textRowNumber + 1
    
    while validationLabelRowNumber < section.count && section[validationLabelRowNumber] is ErrorLabelRow {
      section.remove(at: validationLabelRowNumber)
    }
    
    if row.isValid { return }
    
    for (index, validationMessage) in row.validationErrors.map({ $0.msg }).enumerated() {
      let labelRow = ErrorLabelRow()
        .cellSetup { cell, _ in
          cell.errorLabel.text = validationMessage
        }
      
      section.insert(labelRow, at: validationLabelRowNumber + index)
    }
  }
}
