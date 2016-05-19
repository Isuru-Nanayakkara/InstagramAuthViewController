//
//  InstagramAuthViewController.swift
//  InstagramAuth
//
//  Created by Isuru Nanayakkara on 5/17/16.
//  Copyright © 2016 BitInvent. All rights reserved.
//

import UIKit

protocol InstagramAuthDelegate {
    func authControllerDidFinish(accessToken: String?, error: NSError?)
}

class InstagramAuthViewController: UIViewController {

    private let baseURL = "https://api.instagram.com"
    
    private(set) var clientId: String!
    private(set) var clientSecret: String!
    private(set) var redirectUri: String!
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteAllCookies()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = UIWebView(frame: view.frame)
        webView.delegate = self
        view.addSubview(webView)
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicatorView.center = webView.center
        activityIndicatorView.hidden = true
        activityIndicatorView.hidesWhenStopped = true
        webView.addSubview(activityIndicatorView)
        
        getLoginPage()
    }
    
    private func getLoginPage() {
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        
        let authUrl = baseURL + InstagramEndpoints.Authorize.rawValue
        let components = NSURLComponents(string: authUrl)!
        components.queryItems = [
            NSURLQueryItem(name: "client_id", value: clientId),
            NSURLQueryItem(name: "redirect_uri", value: redirectUri),
            NSURLQueryItem(name: "response_type", value: "code")
        ]
        let request = NSURLRequest(URL: components.URL!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        webView.loadRequest(request)
    }
    
    private func requestAccessToken(code: String) {
        let tokenUrl = baseURL + InstagramEndpoints.AccessToken.rawValue
        let components = NSURLComponents(string: tokenUrl)!
        components.queryItems = [
            NSURLQueryItem(name: "client_id", value: clientId),
            NSURLQueryItem(name: "client_secret", value: clientSecret),
            NSURLQueryItem(name: "grant_type", value: "authorization_code"),
            NSURLQueryItem(name: "redirect_uri", value: redirectUri),
            NSURLQueryItem(name: "code", value: code)
        ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: tokenUrl)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = components.percentEncodedQuery!.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                guard let delegate = self.delegate else {
                    fatalError("InstagramAuthDelegate method needs to be implemented")
                }
                delegate.authControllerDidFinish(nil, error: error)
            } else {
                self.getAccessToken(data!)
            }
        }.resume()
    }
    
    private func getAccessToken(data: NSData) {
        do {
            let result = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String: AnyObject]
            let accessToken = result["access_token"] as! String
            guard let delegate = self.delegate else {
                fatalError("InstagramAuthDelegate method needs to be implemented")
            }
            delegate.authControllerDidFinish(accessToken, error: nil)
            dismiss()
        } catch let error as NSError {
            print("Error parsing for access token: \(error.localizedDescription)")
            guard let delegate = self.delegate else {
                fatalError("InstagramAuthDelegate method needs to be implemented")
            }
            delegate.authControllerDidFinish(nil, error: error)
        }
    }
    
    private func dismiss() {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

extension InstagramAuthViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = request.URL!.absoluteString
        if let range = urlString.rangeOfString("\(redirectUri)?code=") {
            let location = range.endIndex
            let code = urlString.substringFromIndex(location)
            requestAccessToken(code)
            return false
        }
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicatorView.stopAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print(error?.localizedDescription)
        // TODO: Call the InstagramAuthDelegate method passing teh error,
        // only for specific cases like no network.
    }
}

extension NSHTTPCookieStorage {
    func deleteAllCookies() {
        if let cookies = self.cookies {
            for cookie in cookies {
                self.deleteCookie(cookie)
            }
        }
    }
}