//
//  InstagramAuthViewController.swift
//  InstagramAuth
//
//  Created by Isuru Nanayakkara on 5/17/16.
//  Copyright © 2016 BitInvent. All rights reserved.
//

import UIKit

protocol InstagramAuthDelegate {
    func instagramAuthControllerDidFinish(accessToken: String?, error: Error?)
}

class InstagramAuthViewController: UIViewController {

    private let baseURL = "https://api.instagram.com"
    
    var clientId: String!
    var clientSecret: String!
    var redirectUri: String!
    
    private enum InstagramEndpoints: String {
        case Authorize = "/oauth/authorize/"
        case AccessToken = "/oauth/access_token/"
    }
    
    private var webView: UIWebView!
    private var activityIndicatorView: UIActivityIndicatorView!
    
    var delegate: InstagramAuthDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(clientId: String, clientSecret: String, redirectUri: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUri = redirectUri
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        URLCache.shared.removeAllCachedResponses()
        HTTPCookieStorage.shared.deleteAllCookies()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = UIWebView(frame: view.frame)
        webView.delegate = self
        view.addSubview(webView)
        
        activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.center = webView.center
        activityIndicatorView.isHidden = true
        activityIndicatorView.hidesWhenStopped = true
        webView.addSubview(activityIndicatorView)
        
        getLoginPage()
    }
    
    private func getLoginPage() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        let authUrl = baseURL + InstagramEndpoints.Authorize.rawValue
        var components = URLComponents(string: authUrl)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "response_type", value: "code")
        ]
        let request = URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        webView.loadRequest(request)
    }
    
    private func requestAccessToken(code: String) {
        let tokenUrl = baseURL + InstagramEndpoints.AccessToken.rawValue
        var components = URLComponents(string: tokenUrl)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "code", value: code)
        ]
        
        var request = URLRequest(url: URL(string: tokenUrl)!)
        request.httpMethod = "POST"
        request.httpBody = components.percentEncodedQuery!.data(using: String.Encoding.utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                guard let delegate = self.delegate else {
                    fatalError("InstagramAuthDelegate method needs to be implemented")
                }
                delegate.instagramAuthControllerDidFinish(accessToken: nil, error: error)
            } else {
                self.getAccessToken(data: data!)
            }
        }.resume()
    }
    
    private func getAccessToken(data: Data) {
        do {
            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
            let accessToken = result["access_token"] as! String
            guard let delegate = self.delegate else {
                fatalError("InstagramAuthDelegate method needs to be implemented")
            }
            delegate.instagramAuthControllerDidFinish(accessToken: accessToken, error: nil)
            dismiss()
        } catch let error {
            print("Error parsing for access token: \(error.localizedDescription)")
            guard let delegate = self.delegate else {
                fatalError("InstagramAuthDelegate method needs to be implemented")
            }
            delegate.instagramAuthControllerDidFinish(accessToken: nil, error: error)
        }
    }
    
    private func dismiss() {
        OperationQueue.main.addOperation {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension InstagramAuthViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        let urlString = request.url!.absoluteString
        if let range = urlString.range(of: "\(redirectUri)?code=") {
            let location = range.lowerBound
            let code = urlString.substring(from: location)
            requestAccessToken(code: code)
            return false
        }
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicatorView.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        guard let delegate = self.delegate else {
            fatalError("InstagramAuthDelegate method needs to be implemented")
        }
        delegate.instagramAuthControllerDidFinish(accessToken: nil, error: error)
    }
}

extension HTTPCookieStorage {
    func deleteAllCookies() {
        if let cookies = self.cookies {
            for cookie in cookies {
                self.deleteCookie(cookie)
            }
        }
    }
}
