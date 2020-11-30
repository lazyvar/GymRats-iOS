//
//  ProfileViewController.swift
//  GymRats
//
//  Created by mack on 3/16/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class ProfileViewController: UIViewController {
  private let account: Account
  private let challenge: Challenge?
  private let disposeBag = DisposeBag()
  private var workouts: [Workout] = []
  private var workoutsForSelectedDay: [Workout] = []

  init(account: Account, challenge: Challenge?) {
    self.account = account
    self.challenge = challenge
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @IBOutlet private weak var userImageView: UserImageView!

  @IBOutlet private weak var nameLabel: UILabel! {
    didSet {
      nameLabel.font = .body
      nameLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet private weak var workoutsLabel: UILabel! {
    didSet {
      workoutsLabel.font = .body
      nameLabel.textColor = .primaryText
    }
  }

  @IBOutlet private weak var backToThePast: UIButton! {
    didSet {
      backToThePast.setTitleColor(.primaryText, for: .normal)
    }
  }
  
  @IBOutlet private weak var backToTheFuture: UIButton! {
     didSet {
       backToTheFuture.setTitleColor(.primaryText, for: .normal)
     }
   }

  @IBOutlet private weak var calendarMenuView: CVCalendarMenuView! {
    didSet {
      calendarMenuView.menuViewDelegate = self
      calendarMenuView.backgroundColor = .background
      calendarMenuView.dayOfWeekTextColor = .primaryText
    }
  }
  
  @IBOutlet private weak var calendarView: CVCalendarView! {
    didSet {
      calendarView.calendarAppearanceDelegate = self
      calendarView.calendarDelegate = self
      calendarView.backgroundColor = .background
    }
  }
  
  @IBOutlet private weak var monthLabel: UILabel! {
    didSet {
      monthLabel.text = Date().toFormat("MMMM yyyy")
      monthLabel.numberOfLines = 1
      monthLabel.textAlignment = .center
      monthLabel.font = .h2
      monthLabel.textColor = .primaryText
    }
  }
  
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.dataSource = self
      tableView.delegate = self
      tableView.registerCellNibForClass(WorkoutListCell.self)
      tableView.backgroundColor = .background
      tableView.separatorStyle = .none
    }
  }
  
  private let currentCalendar: Calendar = {
    let timeZone = TimeZone.current
    
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    
    return calendar
  }()
  
  private weak var observer: NSObjectProtocol?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .background
    navigationItem.largeTitleDisplayMode = .never
    
    nameLabel.text = account.fullName
    userImageView.load(account)
    
    if let challenge = challenge, challenge.isPast {
      calendarView.toggleViewWithDate(challenge.endDate)
    }
    
    setupBackButton()
    loadWorkouts()
    
    observer = NotificationCenter.default.addObserver(forName: .workoutDeleted, object: nil, queue: nil) { notification in
      self.loadWorkouts()
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(currentAccountUpdated), name: .currentAccountUpdated, object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  
    Track.screen(.profile)
  }
      
  @objc private func currentAccountUpdated(notification: Notification) {
    guard let account = notification.object as? Account else { return }
  
    nameLabel.text = account.fullName
    userImageView.load(account)
    loadWorkouts()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    // Commit frames' updates
    self.calendarMenuView.commitMenuViewUpdate()
    self.calendarView.commitCalendarViewUpdate()
  }
  
  @IBAction private func timeTravelBackwards(_ sender: Any) {
    calendarView.loadPreviousView()
  }
  
  @IBAction private func timeTravelForwards(_ sender: Any) {
    calendarView.loadNextView()
  }

  @objc func pushSettings() {
    push(
      SettingsViewController()
    )
  }
    
  private func loadWorkouts() {
    let workouts: Observable<NetworkResult<[Workout]>>
    
    if let challenge = challenge {
      workouts = gymRatsAPI.getWorkouts(for: account, in: challenge)
    } else {
      workouts = gymRatsAPI.getAllWorkouts(for: account)
    }
    
    showLoadingBar()
    
    let mappedWorkouts = workouts.map { workouts -> [Workout] in
      let workouts = workouts.object ?? []
      
      return workouts.reduce([], { (workouts, workout) -> [Workout] in
        if workouts.contains(where: { anotherWorkout in
          workout.challengeId != anotherWorkout.challengeId &&
          workout.occurredAt.compareCloseTo(anotherWorkout.occurredAt, precision: 3600)
        }) {
          return workouts
        } else {
          return workouts + [workout]
        }
      })
    }
    
    mappedWorkouts
      .map { workouts in
        if workouts.count == 1 {
          return "1 total workout"
        } else {
          return "\(workouts.count) total workouts"
        }
      }
      .catchErrorJustReturn("? total workouts")
      .bind(to: workoutsLabel.rx.text)
      .disposed(by: disposeBag)
    
    mappedWorkouts.subscribe { [weak self] event in
      self?.hideLoadingBar()
      
      switch event {
      case .next(let value):
          self?.refreshScreen(with: value)
      case .error(let error):
          self?.presentAlert(with: error)
      case .completed:
          break
      }
    }
    .disposed(by: disposeBag)
  }
  
  private func refreshScreen(with workouts: [Workout]) {
    self.workouts = workouts
    self.calendarView.contentController.refreshPresentedMonth()
    self.showWorkouts(self.workouts.workouts(on: calendarView.presentedDate.convertedDate()!))
  }
  
  private func showWorkouts(_ workouts: [Workout]) {
    workoutsForSelectedDay = workouts
    tableView?.reloadData()
  }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return workoutsForSelectedDay.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let workout = workoutsForSelectedDay[safe: indexPath.row] else { return UITableViewCell() }
    
    return WorkoutListCell.configure(tableView: tableView, indexPath: indexPath, workout: workout)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard let workout = workoutsForSelectedDay[safe: indexPath.row] else { return }
  
    push(
      WorkoutViewController(workout: workout, challenge: challenge)
    )
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard workoutsForSelectedDay.isNotEmpty else { return nil }
    
    let label = UILabel()
    label.frame = CGRect(x: 15, y: 0, width: view.frame.width, height: 30)
    label.backgroundColor = .clear
    label.font = .proRoundedBold(size: 16)
    label.text = calendarView.presentedDate?.convertedDate()?.toFormat("EEEE, MMM d")
    
    let headerView = UIView()
    headerView.addSubview(label)
    headerView.backgroundColor = .clear
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }
}

