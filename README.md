# InstagramAuthViewController
> A ViewController for Instagram authentication.

A `UIViewController` subclass that handles showing the Instagram login page, the authentication dance and finally returning the access token that can be used to communicate with the Instagram API afterwards.

Inspired by [Instagram-Auth-iOS](https://github.com/Buza/Instagram-Auth-iOS). Used [PhotoBrowser](https://github.com/MoZhouqi/PhotoBrowser) as a stepping stone. I rewrote the login part in Swift, replced third-party library code with built-in Cocoa Touch frameworks and made it reusable.

![](http://i.imgur.com/d69wCaE.jpg)


## Requirements

- iOS 8.0+
- Xcode 7.3

## Installation

#### Manually
1. Download or clone the repo.
2. Open the _source_ folder.
3. Add ```InstagramAuthViewController.swift``` to your project.  
4. Profit(?)!

## Usage example

* Go to Instagram's [developer portal](https://www.instagram.com/developer/) and register your application.
* Take note of the **client ID**, **client secret** and **redirect URI** values.

```swift
let clientId = "<YOUR CLIENT ID>"
let clientSecret = "<YOUR CLIENT SECRET>"
let redirectUri = "<YOUR REDIRECT URI>"
```

#### Storyboards
* Simply add the ```InstagramAuthViewController``` as the ```UIViewController```'s class in the Identity inspector.

![](http://i.imgur.com/7GbxV0j.png)

```swift
let instagramAuthViewController = segue.destinationViewController as! InstagramAuthViewController
instagramAuthViewController.delegate = self
instagramAuthViewController.clientId = clientId
instagramAuthViewController.clientSecret = clientSecret
instagramAuthViewController.redirectUri = redirectUri
```

#### Programmatically

* Initialize an instance of `InstagramAuthViewController` and present it like a normal ViewController.

```swift
let instagramAuthViewController = InstagramAuthViewController(clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri)
instagramAuthViewController.delegate = self
presentViewController(instagramAuthViewController, animated: true, completion: nil)
```

* Either way, don't forget to implement the ```InstagramAuthDelegate```.

```swift
func instagramAuthControllerDidFinish(accessToken: String?, error: NSError?) {
    if let error = error {
        print("Error logging in to Instagram: \(error.localizedDescription)")
    } else {
        print("Access token: \(accessToken!)")
    }
}
```


## Contribute & Bug Fixes

We would love for you to contribute to **InstagramAuthViewController**, check the ``LICENSE`` file for more info. Pull requests, bug fixes, improvements welcome.

## Meta

Isuru Nanayakkara – [@IJNanayakkara](https://twitter.com/IJNanayakkara) – isuru.nan@gmail.com

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/Isuru-Nanayakkara](https://github.com/Isuru-Nanayakkara)