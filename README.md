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
  pod 'MySocialApp', '~> 1.0.16'

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

### Common usage
Everytime you see a "try" instruction, you have the choice between these two alternatives :

#### Error catching
```swift
do {
    try MySocialApp.someOperation.throwingException()
} catch let e as MySocialAppException {
    NSLog("Exception caught : \(e.message)")
} catch {
    NSLog("Another technical exception")
}
```

#### No error catching, just tests if it succeeds
```swift
if let myResult = try? MySocialApp.someOperation.throwingException() {
    doSomething(with: myResult)
} else {
    // Some error occured
}
```

### Profile
#### Create an account
```swift
let appId = "u123456789123a123456"
let msa = MySocialApp.Builder().setAppId(appId).build()

// or
let endpointURL = "https://u123456789123a123456-api.mysocialapp.io";
let msa = MySocialApp.Builder().setAPIEndpointURL(endpointURL).build()

// create an account and return an active session to do fluent operations
let johnSession = try msa.blockingCreateAccount(username: "John", email: "john@myapp.com", password: "myverysecretpassw0rd")
```

#### Do login with an access token and get session
```swift
let johnSession = try msa.blockingConnect(accessToken: "my access token")
```

#### Do login with your account and get session
```swift
let johnSession = try msa.blockingConnect(username: "John", password: "myverysecretpassw0rd")
```

#### Get your account info
```swift
if let account = try johnSession?.account.blockingGet() {
    let _ = account.firstName
    let _ = account.dateOfBirth
    let _ = account.livingLocation?.completeCityAddress
    // [..]
}
```

#### Update your account
```swift
if let account = try johnSession?.account.blockingGet() {
    account.lastName = "James"
    let updatedAccount = try account.blockingSave() // or use save() to asynchronously save it with Rx
}
```

#### How to integrate a MySocialApp user with an existing user in my application? 
MySocialApp allows you to use your own user IDs to find a user using the "external_id" property. 

```swift
let yourAppUserId = "12348-abcdy-82739-qzdqdq"

let s = johnSession

// set app external user id
if let account = try johnSession?.account.blockingGet() {
    account.externalId = yourAppUserId
    let updatedAccount = try account.blockingSave()
}

// find user by external id
let user = try johnSession?.user.blockingGetByExternalId(yourAppUserId)
```

#### Delete your account (not recoverable)
⚠ Caution: this operation is not recoverable
```swift
let s = johnSession
let password = "your account password to confirm the ownership"

let _ = try s?.account.blockingRequestForDeleteAccount(password: password)
// Your account has been deleted..
// You are no more able to perform operations
```

### News feed
#### List news feed from specific page and size
```swift
let feeds = try johnSession?.newsFeed.blockingList(page: 0, size: 10)
```

#### Stream all 100 first news feed message
```swift
let feeds = try johnSession?.newsFeed.blockingStream(limit: 100)
```

#### Post public news with hashtag + url + user mention
```swift
let s = johnSession

let post = try FeedPost.Builder()
        .setMessage("This is a post with #hashtag url https://mysocialapp.io and someone mentioned [[user:3856809369215939951]]")
        .setVisibility(.Public)
        .build()

try s?.newsFeed.blockingSendWallPost(post)
``` 

#### Post public photo with a hashtag
```swift
let s = johnSession
let i = someUIImage

let post = try FeedPost.Builder()
        .setMessage("This is a post with an image and a #hashtag :)")
        .setImage(i)
        .setVisibility(.Public)
        .build()

try s?.newsFeed.blockingSendWallPost(post)
```

#### Post on a friend wall and mention him
```swift
let s = johnSession

// take my first friend
if let friend = try s?.account.blockingGet()?.blockingListFriends()?.first {

    let post = try FeedPost.Builder()
        .setMessage("Hey [[user:\(friend.id)]] what's up?")
        .setVisibility(.Friend)
        .build()

    try friend.blockingSendWallPost(post)
}
```

#### Ignore a news feed post
```swift
let s = getSession()
if let newsFeed = try s?.newsFeed.blockingStream(limit: 1)?.first {
    try newsFeed.blockingIgnore()
}
```

