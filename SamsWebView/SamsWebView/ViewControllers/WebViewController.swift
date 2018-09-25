//
//  WebViewController.swift
//  SamsWebView
//
//  Created by Samman Thapa on 9/24/18.
//  Copyright © 2018 Samman Thapa. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var link: URL?
    
    var webView: WKWebView!
    
    override func loadView() {
        // TODO: learn what this line is doing
        /*
            A collection of properties used to initialize a web view.
         
         Using the WKWebViewConfiguration class, you can determine how soon a webpage is rendered, how media playback is handled, the granularity of items that the user can select, and many other options.
         
         WKWebViewConfiguration is only used when a web view is first initialized. You cannot use this class to change the web view's configuration after it has been created.
        */
//        let webConfiguration = WKWebViewConfiguration()
        // TODO: learn what options we have for frame
        // this does not even work, probably because we are assigning to controllers view
//        let frameOfWebView = CGRect(x: 90.0, y: 90.0, width: 300, height: 300)
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        webView = WKWebView(frame: frameOfWebView, configuration: webConfiguration)
        self.webView = WKWebView()
        self.webView.navigationDelegate = self
        // TODO: learn about uiDelegate - the WebViews user interface delegate
//        webView.uiDelegate = self
        self.view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print ("loaded with link: \(link?.absoluteString ?? "Oops, did not find the link")")
        
        if let link = link
        {
            print ("Found the link")
            let myRequest = URLRequest(url: link)
            webView.load(myRequest)
            webView.allowsBackForwardNavigationGestures = true
        } else
        {
            print ("No link found")
        }
        
        // Adding toolbar
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        toolbarItems = [spacer, refresh]
        navigationController?.isToolbarHidden = false
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

// TODO: learn about WKUIDelegate
extension WebViewController: WKUIDelegate {
    
}

// TODO: learn about WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    
}
