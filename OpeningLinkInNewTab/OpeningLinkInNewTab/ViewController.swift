//
//  ViewController.swift
//  OpeningLinkInNewTab
//
//  Created by Samman Thapa on 11/29/18.
//  Copyright © 2018 Samman Thapa. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var urlString = "http://google.com"
    
    @IBAction func onTapButton(_ sender: Any)
    {
//        self.webView.loadUrl(string: urlString)
        self.webView.load(URLRequest(url: URL(string: urlString)!))
    }
    @IBOutlet weak var webView: WKWebView!
    
    fileprivate var webViewIsInited = false
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }
}

extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let host = webView.url?.host {
            self.navigationItem.title = host
        }
    }
}

extension ViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            let vc = ViewController()
            vc.urlString = navigationAction.request.url?.absoluteString ?? "http://google.com"
            vc.view.frame = UIScreen.main.bounds
            vc.webView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
            navigationController?.pushViewController(vc, animated: false)
            return vc.webView
        }
        return nil
    }
}

//extension WKWebView {
//
//    func loadUrl(string: String) {
//        if let url = URL(string: string) {
//            if self.url?.host == url.host {
//                self.reload()
//            } else {
//                load(URLRequest(url: url))
//            }
//        }
//    }
//}
