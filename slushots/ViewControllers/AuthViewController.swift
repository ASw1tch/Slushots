//
//  AuthViewController.swift
//  slushots
//
//  Created by Anatoliy Switch on 02.09.2022.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate {
    
    private let webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero,
                                configuration: config)
        return webView
    }()
    
    public var completionHandler: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Loading..."
        webView.navigationDelegate = self
        view.addSubview(webView)
        guard let url = SPTFAuthManager.shared.signInURL else {
            print("There is no Sign in URL")
            return 
        }
        webView.load(URLRequest(url: url))
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {
            print("There is no WebView URL")
            return 
        }
        //Exchange the code for access token
        guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value
        else {
            
            return
        }
        
        webView.isHidden = true
        
        SPTFAuthManager.shared.exchangeCodeForToken(code: code) { [weak self] success in
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let _ = storyboard.instantiateInitialViewController() as? UINavigationController else {
                    print("False to setting UINavigationController")
                    return
                    
                }
                let navVC = storyboard.instantiateViewController(withIdentifier: "MediaListViewController") as UIViewController
                self?.navigationItem.hidesBackButton = true
                self?.navigationController?.pushViewController(navVC, animated: true)
                self?.completionHandler?(success)
            }
        }
    }
}