#### Report a news feed post
```swift
let s = getSession()
if let newsFeed = try s?.newsFeed.blockingStream(limit: 1)?.first {
    try newsFeed.blockingReport()
}
```

#### Delete a news feed post
```swift
let s = getSession()
if let newsFeed = try s?.newsFeed.blockingStream(limit: 1)?.first {
    try newsFeed.blockingDelete()
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

let users = try s?.user.blockingSearch(searchQuery)?.data
// return the 10 first results
```

#### Search for users by their living location
```swift
let s = johnSession

let parisLocation = Location(latitude: 48.85661400000001, longitude: 2.3522219000000177)

let searchQuery = FluentUser.Search.Builder()
        .setLocation(parisLocation)
        .build()

let users = try s?.user.blockingSearch(searchQuery)?.data
// return the 10 first results
```

#### Search for news feeds that contains "hello world"
```swift
let s = johnSession

let searchQuery = FluentFeed.Search.Builder()
        .setTextToSearch("hello world")
        .build()

let feeds = try s?.newsFeed.blockingSearch(searchQuery)?.data
// return the 10 first results
```

### Private conversation
#### List private conversations
```swift
let s = johnSession
let conversations = try s?.conversation.blockingList()
```

#### Create conversation
```swift
let s = johnSession

// take 3 first users
if let people = try s?.user.blockingStream(limit: 3) {

    let conversation = Conversation.Builder()
        .setName("let's talk about the next event in private")
        .addMembers(people)
        .build()

    let createdConversation = try s?.conversation.blockingCreate(conversation)
}
```

#### Post new message into conversation
```swift
let s = johnSession
let i = someUIImage
if let lastConversation = try s?.conversation.blockingList().first {

    let message = try ConversationMessagePost.Builder()
            .setMessage("Hello, this is a message from our SDK #MySocialApp with an amazing picture. Enjoy")
            .setImage(i)
            .build()

    let messageSent = try lastConversation.blockingSendMessage(message)
}
```

#### Get messages from conversation
```swift
let s = johnSession
let conversation = try s?.conversation.blockingList().first

// get 35 last messages without consuming them
let conversationMessages = try conversation?.messages?.blockingStream(limit: 35)

// get 35 last messages and consume them
let conversationMessages = try conversation?.messages?.blockingStreamAndConsume(limit: 35)
```

#### Change conversation name
```swift
let s = johnSession
let conversion = try s?.conversation.blockingList().first

conversion?.name = "new conversation title :)"
try conversion?.blockingSave()
```

#### Kick/invite member from conversation
```swift
let s = johnSession
let conversation = try s?.conversation.blockingList().first

// kick member
try conversation?.blockingKickMember(user)

// invite user
try conversation?.blockingAddMember(user)
```

#### Send quick private message to someone
```swift
let s = johnSession
let i = someUIImage
if let user = try? s?.user.blockingList().first {

    let message = ConversationMessagePost.Builder()
        .setMessage("Hey [[user:\(user.id)]] ! This is a quick message from our SDK #MySocialApp with an amazing picture. Enjoy")
        .setImage(i)
        .build()

    try user.blockingSendPrivateMessage(message)
}
```

#### Quit conversation
```swift
let s = johnSession
if let conversation = try? s?.conversation.blockingList().first {
    try conversation.blockingQuit()
}
```

### Event
This module is optional. Please contact [us](mailto:support@mysocialapp.io) to request it

#### List 50 next events
```swift
let s = johnSession
try s?.event.blockingStream(limit: 50)
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

try s?.event.blockingCreate(event)
```

#### Update an event
```swift
event.name = "New event name"
try event.save()
```

#### Join / participate to an event
```swift
try event.blockingParticipate()
```

#### List my 10 next events
```swift
let s = johnSession
try s?.account.blockingGet()?.blockingStreamEvent(limit: 10)
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

try s?.event.blockingSearch(query)
```

#### Search for events by name or description
```swift
let s = johnSession

let query = FluentEvent.Search.Builder()
        .setName("my event name")
        .setDescription("my event description")
        .build()

try s?.event.blockingSearch(query)
```

