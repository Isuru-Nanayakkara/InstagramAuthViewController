# InstagramAuthViewController
A ViewController for Instagram authentication.

-

A `UIViewController` subclass that handles showing the Instagram login page, the authentication dance and finally returning the access token that can be used to communicate with the Instagram API afterwards.

Inspired by [Instagram-Auth-iOS](https://github.com/Buza/Instagram-Auth-iOS). Used [PhotoBrowser](https://github.com/MoZhouqi/PhotoBrowser) as a stepping stone. I rewrote the login part in Swift, replced third-party library code with built-in Cocoa Touch frameworks and made it reusable.

-

### Usage

1. Go to Instagram's [developer portal](https://www.instagram.com/developer/) and register your application.
2. Take note of the **client ID**, **client secret** and **redirect URI** values.
3. Initialize an instance of `InstagramAuthViewController` and present it like a normal ViewController.

```swift
let clientId = "<Your client ID>"
let clientSecret = "<Your client secret>"
let redirectUri = "http://www.example.com/"

let instagramAuthViewController = InstagramAuthViewController(clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri)
presentViewController(instagramAuthViewController, animated: true, completion: nil)
```