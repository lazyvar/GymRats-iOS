//
//  EditChallengeViewController.swift
//  GymRats
//
//  Created by Mack on 9/24/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import SwiftDate
import RxSwift
import RxCocoa
import GradientLoadingBar
import Eureka
import Kingfisher

class EditChallengeViewController: GRFormViewController {
  private let disposeBag = DisposeBag()
  private let challenge: Challenge
  
  init(challenge: Challenge) {
    self.challenge = challenge
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Edit challenge"
    
    tableView.backgroundColor = .background
    tableView.separatorStyle = .none
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: .close, style: .plain, target: self, action: #selector(dismissSelf))
    
    setupBackButton()
    
    form = form
      +++ mainSection
        <<< nameRow
        <<< descriptionRow
        <<< startDateRow
        <<< endDateRow
        <<< scoreRow
  }
    
  @objc private func nextTapped() {
    let values = form.values()
    
    guard form.validate().count == 0 else { return }
    guard let score = values["score_by"] as? Int else { return }
    guard let scoreBy = ScoreBy(intValue: score) else { return }
    guard let start = values["start_date"] as? Date else { return }
    guard let end = values["end_date"] as? Date else { return }

    let difference = start.getInterval(toDate: end, component: .day)

    guard difference > 0 else {
      presentAlert(title: "", message: "The ending date must be further ahead in time than the starting date.")
      return
    }
    
    let updateChallenge = UpdateChallenge(
      id: challenge.id,
      name: values["name"] as? String ?? "",
      description: values["description"] as? String,
      startDate: start.dateAtStartOf(.day),
      endDate: end.dateAtStartOf(.day),
      scoreBy: scoreBy,
      banner: nil
    )

    showLoadingBar()
    
    gymRatsAPI.updateChallenge(updateChallenge)
      .subscribe(onNext: { [weak self] result in
        guard let self = self else { return }
        
        self.hideLoadingBar()
        
        switch result {
        case .success(let challenge):
          Challenge.State.all.fetch().ignore(disposedBy: self.disposeBag)
          NotificationCenter.default.post(name: .joinedChallenge, object: challenge)
          self.dismissSelf()
        case .failure(let error):
          self.presentAlert(with: error)
        }
      })
      .disposed(by: disposeBag)
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
      textRow.value = self.challenge.name
      textRow.add(rule: RuleRequired(msg: "Name is required."))
    }
    .onRowValidationChanged(self.handleRowValidationChange)
  }()

  private lazy var descriptionRow: TextViewRow = {
    return TextViewRow() { textRow in
      textRow.placeholder = "Descripton (optional)"
      textRow.tag = "description"
      textRow.icon = .clipboard
      textRow.value = self.challenge.description
    }
  }()

  private lazy var startDateRow: PickDateRow = {
    return PickDateRow() { textRow in
      textRow.placeholder = "Start date"
      textRow.tag = "start_date"
      textRow.icon = .cal
      textRow.add(rule: RuleRequired(msg: "Start date is required."))
      textRow.value = self.challenge.startDate
    }
  }()

  private lazy var endDateRow: PickDateRow = {
    return PickDateRow() { textRow in
      textRow.placeholder = "End date"
      textRow.tag = "end_date"
      textRow.icon = .cal
      textRow.add(rule: RuleRequired(msg: "End date is required."))
      textRow.value = self.challenge.endDate
      textRow.endDate = Date() + 1000.years
    }
  }()

  private lazy var scoreRow: IntegerPickerRow = {
    return IntegerPickerRow() { textRow in
      textRow.placeholder = "Score by"
      textRow.tag = "score_by"
      textRow.add(rule: RuleRequired(msg: "Score is required."))
      textRow.icon = .star
      textRow.value = ScoreBy.allCases.firstIndex(of: self.challenge.scoreBy) ?? 0
      textRow.numberOfRows = ScoreBy.allCases.count
      textRow.displayInt = { ScoreBy.init(intValue: $0)?.display ?? "" }
    }
  }()

  private lazy var sectionFooter: HeaderFooterView<UIView> = {
    let footerBuilder = { () -> UIView in
      let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
      let goButton = PrimaryButton().apply {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Save", for: .normal)
      }

      container.addSubview(goButton)

      goButton.addTarget(self, action: #selector(self.nextTapped), for: .touchUpInside)
      goButton.constrainWidth(250)
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
