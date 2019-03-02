//
//  ProfileViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/6/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import CVCalendar
import YogaKit
import SwiftDate

class ProfileViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let user: User
    let challenge: Challenge?
    
    var workouts: [Workout] = []
    
    let totalWorkoutsLabel: UILabel = {
        let label = UILabel()
        label.font = .body
        label.text = "Total workouts: -"
        label.textAlignment = .center
        
        return label
    }()
    
    let monthLabel: UILabel = {
        let label = UILabel()
        label.text = Date().toFormat("MMMM yyyy")
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = .h2
        
        return label
    }()
    
    let calendarMenu: CVCalendarMenuView = {
        let calendarMenu = CVCalendarMenuView()
        
        return calendarMenu
    }()
    
    let calendarView: CVCalendarView = {
        let calendar = CVCalendarView()
        calendar.backgroundColor = .whiteSmoke
        
        return calendar
    }()
    
    let currentCalendar: Calendar = {
        let timeZone = TimeZone(identifier: ActiveChallengeViewController.timeZone)!
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        
        return calendar
    }()
    
    let goBackInTimeButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "left-arrow"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        return button
    }()
    
    let goForwardInTimeButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "right-arrow"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        return button
    }()
    
    init(user: User, challenge: Challenge?) {
        self.user = user
        self.challenge = challenge
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackButton()
        
        calendarMenu.menuViewDelegate = self
        calendarView.calendarAppearanceDelegate = self
        calendarView.calendarDelegate = self
        
        containerView = UIView()
        containerView.frame = view.frame
        
        containerView.backgroundColor = .white
        
        let userImageView = UserImageView()
        userImageView.load(avatarInfo: user)
        
        let usernameLabel: UILabel = UILabel()
        usernameLabel.font = .body
        usernameLabel.text = user.fullName
        usernameLabel.textAlignment = .center
        
        containerView.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.justifyContent = .flexStart
            layout.alignContent = .center
            layout.padding = 15
        }
        
        userImageView.configureLayout { layout in
            layout.isEnabled = true
            layout.width = 72
            layout.height = 72
            layout.flexGrow = 1
            layout.marginBottom = 10
            layout.alignSelf = .center
        }
        
        usernameLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.flexGrow = 1
        }
        
        totalWorkoutsLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.flexGrow = 1
        }
        
        let monthContainer = UIView()
        
        monthContainer.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .row
            layout.alignContent = .center
            layout.justifyContent = .spaceBetween
            layout.width = YGValue(self.view.frame.width - 30)
            layout.padding = 10
        }
        
        goBackInTimeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.alignSelf = .center
            layout.flexShrink = 1
        }
        
        monthLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.alignSelf = .center
            layout.flexGrow = 1
        }
        
        goForwardInTimeButton.configureLayout { layout in
            layout.isEnabled = true
            layout.alignSelf = .center
            layout.flexShrink = 1
        }
        
        monthContainer.addSubview(goBackInTimeButton)
        monthContainer.addSubview(monthLabel)
        monthContainer.addSubview(goForwardInTimeButton)
        
        monthContainer.yoga.applyLayout(preservingOrigin: true)
        
        calendarMenu.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
            layout.width = YGValue(self.view.frame.width - 70)
            layout.height = 15
            layout.marginLeft = 20
        }
        
        calendarView.configureLayout { layout in
            layout.isEnabled = true
            layout.flexGrow = 1
            layout.marginTop = 5
            layout.marginLeft = 20
            layout.width = YGValue(self.view.frame.width - 70)
            layout.height = YGValue(self.view.frame.width - 70)
        }
        
        containerView.addSubview(userImageView)
        containerView.addSubview(usernameLabel)
        containerView.addSubview(totalWorkoutsLabel)
        containerView.addSubview(monthContainer)
        containerView.addSubview(calendarMenu)
        containerView.addSubview(calendarView)
        
        containerView.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: .flexibleHeight)
        containerView.makeScrolly(in: view)
        
        goBackInTimeButton.onTouchUpInside { [weak self] in
            self?.calendarView.loadPreviousView()
        }.disposed(by: disposeBag)
        
        goForwardInTimeButton.onTouchUpInside { [weak self] in
            self?.calendarView.loadNextView()
        }.disposed(by: disposeBag)
        
        loadWorkouts()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("WorkoutDeleted"), object: nil, queue: nil) { notification in
            self.loadWorkouts()
        }
    }
    
    @objc func transitionToSettings() {
        let settings = SettingsViewController()

        self.push(settings)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Commit frames' updates
        self.calendarMenu.commitMenuViewUpdate()
        self.calendarView.commitCalendarViewUpdate()
    }
    
    func loadWorkouts() {
        let workouts: Observable<[Workout]>
        
        if let challenge = challenge {
            workouts = gymRatsAPI.getWorkouts(for: user, in: challenge)
        } else {
            workouts = gymRatsAPI.getAllWorkouts(for: user)
        }
        
        showLoadingBar()
        
        let mappedWorkouts = workouts.map { workouts in
            return workouts.reduce([], { (workouts, workout) -> [Workout] in
                if workouts.contains(where: { anotherWorkout in
                    workout.challengeId != anotherWorkout.challengeId &&
                    workout.createdAt.compareCloseTo(anotherWorkout.createdAt, precision: 3600)
                }) {
                    return workouts
                } else {
                    return workouts + [workout]
                }
            })
        }
        
        mappedWorkouts.map { "Total workouts: \($0.count)" }
            .catchErrorJustReturn("Total workouts: -")
            .bind(to: totalWorkoutsLabel.rx.text)
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
        }.disposed(by: disposeBag)
    }
    
    func refreshScreen(with workouts: [Workout]) {
        self.workouts = workouts
        self.calendarView.contentController.refreshPresentedMonth()
        self.showWorkouts(self.workouts.workouts(on: calendarView.presentedDate.convertedDate()!))
    }
    
    func showWorkouts(_ workouts: [Workout]) {
        let workoutsContainer = UIView()
        workoutsContainer.tag = 111
        
        workoutsContainer.configureLayout { layout in
            layout.isEnabled = true
            layout.flexGrow = 1
            layout.flexDirection = .column
            layout.justifyContent = .flexStart
            layout.paddingLeft = 20
            layout.paddingRight = 20
        }
        
        for (index, workout) in workouts.enumerated() {
            let row = UIView()
            row.tag = index
            
            let titleDetailsContainer = UIView()
            
            let titleLabel = UILabel()
            titleLabel.text = workout.title
            titleLabel.font = .body
            
            let detailsLabel = UILabel()
            detailsLabel.font = .details
            detailsLabel.numberOfLines = 0
            detailsLabel.attributedText = self.detailsLabeText(for: workout)
            
            let timeLabel: UILabel = UILabel()
            timeLabel.font = .details
            timeLabel.text = workout.createdAt.challengeTime
            timeLabel.textAlignment = .right
            
            row.configureLayout { layout in
                layout.isEnabled = true
                layout.flexDirection = .row
                layout.justifyContent = .flexStart
                layout.padding = 5
            }
            
            titleDetailsContainer.configureLayout { layout in
                layout.isEnabled = true
                layout.flexDirection = .column
                layout.justifyContent = .flexStart
            }
            
            timeLabel.configureLayout { layout in
                layout.isEnabled = true
                layout.flexGrow = 1
            }
            
            titleLabel.configureLayout { layout in
                layout.isEnabled = true
                layout.marginTop = 7
                layout.marginRight = 10
            }
            
            detailsLabel.configureLayout { layout in
                layout.isEnabled = true
                layout.marginTop = 3
                layout.marginBottom = 7
                layout.paddingRight = 10
            }

            if let googlePlaceId = workout.googlePlaceId {
                GService.getPlaceInformation(forPlaceId: googlePlaceId)
                    .subscribe { event in
                        if case let .next(val) = event {
                            UIView.transition (
                                with: detailsLabel,
                                duration: 0.2,
                                options: .transitionCrossDissolve,
                                animations: { [weak self] in
                                    detailsLabel.attributedText = self?.detailsLabeText(for: workout, including: val)
                                }, completion: nil
                            )
                        }
                    }.disposed(by: self.disposeBag)
            }
            
            row.addSubview(titleDetailsContainer)
            row.addSubview(timeLabel)
            
            titleDetailsContainer.addSubview(titleLabel)
            titleDetailsContainer.addSubview(detailsLabel)
            
            titleDetailsContainer.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: .flexibleHeight)
            row.yoga.applyLayout(preservingOrigin: true)
            
            row.addDivider()
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.transitionToWorkoutScreen(tap:)))
            tap.numberOfTapsRequired = 1
            
            row.addGestureRecognizer(tap)
            row.isUserInteractionEnabled = true
            
            workoutsContainer.addSubview(row)
        }
        
        workoutsContainer.yoga.applyLayout(preservingOrigin: true)
        
        if let containerView = self.containerView {
            containerView.subviews.first(where: { $0.tag == 111 })?.removeFromSuperview()
            containerView.addSubview(workoutsContainer)
            containerView.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: .flexibleHeight)
        }
    }

    private func detailsLabeText(for workout: Workout, including place: Place? = nil) -> NSAttributedString {
        let details = NSMutableAttributedString()
        
        if workout.photoUrl != nil {
            let cameraImage = NSTextAttachment()
            cameraImage.image = UIImage(named: "camera")
            cameraImage.bounds = CGRect(x: 0, y: -2.5, width: 14, height: 14)
            
            details.append(NSAttributedString(attachment: cameraImage))
            details.append(NSAttributedString(string: "  "))
        }
        
        if let place = place {
            details.append(NSAttributedString(string: " \(place.name)"))
        }
        
        return details
    }

    @objc func transitionToWorkoutScreen(tap: UITapGestureRecognizer) {
        guard let tag = tap.view?.tag else { return }
        
        let date = self.calendarView.presentedDate.convertedDate()!
        
        if let workout = self.workouts.workouts(on: date)[safe: tag] {
            self.push(WorkoutViewController(user: user, workout: workout, challenge: challenge))
        }
    }

}

