//
//  ViewController.swift
//  InstagramAuthViewController
//
//  Created by Isuru Nanayakkara on 5/19/16.
//  Copyright © 2016 BitInvent. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // Register your application here - https://www.instagram.com/developer/
    
    let clientId = "<YOUR CLIENT ID>"
    let clientSecret = "<YOUR CLIENT SECRET>"
    let redirectUri = "<YOUR REDIRECT URI>"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didTapLoginButton(sender: UIButton) {
        let instagramAuthViewController = InstagramAuthViewController(clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri)
        instagramAuthViewController.delegate = self
        let navController = UINavigationController(rootViewController: instagramAuthViewController)
        presentViewController(navController, animated: true, completion: nil)
    }
    
}

extension ViewController: InstagramAuthDelegate {
    func instagramAuthControllerDidFinish(accessToken: String?, error: NSError?) {
        if let error = error {
            print("Error logging in to Instagram: \(error.localizedDescription)")
        } else {
            print("Access token: \(accessToken!)")
        }
    }
}