# 隻字片語 Quotely

<p align="center">
    <img width="150" height="150" src="https://github.com/MorganCY/Quotely/blob/main/Quotely/Quotely/Resource/Assets.xcassets/AppIcon.appiconset/1024.png"/>
</p>

<p align="center">
    <img src="https://img.shields.io/badge/platform-iOS-lightgray">
    <img src="https://img.shields.io/badge/release-v1.1.8-green">
    <img src="https://img.shields.io/badge/license-MIT-blue">
</p>

<p align="center">
    <b>Quotely</b> helps people ﬁnd inspiring quotes in everyday life.</br> It is also used for people as a quotes diary to save touching lines,</br> and a supportive community to share thoughts/emotions/mood with each other.
</p>

<p align="center">
    <span>
        我們常常在生活中接觸到讓人很有感觸的「句子」，無論是追劇、看電影、看書，或是聽別人說，<br>
        比起發人深省的長篇大論，這些句子往往非常簡短，卻能在轉眼之間觸及我們心底深處。</br>
        <b>隻字片語</b>便是一個幫助用戶收集這些靈感、找到更多句子和分享感觸的App。
    </span>
</p>

<p align="center">
    <a href="https://github.com/MorganCY/Quotely#features">Features</a>
    <span style="color:gray">‧</span>
    <a href="https://github.com/MorganCY/Quotely/#technical-highlights">Technical Highlights</a>
    <span style="color:gray">‧</span>
    <a href="https://github.com/MorganCY/Quotely/#release-note">Release Note</a>
    <span style="color:gray">‧</span>
    <a href="https://github.com/MorganCY/Quotely/#requirement">Requirement</a>
    <span style="color:gray">‧</span>
    <a href="https://github.com/MorganCY/Quotely/#libraries">Libraries</a>
    <span style="color:gray">‧</span>
    <a href="https://github.com/MorganCY/Quotely/#contact">Contact</a>
    <span style="color:gray">‧</span>
    <a href="https://github.com/MorganCY/Quotely/#license">License</a></br></br>
    <a href="https://apps.apple.com/tw/app/id1591812700"><img src="https://www.dashsuites.com/wp-content/uploads/2017/07/app-store-logo-1024x353.png" height="50"></a>
</p>

# Features
### Core Features

<ol>
    <li>Find Inspiring Quote</li>
    <li>Share Thoughts/Emotions/Mood</li>
    <li>Save Touching Lines</li>
</ol>

### 1. Find Inspring Quotes
<b>Tinder-esque Swipeable Card</b></br>
- There's one inspiring quote on each card. Swipe the card to right to save it to favorite list

<p>
    <img src="https://i.imgur.com/GOGSr11.gif"/>
    <span>   </span>
    <img src="https://i.imgur.com/CeyfP7q.png"/>
</p>

<b>Customize SwipeCardView</b>

- Create swipeable card with `UIPanGesTureRecognizer`
```swift
@objc func dragCard(_ sender: UIPanGestureRecognizer) {

    switch sender.state {

    // Swipe begins
    case .began:
        originPoint = self.center

    // Keep swiping
    case .changed:
        // The View rotates itself as its x axis changes
        let rotationStrength = min(xCenter / UIScreen.main.bounds.size.width, 1)
        let rotationAngel = .pi / 8 * rotationStrength

        // The View scales slightly when being swiped
        let scale = max(1 - abs(rotationStrength) / stength, range)

        center = CGPoint(x: originPoint.x + xCenter, y: originPoint.y + yCenter)

        let transforms = CGAffineTransform(rotationAngle: rotationAngel)
        let scaleTransform: CGAffineTransform = transforms.scaledBy(x: scale, y: scale)
        self.transform = scaleTransform

    // Swipe ends
    case .ended:
        afterSwipeAction()

    ...
    }
}
```
- Create SwipeCardStackView to encapsulate SwipeCardView and generate index for the card views, and implement `protocols` to manage the views
```Swift
protocol SwipeCardStackViewDataSource: AnyObject {

    func numbersOfCardsIn(_ stack: SwipeCardStackView) -> Int

    func cardForStackIn(_ stack: SwipeCardStackView, index: Int) -> String

    func authorForCardsIn(_ stack: SwipeCardStackView, index: Int) -> String
}
```
```Swift
protocol SwipeCardStackViewDelegate: AnyObject {

    func cardGoesLeft(_ stack: SwipeCardStackView, currentIndex: Int, nextIndex: Int)

    func cardGoesRight(_ stack: SwipeCardStackView, currentIndex: Int, nextIndex: Int)
}
```

<b>Favorite Card List</b>

- See the card you saved on this list

<p>
    <img src="https://i.imgur.com/7kxgkxt.gif"/>
    <span>   </span>
    <img src="https://i.imgur.com/mefkRCg.png"/>
</p>

<b>Make Card Template for Sharing</b>

- By taking a screenshot on iPhone, you will be guided to the template making page. Create your own card and share it to Instagram or save it!

<p>
    <img src="https://i.imgur.com/oTG5NhU.gif"/>
    <span>   </span>
    <img src="https://i.imgur.com/luqtM0j.png"/>
</p>

### 2. Share Thoughts and Emotions with the Community

<b>Write a post with quotes</b>

- Write down what you think about the quotes or any thoughts with the supportive community!

<p>
    <img src="https://i.imgur.com/9ceo2MW.png"/>
    <span>   </span>
    <img src="https://i.imgur.com/xEz1Hk2.gif"/>
</p>

