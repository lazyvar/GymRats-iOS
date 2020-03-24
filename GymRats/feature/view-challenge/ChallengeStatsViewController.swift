//
//  ChallengeStatsViewController.swift
//  GymRats
//
//  Created by mack on 12/7/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import CRRefresh
class ChallengeStatsViewController: UITableViewController {
  enum SortBy: Int, CaseIterable {
    case workouts
    case duration
    case distance
    case steps
    case calories
    case points
    
    var title: String {
      switch self {
      case .workouts: return "workouts"
      case .steps:    return "steps"
      case .calories: return "calories"
      case .points:   return "points"
      case .duration: return "duration"
      case .distance: return "distance"
      }
    }
    
    var description: String {
      switch self {
      case .workouts: return "workouts"
      case .steps:    return "steps"
      case .calories: return "calories"
      case .points:   return "points"
      case .duration: return "minutes"
      case .distance: return "miles"
      }
    }
  }
  
  private let disposeBag = DisposeBag()
  
  private let challenge: Challenge

  private var _users: [Int: Account] = [:]
  private var users: [Account] {
    get {
      switch self.sortby {
      case .workouts:
        return usersSortedByWorkouts
      case .duration:
        return usersSortedByDuration
      case .distance:
        return usersSortedByDistance
      case .steps:
        return usersSortedBySteps
      case .calories:
        return usersSortedByCalories
      case .points:
        return usersSortedByPoints
      }
    }
  }
    
  private var workouts: [Workout] = []
  private var sortby: SortBy {
    get {
      let cached = UserDefaults.standard.integer(forKey: "challenge_stats_\(challenge.id)_sort_by_integer")
      
      return SortBy(rawValue: cached) ?? .workouts
    }
    set {
      UserDefaults.standard.set(newValue.rawValue, forKey: "challenge_stats_\(challenge.id)_sort_by_integer")
    }
  }
    
  private lazy var selectedSortBy: SortBy = self.sortby
  
  private var userToWorkoutTotalCache: [Int: Int] = [:]
  private var userToDurationTotalCache: [Int: Int] = [:]
  private var userToDistanceTotalCache: [Int: Double] = [:]
  private var userToStepsTotalCache: [Int: Int] = [:]
  private var userToCaloriesCache: [Int: Int] = [:]
  private var userToPointsCache: [Int: Int] = [:]

  private var usersSortedByWorkouts: [Account] = []
  private var usersSortedByDuration: [Account] = []
  private var usersSortedByDistance: [Account] = []
  private var usersSortedBySteps: [Account] = []
  private var usersSortedByCalories: [Account] = []
  private var usersSortedByPoints: [Account] = []

  init(challenge: Challenge) {
    self.challenge = challenge

    super.init(style: .grouped)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupBackButton()
    
    tableView.register(UINib(nibName: "SegmentedCell", bundle: nil), forCellReuseIdentifier: "celly")
    tableView.register(UINib(nibName: "RatsCell", bundle: nil), forCellReuseIdentifier: "rat")
    tableView.register(UINib(nibName: "DateProgressCell", bundle: nil), forCellReuseIdentifier: "date")
    tableView.register(UINib(nibName: "StatsBabyCell", bundle: nil), forCellReuseIdentifier: "baby")
    tableView.separatorStyle = .none
    tableView.backgroundColor = .background
    tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
      self?.fetch()
    }

    self.showLoadingBar()
    
