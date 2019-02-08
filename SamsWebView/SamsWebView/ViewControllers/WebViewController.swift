//
//  WebViewController.swift
//  SamsWebView
//
//  Created by Samman Thapa on 9/24/18.
//  Copyright © 2018 Samman Thapa. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController
{
    
    var link: URL?
    
    var progressView: UIProgressView?
    var backForwardButtonHolderView: UIView?
    var backButton: UIButton?
    var forwardButton: UIButton?
    
    let stackView = UIStackView()
    
    var webView: WKWebView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.webView = WKWebView()
        self.webView.navigationDelegate = self

        self.view.backgroundColor = UIColor.white
        view.addSubview(stackView)
        setupMainStackViewAndAddConstraints(stackView: stackView)
        stackView.addArrangedSubview(webView)
        
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
        // Set to false to show tool bar too
        navigationController?.isToolbarHidden = true
    }
    
    private func setupMainStackViewAndAddConstraints(stackView: UIStackView)
    {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
}

// TODO: learn about WKNavigationDelegate
extension WebViewController: WKNavigationDelegate
{
    
}
