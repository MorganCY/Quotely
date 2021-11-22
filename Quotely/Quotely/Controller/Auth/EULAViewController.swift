//
//  EULAViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/17.
//

import Foundation
import UIKit
import WebKit

class EULAViewController: UIViewController, WKNavigationDelegate {

    var webView = WKWebView()
    let eulaUrl = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    override func loadView() {
        super.loadView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.load(URLRequest(url: eulaUrl))
        webView.allowsBackForwardNavigationGestures = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissSelf(_:))
        )
    }

    @objc func dismissSelf(_ sender: UIBarButtonItem) {

        dismiss(animated: true, completion: nil)
    }
}
