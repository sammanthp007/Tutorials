/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var basketTop: UIImageView!
  @IBOutlet weak var basketBottom: UIImageView!
  
  @IBOutlet weak var fabricTop: UIImageView!
  @IBOutlet weak var fabricBottom: UIImageView!
  
  @IBOutlet weak var basketTopConstraint : NSLayoutConstraint!
  @IBOutlet weak var basketBottomConstraint : NSLayoutConstraint!
  
  @IBOutlet weak var bug: UIImageView!
  var isBugDead = false
  var tap: UITapGestureRecognizer!
  
  required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(_:)))
  }
  
  override func viewDidAppear(_ animated: Bool)
  {
    openBasket()
    openNapkins()
    moveBugLeft()
    
    view.addGestureRecognizer(tap)
  }
  
  func openBasket()
  {
    basketTopConstraint.constant -= basketTop.frame.size.height
    basketBottomConstraint.constant -= basketBottom.frame.size.height
    
    UIView.animate(withDuration: 0.7, delay: 1.0, options: .curveEaseOut, animations:
      {
        self.view.layoutIfNeeded()
    }, completion: { finished in
      print("Basket doors opened!")
    })
  }
  
  func openNapkins()
  {
    UIView.animate(withDuration: 1.0, delay: 1.2, options: .curveEaseOut, animations:
      {
        var fabricTopFrame = self.fabricTop.frame
        fabricTopFrame.origin.y -= fabricTopFrame.size.height
        
        var fabricBottomFrame = self.fabricBottom.frame
        fabricBottomFrame.origin.y += fabricBottomFrame.size.height
        
        self.fabricTop.frame = fabricTopFrame
        self.fabricBottom.frame = fabricBottomFrame
    }, completion: { finished in
      print("Napkins opened!")
    })
  }
  
  @objc func handleTap(_ gesture: UITapGestureRecognizer)
  {
    let tapLocation = gesture.location(in: bug.superview)
    // As your bug scoots back and forth, its underlying frame has already moved to its final position for that animation.
    // All the in-between animation orientation and positioning details are handled in the presentation layer.
    if (bug.layer.presentation()?.frame.contains(tapLocation))!
    {
      print("Bug tapped!")
      if isBugDead { return }
      
      view.removeGestureRecognizer(tap)
      isBugDead = true
      
      UIView.animate(withDuration: 0.7, delay: 0.0,
                     options: [.curveEaseOut , .beginFromCurrentState], animations: {
                      // flattened by applying a scale transform
                      self.bug.transform = CGAffineTransform(scaleX: 1.25, y: 0.75)
      }, completion: { finished in
        UIView.animate(withDuration: 2.0, delay: 2.0, options: [], animations: {
          // fades to nothingness by setting its alpha to 0 after a delay
          self.bug.alpha = 0.0
        }, completion: { finished in
          // remove the bug from the superview
          self.bug.removeFromSuperview()
        })
      })
    }
    else
    {
      print("Bug not tapped!")
    }
  }
}

extension ViewController
{
  func moveBugLeft()
  {
    if isBugDead { return }
    UIView.animate(withDuration: 1.0,
                   delay: 2.0,
                   options: [.curveEaseInOut , .allowUserInteraction],
                   animations: {
                    self.bug.center = CGPoint(x: 75, y: 200)
    },
                   completion: { finished in
                    print("Bug moved left!")
                    self.faceBugRight()
    })
  }
  
  func faceBugRight()
  {
    if isBugDead { return }
    UIView.animate(withDuration: 1.0,
                   delay: 0.0,
                   options: [.curveEaseInOut , .allowUserInteraction],
                   animations: {
                    self.bug.transform = CGAffineTransform(rotationAngle: .pi)
    },
                   completion: { finished in
                    print("Bug faced right!")
                    self.moveBugRight()
    })
  }
  
  func moveBugRight()
  {
    if isBugDead { return }
    UIView.animate(withDuration: 1.0,
                   delay: 2.0,
                   options: [.curveEaseInOut , .allowUserInteraction],
                   animations: {
                    self.bug.center = CGPoint(x: self.view.frame.width - 75, y: 250)
    },
                   completion: { finished in
                    print("Bug moved right!")
                    self.faceBugLeft()
    })
  }
  
  func faceBugLeft()
  {
    if isBugDead { return }
    UIView.animate(withDuration: 1.0,
                   delay: 0.0,
                   options: [.curveEaseInOut , .allowUserInteraction],
                   animations:
      {
                    self.bug.transform = CGAffineTransform(rotationAngle: 0.0)
    },
                   completion: { finished in
                    print("Bug faced left!")
                    self.moveBugLeft()
    })
  }
}