extension ProfileViewController: CVCalendarViewDelegate, CVCalendarViewAppearanceDelegate, CVCalendarMenuViewDelegate {
  func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
    showWorkouts(workouts.workouts(on: dayView.swiftDate))
  }
  
  func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat { return 15 }
  
  func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
    return workouts.workoutsExist(on: dayView.swiftDate)
  }
  
  func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
    let limitedWorkouts = min(3, workouts.workouts(on: dayView.swiftDate).count)
    
    return .init(repeating: .brand, count: limitedWorkouts)
  }
  
  func presentedDateUpdated(_ date: CVDate) {
    monthLabel.text = date.convertedDate()!.toFormat("MMMM yyyy")
    self.calendarView.contentController.refreshPresentedMonth()
  }
  
  func presentationMode() -> CalendarMode { return .monthView }
  
  func firstWeekday() -> Weekday { return .sunday }
  
  func shouldAutoSelectDayOnMonthChange() -> Bool { return true }
  
  func shouldSelectRange() -> Bool { return false }
  
  func calendar() -> Calendar? { return currentCalendar }
}

extension Array where Element == Workout {
  func workoutsExist(on date: Date) -> Bool {
    return !self.workouts(on: date).isEmpty
  }
  
  func workouts(on date: Date) -> [Workout] {
    return filter { workout in
      return date.inTimeZone(.utc, isSameDayAs: workout.occurredAt, inTimeZone: .current)
    }
  }
}

extension DayView {
  var swiftDate: Date {
    let timeZone = TimeZone.utc
    
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone

    return date.convertedDate(calendar: calendar)!
  }
}
