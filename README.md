# mysocialapp-swift-client

#### MySocialApp - Seamless Social Networking features for your app
Official Swift client to interact with apps made with [MySocialApp](https://mysocialapp.io)

# What is MySocialApp?

MySocialApp’s powerful API lets you quickly and seamlessly implement social networking features within your websites, mobile and back-end applications. Our API powers billions of requests for hundred of apps every month, delivering responses in under 100ms.

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
  pod 'MySocialApp', :git => 'https://github.com/MySocialApp/mysocialapp-swift-client.git', :branch => 'swift4.2'
    ...
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

#### Location usage
You may use Google Places API, or Apple MapKit. Here is an example of the use of MapKit to provide a list of matching locations from an input string :
```swift
import MapKit
// [..]
let thePlaceToFind: String = "some place somewhere"
let callbackToCallWithFoundLocations: ((_: [Location])->Void) = someCallBackFunction

let request = MKLocalSearchRequest()
request.naturalLanguageQuery = thePlaceToFind
let search = MKLocalSearch(request: request)
search.start {
    response, error in
    if let r = response {
        let locations: [Location] = r.mapItems.map {
            mi in
            let l = Location()
            l.latitude = mi.placemark.coordinate.latitude
            l.longitude = mi.placemark.coordinate.longitude
            if let lines = mi.placemark.addressDictionary?["FormattedAddressLines"] as? [String] {
                // Concatenate every address line, separated by a coma
                var fullName = ""
                var separator = ""
                lines.forEach {
                    fullName += separator + $0
                    separator = ", "
                }
                if let name = mi.placemark.addressDictionary?["Name"] as? String, !fullName.contains(name) {
                    fullName = name + separator + fullName
                }
                // The completeAddress field will contain the fully qualified human-readable location
                l.completeAddress = fullName
            }
            return l
        }
        callbackToCallWithFoundLocations(locations)
    } else {
        callbackToCallWithFoundLocations([])
    }
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

#### Update profile photo
```swift
let myPhoto = UIImage()
// [..]
try johnSession?.account.blockingChangeProfilePhoto(myPhoto)
```

#### Update profile cover photo
The cover photo is a secondary photo that you can add to your profile.

```swift
let myPhoto = UIImage()
// [..]
try johnSession?.account.blockingChangeProfileCoverPhoto(myPhoto)
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

### User
#### List nearest users from specific location
```swift
let s = johnSession

let madridLocation = Location(latitude: 40.416775, longitude: -3.703790)
try s?.user.blockingStream(limit: 10, with: FluentUser.Options.Builder().setLocation(madridLocation).build())
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
NB: Setting custom fields value is detailled in the [Custom fields](#set-the-location-and-url-on-custom-fields-on-a-group) section.
```swift
let s = johnSession
let i = someUIImage

let newarkLocation = Location(longitude: 40.736504474883915, latitude: -74.18175405)
 
let tomorrow = Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: Date())

let afterTomorrow = Calendar.current.date(byAdding: Calendar.Component.day, value: 2, to: Date())

let customFields = try s?.event.blockingGetAvailableCustomFields().map {
    customField -> (CustomField) in
    if let type = customField.fieldType {
        switch type {
            case .inputText:
                customField.stringValue = "Text test"
            case .inputTextarea:
                customField.stringValue = "TextArea test text"
            case .inputNumber:
                customField.doubleValue = 1337
            case .inputBoolean:
                customField.boolValue = false
            case .inputDate:
                customField.dateValue = Date()
            case .inputUrl:
                customField.stringValue = "https://mysocialapp.io"
            case .inputEmail:
                customField.stringValue = "test@mysocialapp.io"
            case .inputPhone:
                customField.stringValue = "+33123452345"
            case .inputLocation:
                customField.locationValue = newarkLocation
            case .inputSelect:
                customField.stringValue = customField.possibleValues?.first
            case .inputCheckbox:
                customField.stringsValue = customField.possibleValues ?? []
            case .inputDateTime:
                customField.dateValue = Date()
            case .inputTime:
                customField.dateValue = Date()
            default:
                break
        }
    }
    return customField
}
 
let event = Event.Builder()
        .setName("New test event")
        .setDescription("This is a new event create with our SDK")
        .setStartDate(tomorrow)
        .setEndDate(afterTomorrow)
        .setLocation(newarkLocation)
        .setMaxSeats(100)
        .setMemberAccessControl(.Public)
        .setCoverImage(i)
        .setCustomFields(customFields)
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

#### Change event image (owner only)
```swift
let i = someUIImage
try event.blockingChangeImage(i)
```

#### Change event cover image (owner only)
```swift
let i = someUIImage
try event.blockingChangeCoverImage(i)
```

