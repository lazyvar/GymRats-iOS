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
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let tappedRow = PublishSubject<IndexPath>()
    let submittedComment = PublishSubject<String>()
    let tappedDeleteComment = PublishSubject<Comment>()
  }
  
  struct Output {
    let sections = PublishSubject<[WorkoutSection]>()
    let error = PublishSubject<Error>()
    let navigation = PublishSubject<(Navigation, Screen)>()
    let presentCommentAlert = PublishSubject<Comment>()
  }
  
  let input = Input()
  let output = Output()
  
  func configure(workout: Workout) {
    self.workout = workout
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
    let fetchComments = Observable.merge(input.viewDidLoad, submitCommentSuccess.map { _ in () }, deleteCommentSuccess.map { _ in () })
      .flatMap { gymRatsAPI.getComments(for: self.workout) }
      .share()
    
    fetchComments
      .compactMap { $0.error }
      .bind(to:output.error)
      .disposed(by: disposeBag)

    let comments = fetchComments
      .compactMap { $0.object }
      .map { $0.map { WorkoutRow.comment($0, onMenuTap: { self.output.presentCommentAlert.onNext($0) }) } }
        
    input.viewDidLoad
      .flatMap { Observable.merge(.just([]), comments) }
      .map { comments -> [WorkoutSection] in
        let header: [WorkoutRow] = [
          .image(url: self.workout.photoUrl ?? ""),
          .account(self.workout),
          .details(self.workout)
        ]
        
        let newComment = WorkoutRow.newComment { comment in
          self.input.submittedComment.onNext(comment)
        }
        
        return [.init(model: .instance, items: header + comments + [newComment])]
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)
  }
}
