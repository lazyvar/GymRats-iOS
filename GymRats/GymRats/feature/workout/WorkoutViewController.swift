//
//  WorkoutViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import YogaKit
import MapKit

class WorkoutViewController: UITableViewController {

    let disposeBag = DisposeBag()
    let user: User
    let workout: Workout
    let challenge: Challenge?
    
    var comments: [Comment] = []
    
    let refresher = UIRefreshControl()
    weak var textField: UITextField?
    let userImageView: UserImageView = UserImageView()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    init(user: User, workout: Workout, challenge: Challenge?) {
        self.user = user
        self.workout = workout
        self.challenge = challenge
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem (
            image: UIImage(named: "more-vertical"),
            style: .plain,
            target: self,
            action: #selector(showMenu)
        )

        setupBackButton()
        
        let containerView = UIView()
        containerView.frame = view.frame
        containerView.backgroundColor = .white
        
        let headerView = UIView()
        
        let userImageView = UserImageView()
        userImageView.load(avatarInfo: user)
        
        let usernameLabel: UILabel = UILabel()
        usernameLabel.font = .body
        usernameLabel.text = user.fullName

        let timeLabel: UILabel = UILabel()
        timeLabel.font = .details
        timeLabel.text = workout.createdAt.challengeTime
        timeLabel.textAlignment = .right
        
        headerView.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .row
            layout.justifyContent = .flexStart
            layout.padding = 15
        }
        
        userImageView.configureLayout { layout in
            layout.isEnabled = true
            layout.width = 32
            layout.height = 32
        }
        
        usernameLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.marginLeft = 10
        }

        timeLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.flexGrow = 1
        }

        headerView.addSubview(userImageView)
        headerView.addSubview(usernameLabel)
        headerView.addSubview(timeLabel)

        headerView.yoga.applyLayout(preservingOrigin: true)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(transitionToProfile))
        tap.numberOfTapsRequired = 1
        
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(tap)
        
        containerView.configureLayout { layout in
            layout.isEnabled = true
            layout.flexDirection = .column
            layout.justifyContent = .flexStart
        }
        
        containerView.addSubview(headerView)

        if let pictureUrl = workout.photoUrl, let url = URL(string: pictureUrl) {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = .whiteSmoke

            imageView.configureLayout { layout in
                layout.isEnabled = true
                layout.flexGrow = 1
                layout.width = YGValue(self.view.frame.width)
                layout.height = YGValue(self.view.frame.width)
            }

            imageView.kf.setImage(with: url)

            containerView.addSubview(imageView)
        }
        
        if let placeId = workout.googlePlaceId {
            GService.getPlaceInformation(forPlaceId: placeId)
                .subscribe { event in
                    switch event {
                    case .next(let place):
                        let mapView = MKMapView()
                        let initialLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
                        let coordinateRegion = MKCoordinateRegion (
                            center: initialLocation.coordinate,
                            latitudinalMeters: 500, longitudinalMeters: 500
                        )
                        let annotation = PlaceAnnotation (
                            title: place.name,
                            coordinate: CLLocationCoordinate2D (
                                latitude: place.latitude,
                                longitude: place.longitude
                            )
                        )
                        
                        mapView.setRegion(coordinateRegion, animated: true)
                        mapView.mapType = .standard
                        mapView.isUserInteractionEnabled = false
                        mapView.addAnnotation(annotation)
                        
                        mapView.configureLayout { layout in
                            layout.isEnabled = true
                            layout.width = YGValue(self.view.frame.width)
                            layout.height = 115
                            layout.marginTop = 2
                        }
                        DispatchQueue.main.async { [weak self] in
                            if self?.workout.photoUrl == nil {
                                containerView.insertSubview(mapView, at: 1)
                            } else {
                                containerView.insertSubview(mapView, at: 2)
                            }
                            containerView.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: .flexibleHeight)
                        }
                    default: break
                    }
                }.disposed(by: disposeBag)
        }
        
        let titleLabel: UILabel = UILabel()
        titleLabel.font = .body
        titleLabel.text = workout.title
        
        titleLabel.configureLayout { layout in
            layout.isEnabled = true
            layout.margin = 15
        }
        
        containerView.addSubview(titleLabel)
        
        if let description = workout.description {
            let descriptionLabel = UILabel()
            descriptionLabel.text = description
            descriptionLabel.numberOfLines = 0
            descriptionLabel.font = .body
            descriptionLabel.configureLayout { layout in
                layout.isEnabled = true
                layout.margin = 15
                layout.marginTop = 0
            }
            
            containerView.addSubview(descriptionLabel)
        }

        containerView.yoga.applyLayout(preservingOrigin: true)

        tableView.tableHeaderView = containerView
        tableView.separatorStyle = .none
        tableView.addSubview(refresher)
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")

        refresher.addTarget(self, action: #selector(fetchComments), for: .valueChanged)
        
        fetchComments()
        
        let tapToHideKeyboard = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tapToHideKeyboard.addTarget(self, action: #selector(hideKeyboard))
        
        view.addGestureRecognizer(tapToHideKeyboard)
        
        NotificationCenter.default.addObserver (
            self,
            selector: #selector(fetchComments),
            name: .commentNotification,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        GymRatsApp.coordinator.openWorkoutId = workout.id
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        GymRatsApp.coordinator.openWorkoutId = nil
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func fetchComments() {
        gymRatsAPI.getComments(for: workout)
            .subscribe { event in
                self.refresher.endRefreshing()
                
                switch event {
                case .next(let comments):
                    self.comments = comments
                    self.tableView.reloadData()
                default: break
                }
            }.disposed(by: disposeBag)
    }
    
    func postComment(_ comment: String) {
        self.showLoadingBar(disallowUserInteraction: true)
        
        gymRatsAPI.post(comment: comment, on: workout)
            .subscribe { event in
                self.hideLoadingBar()
                
                switch event {
                case .next(let comments):
                    self.textField?.text = nil
                    self.resignFirstResponder()
                    self.comments = comments
                    self.tableView.reloadData()
                case .error(let error):
                    self.presentAlert(with: error)
                default: break
                }
            }.disposed(by: disposeBag)
    }
    
    @objc func transitionToProfile() {
        self.push(ProfileViewController(user: user, challenge: challenge))
    }
    
    @objc func showMenu() {
        let deleteAction = UIAlertAction(title: "Remove workout", style: .destructive) { _ in
            let areYouSureAlert = UIAlertController(title: "Are you sure?", message: "You will not be able to recover a workout once it has been removed.", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Remove", style: .destructive) { _ in
                self.showLoadingBar()
                gymRatsAPI.deleteWorkout(self.workout)
                    .subscribe({ event in
                        self.hideLoadingBar()
                        
                        switch event {
                        case .error(let error):
                            self.presentAlert(with: error)
                        case .next:
                            self.navigationController?.popViewController(animated: true)
                            NotificationCenter.default.post(name: NSNotification.Name.init("WorkoutDeleted"), object: self.workout)
                        case .completed:
                            break
                        }
                    }).disposed(by: self.disposeBag)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            areYouSureAlert.addAction(deleteAction)
            areYouSureAlert.addAction(cancelAction)
            
            self.present(areYouSureAlert, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertViewController.addAction(deleteAction)
        alertViewController.addAction(cancelAction)

        self.present(alertViewController, animated: true, completion: nil)
    }
    
}

extension WorkoutViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
            let comment = comments[indexPath.row]
            let user: User = comment.gymRatsUser
            
            cell.userImageView.load(avatarInfo: user)
            cell.nameLabel.text = user.fullName
            cell.commentLabel.text = comment.content
            cell.selectionStyle = .blue
            
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            return cell
        } else {
            let cell = UITableViewCell()
            
            let imageView = UserImageView()
            imageView.load(avatarInfo: GymRatsApp.coordinator.currentUser)
            
            let textField = UITextField()
            textField.borderStyle = .roundedRect
            textField.placeholder = "Enter comment"
            textField.delegate = self
            textField.returnKeyType = .send
            textField.isUserInteractionEnabled = true
            textField.font = .details
            
            self.textField = textField
            
            cell.addSubview(imageView)
            cell.addSubview(textField)
            
            cell.addConstraintsWithFormat(format: "V:|-10-[v0(30)]", views: imageView)
            cell.addConstraintsWithFormat(format: "V:|-10-[v0(30)]", views: textField)
            cell.addConstraintsWithFormat(format: "H:|-15-[v0(30)]-10-[v1]-15-|", views: imageView, textField)
            
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < comments.count {
            return UITableView.automaticDimension
        } else {
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.row < comments.count else { return }
        
        let comment = comments[indexPath.row]

        push(ProfileViewController(user: comment.gymRatsUser, challenge: challenge))
    }
    
}

extension WorkoutViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        
        guard !text.isEmpty else {
            view.endEditing(true)
            return false
        }
        
        postComment(text)
        
        return false
    }
    
}

class PlaceAnnotation: NSObject, MKAnnotation {

    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return nil
    }
}
