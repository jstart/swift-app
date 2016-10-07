//
//  LIALinkedInAuthorizationViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 9/26/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import WebKit

class LIALinkedInAuthorizationViewController : UIViewController, WKNavigationDelegate {
    let kLinkedInErrorDomain = "LIALinkedInERROR", kLinkedInDeniedByUser = "the+user+denied+your+request"
    
    let webView = WKWebView(translates: false)
    let application : LIALinkedInApplication = .shared
    var failure : ((Error) -> Void) = { _ in }
    var success : ((String) -> Void) = { _ in }
    var cancel = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Connect LinkedIn"
        
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tappedCancel(sender:)))
        navigationItem.leftBarButtonItem = cancel;
    
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.constrain(.leading, .trailing, .width, .height, toItem: view)
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: navigationController, action: #selector(dismiss))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let linkedIn = "https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=\(application.clientId)&scope=\(application.grantedAccessString)&state=\(application.state)&redirect_uri=\(application.redirectURL.URLEncoded)"
        webView.load(URLRequest(url: URL(string: linkedIn)!))
    }
    
    func tappedCancel(sender: UIButton) { cancel() }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
        let urlString = navigationResponse.response.url!.absoluteString
        if urlString.hasPrefix(application.redirectURL) {
            decisionHandler(.cancel)
            presentingViewController?.dismiss()
            
            if urlString.contains("error") {
                let accessDenied = urlString.contains(kLinkedInDeniedByUser)
                if accessDenied { cancel() }
                else {
                    let errorDescription = extract(getParameter:"error_description", fromURL:navigationResponse.response.url!)
                    let error = NSError.init(domain: kLinkedInErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: errorDescription])
                    failure(error)
                }
            } else {
                let state = extract(getParameter: "state", fromURL: navigationResponse.response.url!)
                if state.contains(application.state) {
                    let code = extract(getParameter: "code", fromURL: navigationResponse.response.url!)
                    success(code)
                } else {
                    let error = NSError.init(domain: kLinkedInErrorDomain, code: 2, userInfo: nil)
                    failure(error)
                }
            }
        } else { decisionHandler(.allow) }
    }
    
    func extract(getParameter: String, fromURL: URL) -> String {
        let url = NSURLComponents(url: fromURL, resolvingAgainstBaseURL: false)
        return url!.queryItems!.filter({ $0.name == getParameter }).first!.value!
    }

}
