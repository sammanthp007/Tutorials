//
//  MainViewController.swift
//  SamsWebView
//
//  Created by Samman Thapa on 9/24/18.
//  Copyright © 2018 Samman Thapa. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTappingOpenLink(_ sender: Any) {
        print ("Will open link")
        
        let link: URL? = URL(string: "www.apple.com")
        let webViewController = WebViewController()
        webViewController.link = link
        self.navigationController?.pushViewController(webViewController, animated: true)
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
