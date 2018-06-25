# mysocialapp-swift-client

[![mysocialapp header](https://msa-resources.s3.amazonaws.com/the%20most%20complete%20community%20messaging%20solution_1280x720.jpg)](https://mysocialapp.io)

Official Swift client to interact with apps made with [MySocialApp](https://mysocialapp.io) (turnkey iOS and Android social network app builder - SaaS).

Note: This lib was made in Swift and can be used inside any Swift 3 and above apps.

# Why using it?

MySocialApp is a very innovative way to have a turnkey native social network app for iOS and Android. Our API are open and ready to use for all your need inside one of our generated app or any thirds app. 

### What can you do?

Add social features to your existing app, automate actions, scrape contents, analyze the users content, add bot to your app, almost anything that a modern social network can bring.. There is no limit! Any suggestion to add here? Do a PR. 

# What features are available?

| Feature | Server side API | Swift client API
| ------- | ----------- | -------------------------- |
| Profile management | :heavy_check_mark: | :heavy_check_mark:
| Feed | :heavy_check_mark: | :heavy_check_mark:
| Comment | :heavy_check_mark: | :heavy_check_mark:
| Like | :heavy_check_mark: | :heavy_check_mark:
| Notification | :heavy_check_mark: | Partially
| Private messaging | :heavy_check_mark: | :heavy_check_mark:
| Photo | :heavy_check_mark: | :heavy_check_mark:
| User | :heavy_check_mark: | :heavy_check_mark:
| Friend | :heavy_check_mark: | :heavy_check_mark:
| URL rewrite | :heavy_check_mark: | :heavy_check_mark:
| URL preview | :heavy_check_mark: | :heavy_check_mark:
| User mention | :heavy_check_mark: | :heavy_check_mark:
| Hash tag| :heavy_check_mark: | :heavy_check_mark:
| Search users | :heavy_check_mark: | :heavy_check_mark:
| Search news feed | :heavy_check_mark: | :heavy_check_mark:
| Search groups | :heavy_check_mark: | :heavy_check_mark:
| Search events | :heavy_check_mark: | :heavy_check_mark:
| Group [optional module] | :heavy_check_mark: | :heavy_check_mark:
| Event [optional module] | :heavy_check_mark: | :heavy_check_mark:
| Roadbook [optional module] | :heavy_check_mark: | Partially
| Live tracking with `RideShare` ([exemple here](https://www.nousmotards.com/rideshare/follow/f6e0c27e01beb4f4-3856809369215939951-f10c31fd2dcc4576a1b488385aaa61c2)) [optional module] | :heavy_check_mark: | Soon
| Point of interest [optional module] | :heavy_check_mark: | Soon
| Admin operations | :heavy_check_mark: | Soon

Looking for official Java/Kotlin client API ? [Click here](https://github.com/MySocialApp/mysocialapp-java-client)

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
  pod 'MySocialApp', '~> 1.0.15'

  post_install do |installer|
    myTargets = ['RxSwift', 'RxCocoa', 'RxBlocking', 'Alamofire', 'MySocialApp']	
    installer.pods_project.targets.each do |target|
      if myTargets.include? target.name
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '3.2'
        end
      end
    end
  end
}
```

Step 3. Update CocoaPods for your project
```
pod update
```

# Prerequisites

You must have "APP ID" to target the right App. Want to [create your app](https://support.mysocialapp.io/hc/en-us/articles/115003936872-Create-my-first-app)?
#### App owner/administrator:
Sign in to [go.mysocialapp.io](https://go.mysocialapp.io) and go to API section. Your **APP ID** is part of the endpoint URL provided to your app. Which is something like `https://u123456789123a123456-api.mysocialapp.io`. Your **APP ID** is `u123456789123a123456`

#### App user:
Ask for an administrator to give you the **APP ID**.

# Usage

Most of the actions can be synchronous and asynchronous with RxSwift. We are using [RxSwift](https://github.com/ReactiveX/RxSwift) to provide an elegant way to handle asynchronous results.

### Profile
#### Create an account
```swift
let appId = "u123456789123a123456"
let msa = MySocialApp.Builder().setAppId(appId).build()

// or
let endpointURL = "https://u123456789123a123456-api.mysocialapp.io";
let msa = MySocialApp.Builder().setAPIEndpointURL(endpointURL).build()

// create an account and return an active session to do fluent operations
let johnSession = msa.blockingCreateAccount(username: "John", email: "john@myapp.com", password: "myverysecretpassw0rd")
```

#### Do login with an access token and get session
```swift
let johnSession = msa.blockingConnect(accessToken: "my access token")
```

#### Do login with your account and get session
```swift
let johnSession = msa.blockingConnect(username: "John", password: "myverysecretpassw0rd")
```

#### Get your account info
```swift
let account = johnSession.account.blockingGet()
account.firstName
account.dateOfBirth
account.livingLocation?.completeCityAddress
[..]
```

#### Update your account
```swift
let account = johnSession.account
account.lastName = "James"
account.blockingSave() // or use save() to asynchronously save it with Rx
```

#### How to integrate a MySocialApp user with an existing user in my application? 
MySocialApp allows you to use your own user IDs to find a user using the "external_id" property. 

```swift
let yourAppUserId = "12348-abcdy-82739-qzdqdq"

let s = johnSession

// set app external user id
let account = s?.account?.blockingGet()
account?.externalId = yourAppUserId
account?.blockingSave()

// find user by external id
let user = s?.user?.blockingGetByExternalId(yourAppUserId)
```

#### Delete your account (not recoverable)
⚠ Caution: this operation is not recoverable
```swift
let s = johnSession
let password = "your account password to confirm the ownership"

s?.account?.blockingRequestForDeleteAccount(password: password)
// Your account has been deleted..
// You are no more able to perform operations
```

### News feed
#### List news feed from specific page and size
```swift
johnSession?.newsFeed?.blockingList(page: 0, size: 10)
```

#### Stream all 100 first news feed message
```swift
johnSession?.newsFeed?.blockingStream(limit: 100)
```

#### Post public news with hashtag + url + user mention
```swift
let s = johnSession

let post = FeedPost.Builder()
        .setMessage("This is a post with #hashtag url https://mysocialapp.io and someone mentioned [[user:3856809369215939951]]")
        .setVisibility(.Public)
        .build()

s?.newsFeed?.blockingSendWallPost(post)
``` 

#### Post public photo with a hashtag
```swift
let s = johnSession
let i = someUIImage

let post = FeedPost.Builder()
        .setMessage("This is a post with an image and a #hashtag :)")
        .setImage(i)
        .setVisibility(.Public)
        .build()

s?.newsFeed?.blockingSendWallPost(post)
```

#### Post on a friend wall and mention him
```swift
let s = johnSession

// take my first friend
if let friend = s?.account?.blockingGet()?.blockingListFriends()?.first {

    val post = FeedPost.Builder()
        .setMessage("Hey [[user:\(friend.id)]] what's up?")
        .setVisibility(.Friend)
        .build()

    friend.blockingSendWallPost(post)
}
```

#### Ignore a news feed post
```swift
let s = getSession()
if let newsFeed = s?.newsFeed?.blockingStream(limit: 1)?.first {
    newsFeed.blockingIgnore()
}
```

#### Report a news feed post
```swift
let s = getSession()
if let newsFeed = s?.newsFeed?.blockingStream(limit: 1)?.first {
    newsFeed.blockingReport()
}
```

#### Delete a news feed post
```swift
let s = getSession()
if let newsFeed = s?.newsFeed?.blockingStream(limit: 1)?.first {
    newsFeed.blockingDelete()
}
```

### Search
#### Search for users by first name and gender
```swift
let s = johnSession

let searchQuery = FluentUser.Search.Builder()
        .setFirstName("alice")
        .setGender(.Female)
        .build()

let users = s?.user?.blockingSearch(searchQuery)?.data
// return the 10 first results
```

#### Search for users by their living location
```swift
let s = johnSession

let parisLocation = SimpleLocation(latitude: 48.85661400000001, longitude: 2.3522219000000177)

let searchQuery = FluentUser.Search.Builder()
        .setLivingLocation(parisLocation)
        .build()

let users = s?.user?.blockingSearch(searchQuery)?.data
// return the 10 first results
```

#### Search for news feeds that contains "hello world"
```swift
let s = johnSession

let searchQuery = FluentFeed.Search.Builder()
        .setTextToSearch("hello world")
        .build()

let feeds = s?.newsFeed?.blockingSearch(searchQuery)?.data
// return the 10 first results
```

### Private conversation
#### List private conversations
```swift
let s = johnSession
let conversations = s?.conversation?.blockingList()
```

#### Create conversation
```swift
let s = johnSession

// take 3 first users
if let people = s?.user?.blockingStream(limit: 3) {

    let conversation = Conversation.Builder()
        .setName("let's talk about the next event in private")
        .addMembers(people)
        .build()

    let createdConversation = s?.conversation?.blockingCreate(conversation)
}
```

#### Post new message into conversation
```swift
let s = johnSession
let i = someUIImage
if let lastConversation = s?.conversation?.blockingList()?.first {

    val message = ConversationMessagePost.Builder()
        .setMessage("Hello, this is a message from our SDK #MySocialApp with an amazing picture. Enjoy")
        .setImage(i)
        .build()

    val messageSent = lastConversation?.blockingSendMessage(message)
}
```

#### Get messages from conversation
```swift
let s = johnSession
let conversation = s?.conversation?.blockingList()?.first

// get 35 last messages without consuming them
let conversationMessages = conversation?.messages?.blockingStream(limit: 35)

// get 35 last messages and consume them
let conversationMessages = conversation?.messages?.blockingStreamAndConsume(limit: 35)
```

#### Change conversation name
```swift
let s = johnSession
let conversion = s?.conversation?.blockingList()?.first

conversion?.name = "new conversation title :)"
conversion?.blockingSave()
```

#### Kick/invite member from conversation
```swift
let s = johnSession
let conversation = s?.conversation?.blockingList()?.first

// kick member
conversation?.blockingKickMember(user)

// invite user
conversation?.blockingAddMember(user)
```

#### Send quick private message to someone
```swift
let s = johnSession
let i = someUIImage
if let user = try? s?.user?.blockingList()?.first?.users?.first {

    let message = ConversationMessagePost.Builder()
        .setMessage("Hey [[user:\(user.id)]] ! This is a quick message from our SDK #MySocialApp with an amazing picture. Enjoy")
        .setImage(i)
        .build()

    user.blockingSendPrivateMessage(message)
}
```

#### Quit conversation
```swift
let s = johnSession
if let conversation = try? s?.conversation?.blockingList()?.first {
    conversation.blockingQuit()
}
```

### Event
This module is optional. Please contact [us](mailto:support@mysocialapp.io) to request it

#### List 50 next events
```swift
let s = johnSession
s?.event?.blockingStream(limit: 50)
```

#### Create an event
```swift
let s = johnSession
let i = someUIImage

let newarkLocation = Location(longitude: 40.736504474883915, latitude: -74.18175405)
 
let tomorrow = Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: Date())

let afterTomorrow = Calendar.current.date(byAdding: Calendar.Component.day, value: 2, to: Date())
 
let event = Event.Builder()
        .setName("New test event")
        .setDescription("This is a new event create with our SDK")
        .setStartDate(tomorrow)
        .setEndDate(afterTomorrow)
        .setLocation(newarkLocation)
        .setMaxSeats(100)
        .setMemberAccessControl(.Public)
        .setCoverImage(i)
        .build()

s?.event?.blockingCreate(event)
```

#### Update an event
```swift
event.name = "New event name"
event.save()
```

#### Join / participate to an event
```swift
event.blockingParticipate()
```

#### List my 10 next events
```swift
let s = johnSession
s?.account?.blockingGet()?.blockingStreamEvent(limit: 10)
```

#### List events between two dates
```swift
let s = johnSession

let tomorrow = Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: Date())

let afterTomorrow = Calendar.current.date(byAdding: Calendar.Component.day, value: 2, to: Date())

let query = FluentEvent.Search.Builder()
        .setLocationMaximumDistanceInKilometers(100.0)
        .setFromDate(tomorrow)
        .setToDate(afterTomorrow)
        .build()

s?.event?.blockingSearch(query)
```

#### Search for events by name or description
```swift
let s = johnSession

let query = FluentEvent.Search.Builder()
        .setName("my event name")
        .setDescription("my event description")
        .build()

s?.event?.blockingSearch(query)
```

#### Search for events by owner
```swift
[..]
user.blockingStreamEvent(limit: 10)
```

#### Create post on event
```swift
[..]
val post = FeedPost.Builder()
        .setMessage("This is a post with #hashtag url https://mysocialapp.io and someone mentioned [[user:3856809369215939951]]")
        .setVisibility(.Public)
        .build()

event.blockingSendWallPost(post)
```

### Group
This module is optional. Please contact [us](mailto:support@mysocialapp.io) to request it 

#### List groups
```swift
let s = johnSession
s?.group?.blockingStream(limit: 100)
```

#### Create a group
```swift
let s = johnSession
let i = someUIImage

let newarkLocation = Location(latitude: 40.736504474883915, longitude: -74.18175405)

let group = Group.Builder()
        .setName("New group")
        .setDescription("This is a new group create with our SDK")
        .setLocation(newarkLocation)
        .setMemberAccessControl(.Public)
        .setImage(i)
        .build()

s?.group?.blockingCreate(group)
```

#### Update a group
```swift
group.name = "New group name"
group.save()
```

#### Join a group
```swift
group.blockingJoin()
```

#### List my groups
```swift
let s = johnSession
s?.account?.blockingGet()?.blockingStreamGroup(limit: 10)
```

#### Search for groups by name or description
```swift
let s = johnSession

let query = FluentGroup.Search.Builder()
        .setName("my group name")
        .setDescription("my group description")
        .build()

s?.group?.blockingSearch(query)
```

#### Search for groups by owner
```swift
[..]
user.blockingStreamGroup(limit: 10)
```

#### Create post on group
```swift
[..]
let post = FeedPost.Builder()
        .setMessage("This is a post with #hashtag url https://mysocialapp.io and someone mentioned [[user:3856809369215939951]]")
        .setVisibility(.Public)
        .build()

group.blockingSendWallPost(post)
```

# Credits

* [Swift](https://www.apple.com/fr/swift/)
* [RxSwift](https://github.com/ReactiveX/RxSwift)
* [Alamofire](https://github.com/Alamofire/Alamofire)

# Contributions

All contributions are welcomed. Thank you
