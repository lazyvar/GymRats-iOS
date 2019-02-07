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
    
    var workouts: [Workout] = []
    
    let totalWorkoutsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.text = "Total workouts: -"
        
        return label
    }()
    
    let monthLabel: UILabel = {
        let label = UILabel()
        label.text = Date().toFormat("MMMM yyyy")
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .light)
        
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
    
    let workoutsContainer: UIView = UIView()
    
    init(user: User) {
        self.user = user
        
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
        
        let headerView = UIView()
        
        let userImageView = UserImageView()
        userImageView.load(avatarInfo: user)
        
        let usernameLabel: UILabel = UILabel()
        usernameLabel.font = UIFont.systemFont(ofSize: 16)
        usernameLabel.text = user.fullName
        
        headerView.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .row
            layout.justifyContent = .flexStart
        }
        
        userImageView.configureLayout { layout in
            layout.isEnabled = true
            layout.width = 44
            layout.height = 44
        }
        
        usernameLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginLeft = 10
        }
        
        headerView.addSubview(userImageView)
        headerView.addSubview(usernameLabel)
        
        headerView.yoga.applyLayout(preservingOrigin: true)
        
        containerView.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.justifyContent = .flexStart
            layout.padding = 15
        }
        
        totalWorkoutsLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }
        
        monthLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 15
        }
        
        calendarMenu.configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = 10
            layout.width = YGValue(self.view.frame.width - 30)
            layout.height = 15
        }
        
        calendarView.configureLayout { layout in
            layout.isEnabled = true
            layout.flexGrow = 1
            layout.marginTop = 5
            layout.width = YGValue(self.view.frame.width - 60)
            layout.height = YGValue(self.view.frame.width - 60)
            layout.marginLeft = 15
        }
        
        workoutsContainer.configureLayout { layout in
            layout.isEnabled = true
            layout.flexGrow = 1
            layout.flexDirection = .column
            layout.justifyContent = .flexStart
        }
        
        containerView.addSubview(headerView)
        containerView.addSubview(totalWorkoutsLabel)
        containerView.addSubview(monthLabel)
        containerView.addSubview(calendarMenu)
        containerView.addSubview(calendarView)
        containerView.addSubview(workoutsContainer)
        
        containerView.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: .flexibleHeight)
        containerView.makeScrolly(in: view)
        
        loadWorkouts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Commit frames' updates
        self.calendarMenu.commitMenuViewUpdate()
        self.calendarView.commitCalendarViewUpdate()
    }
    
    func loadWorkouts() {
        let workouts = gymRatsAPI.getWorkouts(for: user)
        
        workouts.map { "Total workouts: \($0.count)" }
            .bind(to: totalWorkoutsLabel.rx.text)
            .disposed(by: disposeBag)
        
        workouts.then { [weak self] workouts in
            self?.refreshScreen(with: workouts)
            }.disposed(by: disposeBag)
    }
    
    func refreshScreen(with workouts: [Workout]) {
        self.workouts = workouts
        self.calendarView.contentController.refreshPresentedMonth()
        self.showWorkouts(self.workouts.workouts(on: calendarView.presentedDate.convertedDate()!))
    }
    
    func showWorkouts(_ workouts: [Workout]) {
        UIView.animate(withDuration: 0.25) {
            self.workoutsContainer.removeAllSubviews()
            
            for (index, workout) in workouts.enumerated() {
                let row = UIView()
                row.tag = index
                
                let titleDetailsContainer = UIView()
                
                let titleLabel = UILabel()
                titleLabel.text = workout.title
                titleLabel.font = UIFont.systemFont(ofSize: 16)
                
                let detailsLabel = UILabel()
                detailsLabel.font = UIFont.systemFont(ofSize: 13)
                detailsLabel.text = "Details"
                
                let timeLabel: UILabel = UILabel()
                timeLabel.font = UIFont.systemFont(ofSize: 12)
                timeLabel.text = workout.date.localTime
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
                    layout.marginRight = 10
                }
                
                row.addSubview(titleDetailsContainer)
                row.addSubview(timeLabel)
                
                titleDetailsContainer.addSubview(titleLabel)
                titleDetailsContainer.addSubview(detailsLabel)
                
                titleDetailsContainer.yoga.applyLayout(preservingOrigin: true)
                row.yoga.applyLayout(preservingOrigin: true)
                
                row.addDivider()
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.transitionToWorkoutScreen(tap:)))
                tap.numberOfTapsRequired = 1
                
                row.addGestureRecognizer(tap)
                row.isUserInteractionEnabled = true
                
                self.workoutsContainer.addSubview(row)
            }
            
            self.workoutsContainer.configureLayout { layout in
                layout.isEnabled = true
                layout.flexGrow = 1
                layout.flexDirection = .column
                layout.justifyContent = .flexStart
            }
            
            self.workoutsContainer.yoga.applyLayout(preservingOrigin: true)
            
            if let containerView = self.containerView {
                containerView.yoga.applyLayout(preservingOrigin: true)
            }
        }
    }
    
    @objc func transitionToWorkoutScreen(tap: UITapGestureRecognizer) {
        guard let tag = tap.view?.tag else { return }
        
        let date = self.calendarView.presentedDate.convertedDate()!
        
        if let workout = self.workouts.workouts(on: date)[safe: tag] {
            self.push(WorkoutViewController(user: user, workout: workout))
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
        return .init(repeating: .brand, count: self.workouts.workouts(on: dayView.swiftDate).count)
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
        return self.workouts(on: date).isNotEmpty
    }
    
    func workouts(on date: Date) -> [Workout] {
        return self.filter({ workout in
            let region = Region (
                calendar: Calendar.autoupdatingCurrent,
                zone: TimeZone(abbreviation: ActiveChallengeViewController.timeZone)!,
                locale: Locale.autoupdatingCurrent
            )

            let workoutInRegion = DateInRegion(workout.date, region: region)
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
