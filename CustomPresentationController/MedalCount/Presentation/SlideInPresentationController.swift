//
//  SlideInPresentationController.swift
//  MedalCount
//
//  Created by Samman Thapa on 4/10/19.
//  Copyright © 2019 Ron Kliffer. All rights reserved.
//

import UIKit

/**
 Before you can start customizing the transition, you have to override four methods and a property
 from UIPresentationController. The default methods don’t do anything, so there’s no need to call
 super
 
 The four methods are;
 - presentationTransitionWillBegin()
 - dismissalTransitionWillBegin()
 - containerViewWillLayoutSubviews()
 - size(forChildContentContainer:withParentContainerSize:) -> CGSize
 */
class SlideInPresentationController: UIPresentationController
{
  // 4.0: Setting up the dimming view
  fileprivate var dimmingView: UIView!
  
  // 1 Declares a direction property to represent the direction of the presentation.
  private var direction: PresentationDirection
  
  // 5.3.1 In addition to calculating the size of the presented view, you need to return its full
  // frame
  override var frameOfPresentedViewInContainerView: CGRect {
    // 5.3.1.1
    var frame: CGRect = .zero
    frame.size = size(forChildContentContainer: presentedViewController,
                      withParentContainerSize: containerView!.bounds.size)
    
    // 5.3.1.2
    switch direction {
    case .right:
      frame.origin.x = containerView!.frame.width*(1.0/3.0)
    case .bottom:
      frame.origin.y = containerView!.frame.height*(1.0/3.0)
    default:
      frame.origin = .zero
    }
    return frame
  }
  
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

  // 5.0
  // First, for a smooth transition, override presentationTransitionWillBegin() to make the dimming
  // view fade in along with the presentation.
  override func presentationTransitionWillBegin()
  {
    // 5.0.1
    containerView?.insertSubview(dimmingView, at: 0)
    
    // 5.0.2: Check this out to know more about visual format:
    // https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|",
                                     options: [], metrics: nil, views: ["dimmingView": dimmingView]))
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|",
                                     options: [], metrics: nil, views: ["dimmingView": dimmingView]))
    
    // 5.0.3 UIPresentationController‘s transitionCoordinator has a very cool method to animate
    // things during the transition. In this section, you set the dimming view’s alpha property to
    // 1.0 along the presentation transition.
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 1.0
      return
    }
    
    coordinator.animate(alongsideTransition: { _ in
      self.dimmingView.alpha = 1.0
    })
  }
  
  // 5.1 Hide the dimming view when the presented controller is dismissed
  override func dismissalTransitionWillBegin()
  {
    guard let coordinator = presentedViewController.transitionCoordinator else
    {
      dimmingView.alpha = 0.0
      return
    }
    
    coordinator.animate(alongsideTransition: { _ in
      self.dimmingView.alpha = 0.0
    })
  }
  
  // 5.2: When layout is about to begin on views of container view, respond to layout changes in the
  // presentation controller’s containerView
  override func containerViewWillLayoutSubviews()
  {
    // Reset the presented view’s frame to fit any changes to the containerView frame
    presentedView?.frame = frameOfPresentedViewInContainerView
  }
  
  // 5.3.0: Give the size of the presented view controller’s content to the presentation controller
  // This method receives the content container and parent view’s size, and then it calculates the
  // size for the presented content. In this code, you restrict the presented view to 2/3 of the
  // screen by returning 2/3 the width for horizontal and 2/3 the height for vertical presentations
  override func size(forChildContentContainer container: UIContentContainer,
                     withParentContainerSize parentSize: CGSize) -> CGSize
  {
    switch direction
    {
    case .left, .right:
      return CGSize(width: parentSize.width*(2.0/3.0), height: parentSize.height)
    case .bottom, .top:
      return CGSize(width: parentSize.width, height: parentSize.height*(2.0/3.0))
    }
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
