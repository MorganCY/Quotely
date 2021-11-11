//
//  PrivacyPolicyViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/10.
//

import Foundation
import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController, WKNavigationDelegate {

    var webView = WKWebView()
    let privacyPolicyUrl = URL(string: "https://www.privacypolicies.com/live/355394c1-aafe-4d6b-8bc8-07bca81cf42f")!

    override func loadView() {
        super.loadView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.load(URLRequest(url: privacyPolicyUrl))
        webView.allowsBackForwardNavigationGestures = true
    }
}
