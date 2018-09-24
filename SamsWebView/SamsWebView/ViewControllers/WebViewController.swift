//
//  WebViewController.swift
//  SamsWebView
//
//  Created by Samman Thapa on 9/24/18.
//  Copyright © 2018 Samman Thapa. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    var link: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print ("loaded with link: ", link?.absoluteString)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