    fetch()
  }

  @objc func fetch() {
    Observable.combineLatest(gymRatsAPI.getMembers(for: challenge), gymRatsAPI.getAllWorkouts(for: challenge))
      .subscribe(onNext: { [weak self] m, w in
        guard let self = self else { return }
        
        self.tableView.cr.endHeaderRefresh()
        self.hideLoadingBar()
        
        if let error = m.error ?? w.error {
          Alert.presentAlert(error: error)
          return
        }
        
        self.workouts = w.object ?? []
        
        for member in (m.object ?? []) {
          self._users[member.id] = member
        }
        
        self.calc()
        self.tableView.reloadData()
      })
      .disposed(by: disposeBag)
  }
    
  func calc() {
    func update(_ user: Int, with workout: Workout) {
      self.userToWorkoutTotalCache[user] = self.userToWorkoutTotalCache[user, default: 0] + 1
      self.userToDurationTotalCache[user] = self.userToDurationTotalCache[user, default: 0] + (workout.duration ?? 0)
      self.userToDistanceTotalCache[user] = self.userToDistanceTotalCache[user, default: 0] + (workout.distance != nil ? Double(workout.distance!) ?? 0 : 0)
      self.userToStepsTotalCache[user] = self.userToStepsTotalCache[user, default: 0] + (workout.steps ?? 0)
      self.userToCaloriesCache[user] = self.userToCaloriesCache[user, default: 0] + (workout.calories ?? 0)
      self.userToPointsCache[user] = self.userToPointsCache[user, default: 0] + (workout.points ?? 0)
    }
      
    for member in _users {
      let user = member.value.id
      
      self.userToWorkoutTotalCache[user] = 0
      self.userToDurationTotalCache[user] = 0
      self.userToDistanceTotalCache[user] = 0
      self.userToStepsTotalCache[user] = 0
      self.userToCaloriesCache[user] = 0
      self.userToPointsCache[user] = 0
    }
    
    for workout in workouts {
      update(workout.gymRatsUserId, with: workout)
    }

    self.usersSortedByWorkouts = userToWorkoutTotalCache.sorted(by: { a, b -> Bool in
      a.value > b.value
    }).compactMap({ args in
      return _users[args.key]
    })

    self.usersSortedByDuration = userToDurationTotalCache.sorted(by: { a, b -> Bool in
      a.value > b.value
    }).compactMap({ args in
      return _users[args.key]
    })

    self.usersSortedByDistance = userToDistanceTotalCache.sorted(by: { a, b -> Bool in
      a.value > b.value
    }).compactMap({ args in
      return _users[args.key]
    })

    self.usersSortedBySteps = userToStepsTotalCache.sorted(by: { a, b -> Bool in
      a.value > b.value
    }).compactMap({ args in
      return _users[args.key]
    })

    self.usersSortedByCalories = userToCaloriesCache.sorted(by: { a, b -> Bool in
      a.value > b.value
    }).compactMap({ args in
      return _users[args.key]
    })

    self.usersSortedByPoints = userToPointsCache.sorted(by: { a, b -> Bool in
      a.value > b.value
    }).compactMap({ args in
      return _users[args.key]
    })

    tableView.reloadData()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 2
    case 1:
      return users.count + 1
    default:
      fatalError("Whooop!")
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard indexPath.section == 1, indexPath.row > 0 else { return }
    
    let profile = ProfileViewController(account: users[indexPath.row - 1], challenge: challenge)
    
    push(profile)
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label = UILabel()
    label.frame = CGRect(x: 15, y: 0, width: view.frame.width - 30, height: 30)
    label.font = .proRoundedBold(size: 28)
    label.backgroundColor = .clear
    
    switch section {
    case 0:
        label.text = "Stats"
    case 1:
        label.text = "Rats"
    default:
        fatalError("5 minutes")
    }
    
    let headerView = UIView()
    headerView.addSubview(label)
    headerView.backgroundColor = .clear
    
    return headerView
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      switch indexPath.row {
      case 0:
        return dateCell(tableView: tableView)
      case 1:
        return statsCell()
      default:
        fatalError("WOW")
      }
    case 1:
      switch indexPath.row {
      case 0:
        return cellycell()
      default:
        return userCell(row: indexPath.row - 1)
      }
    default:
      fatalError("Stop")
    }
  }
  
  func cellycell() -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "celly") as! SegmentedCell
    cell.selectionStyle = .none
    cell.sortbyTextField.text = self.sortby.title.capitalized
    cell.picker.delegate = self
    cell.picker.dataSource = self
    cell.picker.selectRow(SortBy.allCases.enumerated().first(where: { $0.element == self.sortby })!.offset, inComponent: 0, animated: false)
      
    let toolBar = UIToolbar()
    toolBar.barStyle = .default
    toolBar.isTranslucent = true
    toolBar.tintColor = .brand
    toolBar.sizeToFit()

    let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(donePicker))
    let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelPicker))

    toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
    toolBar.isUserInteractionEnabled = true
    
    cell.sortbyTextField.inputAccessoryView = toolBar
    
    return cell
  }
  
  @objc func donePicker() {
    self.sortby = selectedSortBy
    self.tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
  }
  
  @objc func cancelPicker() {
    self.view.endEditing(true)
    self.selectedSortBy = self.sortby
  }
  
  func dateCell(tableView: UITableView) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "date") as! DateProgressCell
    cell.doTheThing(challenge: challenge)
    cell.selectionStyle = .none
    
    return cell
  }
  
  func statsCell() -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "baby") as! StatsBabyCell
    cell.wow(challenge, workouts, users)
    
    return cell
  }
    
  func userCell(row: Int) -> UITableViewCell {
    let user = users[row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "rat") as! RatsCell
    cell.selectionStyle = .default
    
    let score: String
    switch sortby {
    case .workouts:
      score = String(self.userToWorkoutTotalCache[user.id, default: 0])
    case .duration:
      score = String(self.userToDurationTotalCache[user.id, default: 0])
    case .distance:
      score = String(self.userToDistanceTotalCache[user.id, default: 0])
    case .steps:
      score = String(self.userToStepsTotalCache[user.id, default: 0])
    case .calories:
      score = String(self.userToCaloriesCache[user.id, default: 0])
    case .points:
      score = String(self.userToPointsCache[user.id, default: 0])
    }
    
    cell.configure(withHuman: user, score: score, scoredBy: sortby)
    
    return cell
  }
}

extension ChallengeStatsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return SortBy.allCases.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return SortBy.allCases[row].title.capitalized
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedSortBy = SortBy.allCases[row]
  }
}
