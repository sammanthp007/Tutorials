//
//  ViewController.swift
//  MLWhatObjectIsIt
//
//  Created by Samman Thapa on 12/12/18.
//  Copyright © 2018 Samman Thapa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classifier: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}

extension ViewController: UINavigationControllerDelegate
{
    // using https://www.appcoda.com/coreml-introduction/
}