#### List nearest events from specific location
```swift
let s = johnSession

let madridLocation = Location(latitude: 40.416775, longitude: -3.703790)
try s?.event.blockingStream(limit: 10, with: FluentEvent.Options.Builder().setLocation(madridLocation).build())
```

#### Search events between two dates
```swift
let s = johnSession

let tomorrow = Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: Date())

let afterTomorrow = Calendar.current.date(byAdding: Calendar.Component.day, value: 2, to: Date())

let madridLocation = Location(latitude: 40.416775, longitude: -3.703790)

let query = FluentEvent.Search.Builder()
        .setLocation(madridLocation)
        .setLocationMaximumDistanceInKilometers(100.0)
        .setFromDate(tomorrow)
        .setToDate(afterTomorrow)
        .setDateField(.startDate)
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

#### Change group image (owner only)
```swift
let i = someUIImage
try group.blockingChangeImage(i)
```

#### Change group cover image (owner only)
```swift
let i = someUIImage
try group.blockingChangeCoverImage(i)
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

#### List nearest groups from specific location
```swift
let s = johnSession

let madridLocation = Location(latitude: 40.416775, longitude: -3.703790)
try s?.group.blockingStream(limit: 10, with: FluentGroup.Options.Builder().setLocation(madridLocation).build())
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

# Realtime notifications
In order to make your application able to receive native and silent notifications from our backend, here are some steps to follow.

## Create a .p12 certificate
Why ? We must provide to the APNS a valid certificate related to your application.
### Create an APNS certificate
- Connect on your Apple Developer Account, and then get into the "Certificates, Identifiers & Profiles" section, on the "Certificates > All" tab (i.e. on [this URL](https://developer.apple.com/account/ios/certificate/)).
- Click on the "+" button to create a new certificate
- Choose "Apple Push Notification service SSL (Sandbox & Production)" and click on "Continue"
- Choose your App ID in the list and click on "Continue"
- Follow the instructions to create a CSR
- Click on "Continue"
- Choose the CSR you just created and click on "Continue"
- Download the generated certificate
### Create the first .p12 file
- Double-click on the certificate you just downloaded, this will open your Keychain manager
- Search in the "My certificates" list to find a certificate named "Apple Push Services: {your App ID}"
- Right-click on it and choose "Export ..." and export it as a .p12 file
- A password is requested, so enter "mysocialapp" (only lowercased)
### Convert the .p12 file into a usable one
- On command line (in terminal), in the folder containing the .p12 file, just type these instructions, typing "mysocialapp" (only lowercased) as password everytime one is asked :
```
# These instructions require a Java Development Kit (JDK) installed on your system
keytool -importkeystore -destkeystore mysocialapp.jks -srckeystore {your .p12 exported certificat}.p12  -srcstoretype PKCS12
keytool -importkeystore -srckeystore mysocialapp.jks -srcstoretype JKS -deststoretype PKCS12 -destkeystore mysocialapp.p12
openssl base64 -in mysocialapp.p12 -out mysocialapp.b64
```
### Upload the .p12
- Connect on your [admin console](https://go.mysocialapp.io)
- Click on your app
- Choose the "Certificates" tab
- Click on the "+ Add" button
- Enter your package name (App ID)
- Choose IOS as platform
- Enter the expiration date
- Copy / paste the content of the file in the field (open the file "mysocialapp.b64" in a text editor to do so)
- Click on "Add" button, and that's it!

## Make your app aware of notifications
Now you need to adapt your app to register on our backend, and to provide callbacks to be notified when a notification is received, or when the user taps on a native notification to open it in your app

### Enable notifications for your app
In the project properties in XCode, got to the main target Capabilities, and enable "Push notifications", "Background modes", and in "Background modes" check "Background fetch" and "Remote notifications"

### Allow notifications to be received by your app
You need to ask to the user for permission to notify it. Just put this piece of code to ask the user for permission to send it notifications :
```swift
if #available(iOS 10, *) {
    DispatchQueue.main.async {
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){
            (granted, error) in
            UNUserNotificationCenter.current().delegate = self
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
} else {
    DispatchQueue.main.async {
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
        UIApplication.shared.registerForRemoteNotifications()
    }
}
```

### Register your app on our backend
Once the user permission is granted, and once the application is registered for remote notifications, you have to receive the APNS token to send it to our backend, by implementing certain methods
```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let msa = MySocialApp.Builder().setAppId(appId).build()
    do {
        let johnSession = try msa.blockingConnect(accessToken: "user access token stored in user defaults or wherever")
        try johnSession.notification.blockingRegisterToken(deviceToken)
    } catch let e as MySocialAppException {
        NSLog("Exception caught : \(e.message)")
    } catch {
        NSLog("Another technical exception")
    }
}
```

If the user explicitely logs out, you may unregister the token to avoid the user receiving unwanted notifications
```swift
try johnSession.notification.blockingUnregisterToken()
```

### Provide callback for silent notification (only in foreground and background mode)
You have to implement these methods in the __AppDelegate.swift__ file:
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // [..]
    let msa = MySocialApp.Builder().setAppId(appId).build()
    do {
        let johnSession = try msa.blockingConnect(accessToken: "user access token stored in user defaults or wherever")
        if let receivedNotification = try johnSession.notification.application(didFinishLaunchingWithOptions: launchOptions) {
            // [..] A notification has just been received, you may update the app GUI to notify the user
        } else {
            // Nothing happened, it is a regular application start
        }
    } catch let e as MySocialAppException {
        NSLog("Exception caught : \(e.message)")
    } catch {
        NSLog("Another technical exception")
    }
    // [..]
}

func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    let msa = MySocialApp.Builder().setAppId(appId).build()
    do {
        let johnSession = try msa.blockingConnect(accessToken: "user access token stored in user defaults or wherever")
        if let receivedNotification = try johnSession.notification.application(didReceiveRemoteNotification: userInfo) {
            // [..] The notification has just been received, you may update the app GUI to notify the user
        } else {
            // It wasn't a MySocialApp notification
        }
    } catch let e as MySocialAppException {
        NSLog("Exception caught : \(e.message)")
    } catch {
        NSLog("Another technical exception")
    }
}

func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    let msa = MySocialApp.Builder().setAppId(appId).build()
    do {
        let johnSession = try msa.blockingConnect(accessToken: "user access token stored in user defaults or wherever")
        if let receivedNotification = try johnSession.notification.application(didReceiveRemoteNotification: userInfo) {
            // [..] The notification has just been received, you may update the app GUI to notify the user
        } else {
            // It wasn't a MySocialApp notification
        }
    } catch let e as MySocialAppException {
        NSLog("Exception caught : \(e.message)")
    } catch {
        NSLog("Another technical exception")
    }
    completionHandler(.noData)
}
```