- Apply `Vision framework` to realize text recoginition
```Swift
func recognizeText(image: UIImage?,
                    textHandler: @escaping (_ text: String) -> Void) {

    guard let cgImage = image?.cgImage else {
        return
    }
    ...

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

    let request = VNRecognizeTextRequest { request, error in

        guard let observations = request.results as? [VNRecognizedTextObservation],
            error == nil else {

             Toast.showFailure(text: ToastText.failToScan.rawValue)
            return
        }

        let text = observations.compactMap {
            $0.topCandidates(1).first?.string
        }.joined()
        ...
        }

    request.recognitionLanguages = ["zh-Hant", "en"]

    do {
        try handler.perform([request])
    } catch {
        print(error)
        ...
    }
}
```

<b>Responsive News Feed</b>
- Like other users' posts and leave a comment

<p>
    <img src="https://i.imgur.com/tk6WYoz.gif"/>
    <span>   </span>
    <img src="https://i.imgur.com/JXoDUvJ.png"/>
</p>

- Utilize `DispathGroup` to ensure post data are processed after all API calls are executed
```Swift
func fetchUserList(postList: [Post]) {

    var userList: [User] = Array(repeating: User.default, count: postList.count)
    let group = DispatchGroup()

    DispatchQueue.main.async {

        for (index, post) in postList.enumerated() {

            group.enter()
                
            UserManager.shared.fetchUserInfo(uid: post.uid) { result in
                switch result {
                case .success(let user):
                    userList[index] = user
                    group.leave()

                case .failure(let error):
                    print(error)
                    Toast.showFailure(text: ToastText.failToDownload.rawValue)
                    group.leave()
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            self.userList = userList
            ...
        }
    }
}
```

- Implement real-time post update by `Firestore SnapShotListener`
```Swift
query.addSnapshotListener { [self] (documentSnapshot, error) in

    if let error = error {
                    completion(.failure(error))
    }

    var posts = [Post]()
    
    guard let documentSnapshot = documentSnapshot else { return }

    for document in documentSnapshot.documents {

        do {
           if let post = try document.data(as: Post.self, decoder: Firestore.Decoder()) {
                filterOutBlockedUser(post: post, posts: &posts)
            }
        } catch {
            completion(.failure(error))
        }
    }
    completion(.success(posts))
}
```

### 3. Save Touching Lines

<b>Write the Touching Lines and Thoughts</b>

- Catch each inspiring moment and write down every single piece of thoughts

<p>
    <img src="https://i.imgur.com/AtAtJVS.gif"/>
    <img src="https://i.imgur.com/Pc8aaOf.gif"/>
</p>

- Instantiate customized SelectionView for selecting icons and implement `protocols` to manage the view
```Swift
protocol SelectionViewDataSource: AnyObject {

    func numberOfButtonsAt(_ view: SelectionView) -> Int
    ...
    func buttonImage(_ view: SelectionView, index: Int) -> UIImage?

    func buttonColor(_ view: SelectionView) -> UIColor

    func indicatorColor(_ view: SelectionView) -> UIColor
    ...
}
```
```Swift
@objc protocol SelectionViewDelegate: AnyObject {

    @objc optional func didSelectButtonAt(_ view: SelectionView, at index: Int)

    @objc optional func shouldSelectButtonAt(_ view: SelectionView, at index: Int) -> Bool
}
```

# Technical Highlights
- Wrote readable, idiomatic and maintainable code using `OOP` and `MVC` patterns
- Programmed Auto Layout with codes for most of the views to make the app compatible for different devices
- Created flexibly reusable UITableviewCell and UICollectionViewCell via `nib` file
- Designed `custom views` and managed the views with `protocols`
- Implemented `Sign in with Apple` and integrated user account into `Firebase Auth`
- Applied `Vision framework` to realize text recognition for users to input scanned text through camera and photos
- Established responsive news feed which updates posts data in real time by monitoring data changes through `Firebase Snapshot Listener`
- Utilized `DispatchGroup` to ensure data was processed after API calls were executed
- Used `Singleton` pattern to ensure objects access the single instance of model managers
- Integrated `Firestore` to manage data, and processed image by `Firebase Storage`
- Achieved displaying new user guide during first-time launch with `UserDefaults` by saving a one-time flag
- Detected screenshot behavior on device using `NotificationCenter`
- Integrated `Crashlytics` to track stability issues effectively

# Release Note
<img src="https://img.shields.io/badge/current-v1.1.8-green"/>

| Version  | Release Date | Note |
|:-------------:|:-------------:|:-------------|
| 1.1.8 | Nov 24 2021 | Fix some minor bugs & add more guide on interface for better experience.
| 1.1.2 | Nov 20 2021 | Add user guide for first-time launch & fix some minor bugs.
| 1.0.0 | Nov 19 2021 | Launch MVP to App Store.

# Requirement

* Xcode 13.1 or any higher version.
* Swift 5.0 or any higher version.
* iOS 13.0 or any higher version.

# Libraries

*  [SwiftLint](https://github.com/realm/SwiftLint) : Inspect coding style
*  [Kingfisher](https://github.com/onevcat/Kingfisher) : Download and cache images
*  [JGProgressHUD](https://github.com/JonasGessner/JGProgressHUD) : Toast of loading, success, and fail
*  [UITextView+Placeholder](https://github.com/devxoul/UITextView-Placeholder) : Display placeholder in UITextView
*  [lottie-ios](https://github.com/airbnb/lottie-ios) : Ship reminder animation when loading data and finding empty data
*  [IQKeyboardManagerSwift](https://github.com/hackiftekhar/IQKeyboardManager) : Improve keyboard using experience
*  [Firebase](https://firebase.google.com/docs/ios/setup) : Database usage

# Contact

Morgan Yu | nihao0705@gmail.com

# License

This project is licensed under the terms of the [MIT license](https://github.com/MorganCY/Quotely/blob/main/LICENSE).