#### Search for events by owner
```swift
[..]
try user.blockingStreamEvent(limit: 10)
```

#### Create post on event
```swift
[..]
let post = FeedPost.Builder()
        .setMessage("This is a post with #hashtag url https://mysocialapp.io and someone mentioned [[user:3856809369215939951]]")
        .setVisibility(.Public)
        .build()

try event.blockingSendWallPost(post)
```

### Group
This module is optional. Please contact [us](mailto:support@mysocialapp.io) to request it 

#### List groups
```swift
let s = johnSession
try s?.group.blockingStream(limit: 100)
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

try s?.group.blockingCreate(group)
```

#### Update a group
```swift
group.name = "New group name"
try group.save()
```

#### Join a group
```swift
try group.blockingJoin()
```

#### List my groups
```swift
let s = johnSession
try s?.account.blockingGet()?.blockingStreamGroup(limit: 10)
```

#### Search for groups by name or description
```swift
let s = johnSession

let query = FluentGroup.Search.Builder()
        .setName("my group name")
        .setDescription("my group description")
        .build()

try s?.group.blockingSearch(query)
```

#### Search for groups by owner
```swift
[..]
try user.blockingStreamGroup(limit: 10)
```

#### Create post on group
```swift
[..]
let post = FeedPost.Builder()
        .setMessage("This is a post with #hashtag url https://mysocialapp.io and someone mentioned [[user:3856809369215939951]]")
        .setVisibility(.Public)
        .build()

try group.blockingSendWallPost(post)
```

### Custom Fields
This feature is available on users, events, groups, and other options to allow your community to provide specific information. This feature can be managed on your MySocialApp admin console.

#### Display all custom fields of a user
```swift
let s = johnSession
if let user = try s?.user.blockingList().first {
    try user.blockingGetCustomFields().forEach {
        field in
        // NB: label, placeholder and string values are automatically translated into the user's language
        NSLog("Custom Field label: \(field.label)")
        // Every type of Custom Field may have a placeholder
        NSLog("Custom Field placeholder: \(field.placeholder)")
        if let type = field.fieldType {
            NSLog("Custom Field type: \(type)")
            if type == FieldType.inputSelect || type == FieldType.inputCheckbox {
                // For SELECT and CHECKBOX types, the list of possible values is provided
                NSLog("CustomField possible values: \(field.possibleValues)")
            }
            // The way the value can be get / set depends on the type of the Custom Field
            switch type {
                case .inputBoolean:
                    NSLog("Custom Field value: \(field.boolValue)")
                case .inputDate, .inputDateTime, .inputTime:
                    NSLog("Custom Field value: \(field.dateValue)")
                case .inputCheckbox:
                    NSLog("Custom Field values: \(field.stringsValue)")
                case .inputUrl, .inputText, .inputEmail, .inputPhone, .inputSelect, .inputTextarea:
                    NSLog("Custom Field value: \(field.stringValue)")
                case .inputLocation:
                    NSLog("Custom Field value: \(field.locationValue)")
                case .inputNumber:
                    NSLog("CustomField value: \(field.doubleValue)")
            }
        }
    }
}
```

#### Set the location and url on custom fields on a group
```swift
let newarkLocation = Location(latitude: 40.736504474883915, longitude: -74.18175405)
let url = "https://mysocialapp.io"

if let group = try s?.group.blockingList().first {
    if let locationField = try group.blockingGetCustomFields().filter({
                group in
                return group.fieldType == FieldType.inputLocation
            }).first {
        locationField.locationValue = newarkLocation
    }

    if let urlField = try group.blockingGetCustomFields().filter({
                group in
                return group.fieldType == FieldType.inputUrl
            }).first {
        urlField.stringValue = url
    }

    try group.blockingSave()
}
```

# Credits

* [Swift](https://www.apple.com/fr/swift/)
* [RxSwift](https://github.com/ReactiveX/RxSwift)
* [Alamofire](https://github.com/Alamofire/Alamofire)

# Contributions

All contributions are welcomed. Thank you
