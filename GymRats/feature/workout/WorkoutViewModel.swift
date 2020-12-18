//
//  WorkoutViewModel.swift
//  GymRats
//
//  Created by mack on 4/8/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class WorkoutViewModel: ViewModel {
  private let disposeBag = DisposeBag()
  private var workout: Workout!
  private var challenge: Challenge?

  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let transitionEnded = PublishSubject<Void>()
    let tappedRow = PublishSubject<IndexPath>()
    let submittedComment = PublishSubject<String>()
    let tappedDeleteComment = PublishSubject<Comment>()
    let updatedWorkout = PublishSubject<Void>()
  }
  
  struct Output {
    let loading = PublishSubject<Bool>()
    let sections = PublishSubject<[WorkoutSection]>()
    let error = PublishSubject<Error>()
    let navigation = PublishSubject<(Navigation, Screen)>()
    let presentCommentAlert = PublishSubject<Comment>()
  }
  
  let input = Input()
  let output = Output()
  
  func configure(workout: Workout, challenge: Challenge?) {
    self.workout = workout
    self.challenge = challenge
  }
  
  init() {
    let deleteComment = input.tappedDeleteComment
      .flatMap { gymRatsAPI.deleteComment(id: $0.id) }
      .share()

    deleteComment
      .compactMap { $0.error }
      .bind(to:output.error)
      .disposed(by: disposeBag)

    let deleteCommentSuccess = deleteComment
      .compactMap { $0.object }
    
    let submitComment = input.submittedComment
      .flatMap { gymRatsAPI.post(comment: $0, on: self.workout) }
      .share()
    
    submitComment
      .compactMap { $0.error }
      .bind(to:output.error)
      .disposed(by: disposeBag)

    let submitCommentSuccess = submitComment.compactMap { $0.object }
    let loadingComments = Observable.merge(input.transitionEnded, submitCommentSuccess.map { _ in () }, deleteCommentSuccess.map { _ in () })
      .share()
    
    loadingComments
      .map { _ in true }
      .bind(to: output.loading)
      .disposed(by: disposeBag)
    
    let fetchComments = loadingComments
      .flatMap { gymRatsAPI.getComments(for: self.workout) }
      .share()
    
    fetchComments
      .map { _ in false }
      .bind(to: output.loading)
      .disposed(by: disposeBag)
    
    fetchComments
      .compactMap { $0.error }
      .bind(to:output.error)
      .disposed(by: disposeBag)

    let comments = fetchComments
      .compactMap { $0.object }
      .map { $0.map { WorkoutRow.comment($0, onMenuTap: { self.output.presentCommentAlert.onNext($0) }) }}
    
    Observable.merge(input.viewDidLoad, input.updatedWorkout)
      .flatMap { Observable.merge(.just([]), comments) }
      .map { comments -> [WorkoutSection] in
        var headerRows: [WorkoutRow] = []
        
        if self.workout.media.count == 1, let first = self.workout.media.first, first.mediumType == .image {
          headerRows.append(.singleImage(url: first.url))
        } else if self.workout.media.isNotEmpty {
          headerRows.append(.media(media: self.workout.media))
        } else if let photo = self.workout.photoUrl {
          headerRows.append(.singleImage(url: photo))
        }
        
        headerRows.append(contentsOf: [
          .account(self.workout),
          .details(self.workout),
        ])
        
        if let place = self.workout.googlePlaceId {
          headerRows.append(.location(placeID: place))
        }
        
        let headerSection = WorkoutSection(model: 0, items: headerRows)

        let commentSection = WorkoutSection(model: 1, items: comments)
        let newComment = WorkoutRow.newComment { comment in
          self.input.submittedComment.onNext(comment)
        }
        
        let newCommentSection = WorkoutSection(model: 2, items: [newComment, .space])
        
        return [headerSection, commentSection, newCommentSection]
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)
    
    input.tappedRow
      .filter { $0.section == 0  && $0.row == 1 }
      .compactMap { _ -> (Navigation, Screen)? in
        guard let challenge = self.challenge else { return nil }
        
        return (.push(animated: true), .profile(self.workout.account, challenge))
      }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)
    
    input.tappedRow
      .filter { $0.section == 0  && $0.row == 3 }
      .compactMap { _ -> (Navigation, Screen)? in
        guard let place = self.workout.googlePlaceId else { return nil }

        return (.presentInNav(animated: true), .map(placeID: place))
      }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)

      input.tappedRow
        .filter { $0.section == 1 }
        .withLatestFrom(fetchComments.compactMap { $0.object }) { ($0, $1) }
        .compactMap { indexPath, comments -> (Navigation, Screen)? in
          guard let comment = comments[safe: indexPath.row] else { return nil }
          guard let challenge = self.challenge else { return nil }

          return (.push(animated: true), .profile(comment.account, challenge))
        }
        .bind(to: output.navigation)
        .disposed(by: disposeBag)
  }
}
