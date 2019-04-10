//
//  SlideInPresentationController.swift
//  MedalCount
//
//  Created by Samman Thapa on 4/10/19.
//  Copyright © 2019 Ron Kliffer. All rights reserved.
//

import UIKit

class SlideInPresentationController: UIPresentationController
{
  // 4.0: Setting up the dimming view
  fileprivate var dimmingView: UIView!
  
  // 1 Declares a direction property to represent the direction of the presentation.
  private var direction: PresentationDirection
  
  // 2 Declares an initializer that accepts the presented and presenting view controllers, as well
  // as the presentation direction.
  init(presentedViewController: UIViewController,
       presenting presentingViewController: UIViewController?,
       direction: PresentationDirection)
  {
    self.direction = direction
    
    super.init(presentedViewController: presentedViewController,
               presenting: presentingViewController)
    
    // 4.4
    setupDimmingView()
  }

}

// MARK: - Private
private extension SlideInPresentationController
{
  // 4.1: Notice you don’t add it to a superview yet. You’ll do that when the presentation
  // transition starts
  func setupDimmingView()
  {
    dimmingView = UIView()
    dimmingView.translatesAutoresizingMaskIntoConstraints = false
    dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
    dimmingView.alpha = 0.0
    
    // 4.3 Add tap gesture reconizer to introduce tap to dismiss
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
    dimmingView.addGestureRecognizer(recognizer)
  }
  
  // 4.2: A UITapGestureRecognizer handler that dismisses the controller, for when tapping the
  // dimmed view
  dynamic func handleTap(recognizer: UITapGestureRecognizer)
  {
    presentingViewController.dismiss(animated: true)
  }
}
