/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

final class MainViewController: UIViewController
{

  // MARK: - IBOutlets
  @IBOutlet weak var yearLabel: UILabel!
  @IBOutlet weak var hostLabel: UILabel!
  @IBOutlet weak var medalCountButton: UIButton!
  @IBOutlet weak var logoImageView: UIImageView!

  // MARK: - Properties
  /**
   The handler for transitioning delegate. We will use this reference when assigning the
   transitioning delegate before presentation.
   
   Because
   1. transitioningDelegate is a weak property, so you must keep a strong reference to the delegate
   somewhere.
   
   2. However, you don’t to keep this reference on the presented controller itself because you might
   want to re-use it on different presentation styles.
   
   3. Adding it to MainViewController keeps the strong reference on the presenting controller.
   
   4. Deciding the type of presentation to use is now the presenting controller’s task.
   */
  lazy var slideInTransitioningDelegate = SlideInPresentationManager()
  
  private let dataStore = GamesDataStore()
  fileprivate var presentedGames: Games? {
    didSet {
      configurePresentedGames()
    }
  }

  // MARK: - View Life Cycle
  override func viewDidLoad()
  {
    super.viewDidLoad()

    presentedGames = nil
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if let controller = segue.destination as? GamesTableViewController
    {
      if segue.identifier == "SummerSegue"
      {
        controller.gamesArray = dataStore.summer
        
        // 1.0
        slideInTransitioningDelegate.direction = .left
      }
      else if segue.identifier == "WinterSegue"
      {
        controller.gamesArray = dataStore.winter
        
        // 1.1
        slideInTransitioningDelegate.direction = .right
      }
      
      controller.delegate = self
      // 2. Set the transitioning delegate of the presented view controller to custom
      controller.transitioningDelegate = slideInTransitioningDelegate
      
      // 3 The modalPresentationStyle is .custom to make the presented controller expect a custom
      // presentation instead of an iOS default presentation
      controller.modalPresentationStyle = .custom
    } else if let controller = segue.destination as? MedalCountViewController
    {
      controller.medalCount = presentedGames?.medalCount
      
      // 4 Same as 1.0 - 3, but for Medal Count View Controller, with different direction
      slideInTransitioningDelegate.direction = .bottom
      controller.transitioningDelegate = slideInTransitioningDelegate
      controller.modalPresentationStyle = .custom
    }
  }
}

// MARK: - Private
private extension MainViewController
{

  func configurePresentedGames()
  {
    guard let presentedGames = presentedGames
      else {
        logoImageView.image = UIImage(named: "medals")
        hostLabel.text = nil
        yearLabel.text = nil
        medalCountButton.isHidden = true
        return
    }

    logoImageView.image = UIImage(named: presentedGames.flagImageName)
    hostLabel.text = presentedGames.host
    yearLabel.text = presentedGames.seasonYear
    medalCountButton.isHidden = false
  }
}

// MARK: - GamesTableViewControllerDelegate
extension MainViewController: GamesTableViewControllerDelegate
{
  func gamesTableViewController(controller: GamesTableViewController, didSelectGames selectedGames: Games)
  {
    presentedGames = selectedGames
    dismiss(animated: true)
  }
}
