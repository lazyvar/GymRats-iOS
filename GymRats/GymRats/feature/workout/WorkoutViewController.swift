//
//  WorkoutViewController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import MapKit
import SkeletonView
import Kingfisher

class WorkoutViewController: UITableViewController {

    let disposeBag = DisposeBag()
    let user: Account
    let workout: Workout
    let challenge: Challenge?
    
    var comments: [Comment] = []
    
    let refresher = UIRefreshControl()
    weak var textField: UITextField?
    let userImageView: UserImageView = UserImageView()
    
    var postingComment = false
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    init(user: Account, workout: Workout, challenge: Challenge?) {
        self.user = user
        self.workout = workout
        self.challenge = challenge
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    weak var headerView: WorkoutHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        let moreVert = UIImage(named: "more-vertical")!.withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem (
            image: moreVert,
            style: .plain,
            target: self,
            action: #selector(showMenu)
        )
        button.tintColor = .lightGray
        
        navigationItem.rightBarButtonItem = button

        setupBackButton()
        
        navigationItem.largeTitleDisplayMode = .never
        
        self.headerView = WorkoutHeaderView.instanceFromNib()
        headerView.configure(user: user, workout: workout, challenge: challenge, width: tableView.frame.width)
        headerView.delegate = self
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
        tableView.addSubview(refresher)
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")

        refresher.addTarget(self, action: #selector(fetchComments), for: .valueChanged)
        
        fetchComments()
        
        let tapToHideKeyboard = UITapGestureRecognizer()
        tapToHideKeyboard.numberOfTapsRequired = 1
        tapToHideKeyboard.addTarget(self, action: #selector(hideKeyboard))
        tapToHideKeyboard.cancelsTouchesInView = false
        
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
                  guard let comments = comments.object else { return }
                  
                    self.comments = comments
                    self.tableView.reloadData()
                default: break
                }
            }.disposed(by: disposeBag)
    }
    
    func postComment(_ comment: String) {
        guard !postingComment else { return }
        
        self.showLoadingBar(disallowUserInteraction: true)
        self.postingComment = true
        gymRatsAPI.post(comment: comment, on: workout)
            .subscribe { event in
                self.postingComment = false
                self.hideLoadingBar()
                
                switch event {
                case .next(let comments):
                    Track.event(.commentedOnWorkout)
                    guard let comments = comments.object else { return }
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

extension WorkoutViewController: WorkoutHeaderViewDelegate {
    func tappedHeader() {
        self.transitionToProfile()
    }
    func layoutTableView() {
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
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
            let user: Account = comment.gymRatsUser
            let currentUser = GymRats.currentAccount!
            
            cell.userImageView.load(avatarInfo: user)
            cell.nameLabel.text = user.fullName
            cell.commentLabel.text = comment.content
            cell.selectionStyle = .blue
            
            cell.menu.isHidden = comment.gymRatsUser.id != currentUser.id
            
            cell.menuTappedBlock = { [weak self] in
                guard let self = self else { return }
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let delete = UIAlertAction(title: "Delete comment", style: .destructive) { [weak self] _ in
                    let areYouSureAlert = UIAlertController(title: "Are you sure?", message: "This will permanently remove the comment.", preferredStyle: .alert)
                    
                    let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                        guard let self = self else { return }
                        self.showLoadingBar()
                        gymRatsAPI.deleteComment(id: comment.id)
                            .subscribe { e in
                                self.hideLoadingBar()

                                switch e {
                                case .next:
                                    self.fetchComments()
                                case .error(let error):
                                    self.presentAlert(with: error)
                                default: break
                                }
                        }.disposed(by: self.disposeBag)
                    }
                    
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    areYouSureAlert.addAction(delete)
                    areYouSureAlert.addAction(cancel)
                    
                    self?.present(areYouSureAlert, animated: true, completion: nil)
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(delete)
                alert.addAction(cancel)
                
                self.present(alert, animated: true, completion: nil)
            }
            
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            return cell
        } else {
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            
            let imageView = UserImageView()
            imageView.load(avatarInfo: GymRats.currentAccount)
            
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
            cell.addConstraintsWithFormat(format: "H:|-10-[v0(30)]-10-[v1]-10-|", views: imageView, textField)
            
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