### Provide callback for native notification tapped by user
To handle properly the actions on the native notifications, you first have to setup your application to receive the URL generated especially for your MySocialApp appId. To do so, you have to edit your __Info.plist__ file to add these lines in the main <dict> markup, remplacing the "u123456789123a123456" by your appId :
```
<key>CFBundleURLTypes</key>
<array><dict>
<key>CFBundleURLSchemes</key>
<array>
<string>u123456789123a123456</string>
</array>
</dict></array>
```

Then, the actions on the native notifications can thus be catched in the __AppDelegate.swift__ file by implementing these methods:
```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    let msa = MySocialApp.Builder().setAppId(appId).build()
    do {
        let johnSession = try msa.blockingConnect(accessToken: "user access token stored in user defaults or wherever")
        if let tappedNotification = try johnSession.notification.application(continue: userActivity) {
            // [..] The notification has just been tapped by the user, you may do something with the notification, like displaying it
        } else {
            // It wasn't a MySocialApp notification
        }
    } catch let e as MySocialAppException {
        NSLog("Exception caught : \(e.message)")
    } catch {
        NSLog("Another technical exception")
    }
    return true
}

func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    let msa = MySocialApp.Builder().setAppId(appId).build()
    do {
        let johnSession = try msa.blockingConnect(accessToken: "user access token stored in user defaults or wherever")
        if let tappedNotification = try johnSession.notification.application(open: url) {
            // [..] The notification has just been tapped by the user, you may do something with the notification, like displaying it
        } else {
            // It wasn't a MySocialApp notification
        }
    } catch let e as MySocialAppException {
        NSLog("Exception caught : \(e.message)")
    } catch {
        NSLog("Another technical exception")
    }
    return true
}

@available(iOS 10.0, *)
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let msa = MySocialApp.Builder().setAppId(appId).build()
    do {
        let johnSession = try msa.blockingConnect(accessToken: "user access token stored in user defaults or wherever")
        if let tappedNotification = try johnSession.notification.userNotificationCenter(didReceive: response) {
            // [..] The notification has just been tapped by the user, you may do something with the notification, like displaying it
        } else {
            // It wasn't a MySocialApp notification
        }
    } catch let e as MySocialAppException {
        NSLog("Exception caught : \(e.message)")
    } catch {
        NSLog("Another technical exception")
    }
}
```
# Demo apps using MySocialApp

* [MySocialApp Android](https://play.google.com/store/apps/details?id=io.mysocialapp.android)
* [MySocialApp iOS](https://itunes.apple.com/fr/app/mysocialapp-your-social-app/id1351250650)

# Credits

* [Swift](https://www.apple.com/fr/swift/)
* [RxSwift](https://github.com/ReactiveX/RxSwift)
* [Alamofire](https://github.com/Alamofire/Alamofire)

# Contributions

All contributions are welcomed. Thank you