extension ProfileViewController: CVCalendarViewDelegate, CVCalendarViewAppearanceDelegate, CVCalendarMenuViewDelegate {
    
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    func firstWeekday() -> Weekday {
        return .sunday
    }
    
    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        self.showWorkouts(self.workouts.workouts(on: dayView.swiftDate))
    }
    
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 15
    }
    
    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        return self.workouts.workoutsExist(on: dayView.swiftDate)
    }
    
    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        let limitedWorkouts = min(3, self.workouts.workouts(on: dayView.swiftDate).count)
        
        return .init(repeating: .brand, count: limitedWorkouts)
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        monthLabel.text = date.convertedDate()!.toFormat("MMMM yyyy")
        self.calendarView.contentController.refreshPresentedMonth()
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool { return true }
    
    func shouldSelectRange() -> Bool { return false }
    
    func calendar() -> Calendar? { return currentCalendar }
}

extension Array where Element == Workout {
    
    func workoutsExist(on date: Date) -> Bool {
        return !self.workouts(on: date).isEmpty
    }
    
    func workouts(on date: Date) -> [Workout] {
        return self.filter({ workout in
            let region = Region (
                calendar: Calendar.autoupdatingCurrent,
                zone: TimeZone(abbreviation: ActiveChallengeViewController.timeZone)!,
                locale: Locale.autoupdatingCurrent
            )

            let workoutInRegion = DateInRegion(workout.createdAt, region: region)
            let dateInRegion = DateInRegion(date, region: region)
            
            let daysApart = workoutInRegion.daysApartRespectingRegions(from: dateInRegion)

            return daysApart == 0
        })
    }
    
}

extension DayView {
    
    var swiftDate: Date {
        let timeZone = TimeZone(identifier: ActiveChallengeViewController.timeZone)!
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        return date.convertedDate(calendar: calendar)!
    }
    
}

extension DateInRegion {
    
    func daysApartRespectingRegions(from dateRegion: DateInRegion) -> Int {
        let startCalendar = self.calendar
        let endCalendar = dateRegion.calendar
        
        let startComponents = startCalendar.dateComponents([.month, .day, .year], from: date)
        let endComponents = endCalendar.dateComponents([.month, .day, .year], from: dateRegion.date)
        
        let difference = Calendar.current.dateComponents (
            [.day],
            from: startComponents,
            to: endComponents
        )

        return difference.day ?? 0
    }
    
}
