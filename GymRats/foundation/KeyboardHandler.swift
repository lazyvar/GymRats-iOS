//
//  KeyboardHandler.swift
//  GymRats
//
//  Created by mack on 12/15/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class KeyboardHandler {
  let scrollView: UIScrollView
  let stackView: UIStackView
  
  var observer: AnyObject?
  var keyboardHeightConstraint: NSLayoutConstraint!

  struct Info {
    let frame: CGRect
    let duration: Double
    let animationOptions: UIView.AnimationOptions
  }

  init(scrollView: UIScrollView, stackView: UIStackView) {
    self.scrollView = scrollView
    self.stackView = stackView
    
    setup()
  }
  
  func setup() {
    let space = UIView()
    
    keyboardHeightConstraint = space.heightAnchor.constraint(equalToConstant: 0)
    keyboardHeightConstraint.isActive = true
    stackView.addArrangedSubview(space)
    
    observer = NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillChangeFrameNotification,
      object: nil,
      queue: .main,
      using: { [weak self] notification in
        self?.handle(notification)
      }
    )
  }
  
  func handle(_ notification: Notification) {
    guard let info = convert(notification: notification) else { return }
    let isHiding = info.frame.origin.y == UIScreen.main.bounds.height
    
    keyboardHeightConstraint.constant = isHiding ? 0 : info.frame.height
    
    UIView.animate(
      withDuration: info.duration,
      delay: 0,
      options: info.animationOptions,
      animations: {
        self.scrollView.layoutIfNeeded()
        self.moveTextFieldIfNeeded(info: info)
      },
      completion: nil
    )
  }
    
  func moveTextFieldIfNeeded(info: Info) {
    let textFields = stackView.arrangedSubviews.compactMap { $0 as? UITextField }
    guard let input = textFields.first(where: { $0.isFirstResponder }) else { return }
    let inputFrame = input.convert(input.bounds, to: nil)
     
    if inputFrame.intersects(info.frame) {
      scrollView.setContentOffset(CGPoint(x: 0, y: inputFrame.height), animated: true)
    } else {
      scrollView.setContentOffset(.zero, animated: true)
    }
  }
      
  func convert(notification: Notification) -> Info? {
    guard let frameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return nil }
    guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return nil }
    guard let raw = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return nil }

    return Info(
      frame: frameValue.cgRectValue,
      duration: duration.doubleValue,
      animationOptions: UIView.AnimationOptions(rawValue: raw.uintValue)
    )
  }
}
