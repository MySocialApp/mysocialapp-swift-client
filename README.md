# mysocialapp-swift-client

[![mysocialapp header](https://msa-resources.s3.amazonaws.com/build%20your%20own%20social%20networking%20app%202.jpg)](https://mysocialapp.io)

Official Swift client to interact with apps made with [MySocialApp](https://mysocialapp.io) (turnkey iOS and Android social network app builder - SaaS).

Note: This lib was made in Swift and can be used inside any XCode iOS app.

# Why using it?

MySocialApp is a very innovative way to have a turnkey native social network app for iOS and Android. Our API are open and ready to use for all your need inside one of our generated app or any thirds app. 

### What can you do?

Add social features to your existing app, automate actions, scrape contents, analyze the users content, add bot to your app, almost anything that a modern social network can bring.. There is no limit! Any suggestion to add here? Do a PR. 

# What features are available?

| Feature | Server side API | Swift client API
| ------- | ----------- | -------------------------- |
| Account management | :heavy_check_mark: | Partially
| Feed | :heavy_check_mark: | Partially
| Comment | :heavy_check_mark: | Partially
| Like | :heavy_check_mark: | Partially
| Notification | :heavy_check_mark: | Soon
| Private messaging | :heavy_check_mark: | Soon
| Photo | :heavy_check_mark: | Soon
| User | :heavy_check_mark: | Partially
| Friend | :heavy_check_mark: | Partially
| URL rewrite | :heavy_check_mark: | :heavy_check_mark:
| URL preview | :heavy_check_mark: | :heavy_check_mark:
| User mention | :heavy_check_mark: | Partially
| Hash tag | :heavy_check_mark: | :heavy_check_mark:
| Search | :heavy_check_mark: | Soon
| Group [optional module] | :heavy_check_mark: | Partially
| Event [optional module] | :heavy_check_mark: | Partially
| Roadbook [optional module] | :heavy_check_mark: | Partially
| Live tracking with `RideShare` ([exemple here](https://www.nousmotards.com/rideshare/follow/f6e0c27e01beb4f4-3856809369215939951-f10c31fd2dcc4576a1b488385aaa61c2)) [optional module] | :heavy_check_mark: | Soon
| Point of interest [optional module] | :heavy_check_mark: | Soon

Looking for official Java/Kotlin/Android client API ? [Take a look right here](https://github.com/MySocialApp/mysocialapp-java-client)

Coming soon:
* Real time downstream handlers with FCM (Android), APNS (iOS) and Web Socket.

# Dependencies

Step 1. Activate CocoaPods for your project
```
pod init
```

Step 2. Add it in your root Podfile at the end of pods:
```
target ... {
	...
  pod 'MySocialApp', :git => 'https://github.com/MySocialApp/mysocialapp-swift-client.git'
}
```

Step 3. Update CocoaPods for your project
```
pod update
```

# Prerequisites

You must have "APP ID" to target the right App. Want to [create your app](https://support.mysocialapp.io/hc/en-us/articles/115003936872-Create-my-first-app)?
##### App owner/administrator:
Sign in to [go.mysocialapp.io](https://go.mysocialapp.io) and go to API section. Your **APP ID** is part of the endpoint URL provided to your app. Which is something like `https://u123456789123a123456-api.mysocialapp.io`. Your **APP ID** is `u123456789123a123456`

##### App user:
Ask for an administrator to give you the **APP ID**.

# Usage

Most of the actions can be synchronous and asynchronous with RxSwift. We are using [RxSwift](https://github.com/ReactiveX/RxSwift) to provide an elegant way to handle asynchronous results.

Create an account
```swift
let appId = "u123456789123a123456"
let msa = MySocialApp.Builder().setAppId(appId).build()

// create an account and return an active session to do fluent operations
let johnSession = msa.createAccount(username: "John", email: "john@myapp.com", password: "myverysecretpassw0rd")
```

Do login with your account
```swift
let johnSession = msa.connect(username: "John", password: "myverysecretpassw0rd")
```

Get your account info
```swift
var account = jognSession.account.blockingGet()
account.firstName
account.dateOfBirth
account.livingLocation?.completeCityAddress
[..]
```

Update your account
```swift
var account = johnSession.account
account.lastName = "James"
account.blockingSave() // or use save() to asynchronously save it with Rx
```

List news feed from specific page and size
```swift
johnSession?.newsFeed?.blockingList(0, 10)
```

Stream all 100 first news feed message
```swift
johnSession?.newsFeed?.blockingStream(100)
```

Post public news with hashtag + url + user mention
```swift
let s = johnSession

let post = TextWallMessage.Builder()
        .setMessage("This is a post with #hashtag url https://mysocialapp.io and someone mentioned [[user:3856809369215939951]]")
        .setVisibility(AccessControl.PUBLIC)
        .build()

s?.newsFeed?.blockingSendWallPost(post)
``` 

Post public photo with a hashtag
```swift
let s = johnSession

let post = Photo.Builder()
        .setMessage("This is a post with an image and a #hashtag :)")
        .setImage(File("/tmp/myimage.jpg"))
        .setVisibility(AccessControl.PUBLIC)
        .build()

s?.newsFeed?.blockingSendWallPost(post)
```

Post on a friend wall and mention him
````swift
let s = johnSession

// take my first friend
guard let friend = s?.account?.blockingGet()?.blockingListFriends()?.firstOrNull() else {
	return
}

let post = TextWallMessage.Builder()
        .setMessage("Hey [[user:${friend.id}]] what's up?")
        .setVisibility(AccessControl.FRIEND)
        .build()

friend.blockingSendWallPost(post)
````

# Credits

* [Swift](https://www.apple.com/fr/swift/)
* [RxSwift](https://github.com/ReactiveX/RxSwift)
* [Alamofire](https://github.com/Alamofire/Alamofire)

# Contributions

All contributions are welcomed. Thank you
