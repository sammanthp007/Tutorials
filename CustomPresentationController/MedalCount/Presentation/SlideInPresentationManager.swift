//
//  SlideInPresentationManager.swift
//  MedalCount
//
//  Created by Samman Thapa on 4/10/19.
//  Copyright © 2019 Ron Kliffer. All rights reserved.
//

import UIKit

/**
 In MainViewController you have buttons for both seasons: Summer on the left and Winter on the
 right. There’s also a Medal Count button on the bottom.
 
 To make the presentations fit each button’s context, you’ll add a direction property to
 SlideInPresentationManager. Later, you’ll pass this property to the presentation and animation
 controllers.
 */
enum PresentationDirection
{
  case left
  case right
  case bottom
  case top
}

class SlideInPresentationManager: NSObject
{
  var direction = PresentationDirection.left
}

/**
 The presented view controller has a transitioning delegate that’s responsible for loading the
 UIPresentationController and the presentation/dismissal animation controllers
 */
extension SlideInPresentationManager: UIViewControllerTransitioningDelegate
{
  
}
