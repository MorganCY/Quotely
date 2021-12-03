# Quotely

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
    <span style="color: gray">
        我們常常在生活中接觸到讓人很有感觸的「句子」，無論是追劇、看電影、看書，或是聽別人說，<br>
        比起發人深省的長篇大論，這些句子往往非常簡短，卻能在轉眼之間觸及我們心底深處。</br>
        隻字片語便是一個幫助用戶收集這些靈感、找到更多句子和分享感觸的App。
    </span>
</p>

<p align="center">
    <a href ="">Features</a>
    <span style="color:gray">‧</span>
    <a href ="">Technical Highlights</a>
    <span style="color:gray">‧</span>
    <a href ="">Libraries</a>
    <span style="color:gray">‧</span>
    <a href ="">Version</a>
    <span style="color:gray">‧</span>
    <a href ="">Release Note</a>
    <span style="color:gray">‧</span>
    <a href ="">Requirement</a>
    <span style="color:gray">‧</span>
    <a href ="">Contact</a>
    <span style="color:gray">‧</span>
    <a href ="">License</a>
</p>

# Features
### Core Features
<ol>
    <li>Find Inspiring Quote</li>
    <li>Share Thoughts/Emotions/Mood</li>
    <li>Save Touching Lines</li>
</ol>

### Introduction
#### 1. Find Inspring Quotes
Swipe Tinder-esque cards to browse different sentences from books, shows, and movies, and save the ones you like!
- Tinder-esque Swipeable Card
> There's one inspiring quote on each card.</br>
> By swiping the cards to left and right, users decide whether to save the quote card to favorite list.

<img src="https://i.imgur.com/rluy0vV.gif"/>
<img src="https://i.imgur.com/CeyfP7q.png"/>

- Favorite List
> Through the entry button on top-right corner, users browse the list of their favorite cards.

<img src="https://i.imgur.com/ijzhuyF.gif"/>
<img src="https://i.imgur.com/mefkRCg.png"/>

- Share to Social Media
> By taking a screenshot on iPhone or tapping the button on the bottom-left corner, users are guided to the page where they can customize a card image.</br>
> Afterwards, users can share the image to Instagram Stories or save to photo album.

<img src="https://i.imgur.com/C7dMRDL.gif"/>
<img src="https://i.imgur.com/luqtM0j.png"/>

#### 2. Share Thoughts/Emotions/Mood
Write down what you think about the quotes or any thoughts with the supportive community!
- Write a post with quotes
> By tapping the button on the bottom-right corner, users can quote the current line and write a post.</br>
> Text recognition is also supported.

<img src="https://i.imgur.com/9ceo2MW.png"/>
<img src="https://i.imgur.com/DSIZfNp.gif"/>

- Responsive News Feed
> Users can like and comment on the posts.
> Each user has their own profile. By following the user, I can brower their latest posts on 探索 tab.

<img src="https://i.imgur.com/JXoDUvJ.png"/>

#### 3. Save Touching Lines
Catch each inspiring moment and write down every single piece of thoughts with the journal feature.</br>

- Write the Touching Lines and Thoughts
> Choose an icon representing current emotion and write down the notes.
> Browse the written notes on list.

<img src="https://i.imgur.com/XimFKmB.gif"/>
<img src="https://i.imgur.com/2yxcOaj.gif"/>

# Technical Highlights
- Programmed Auto Layout with codes for most of the views to make the app compatible for different devices
- Created flexibly reusable UITableviewCell and UICollectionViewCell via nib file
- Designed custom views and managed the views with protocols
- Created custom Tinder-esque swipeable card view with UIPanGestureRecognizer
- Implemented Sign in with Apple and integrated user account into Firebase Auth
- Applied Vision framework to realize text recognition for users to input scanned text through camera and photos
- Established responsive news feed which updates posts data in real time by monitoring data changes through Firebase Snapshot Listener
- Utilized DispatchGroup to ensure data was processed after API calls were executed
- Used Singleton pattern to ensure objects access the single instance of model managers
- Integrated Firestore to manage data, and processed image by Firebase Storage
- Achieved displaying new user guide during first-time launch with UserDefaults by saving a one-time flag
- Detected screenshot behavior on device using NotificationCenter
- Wrote readable, idiomatic and maintainable code using OOP and MVC patterns
- Passed values between View Controllers with delegates and closures
- Integrated Crashlytics to track stability issues effectively

# Release Note
<img src="https://img.shields.io/badge/release-v1.1.8-green"/>

| Version  | Release Date | Note |
|:-------------:|:-------------:|:-------------|
| 1.1.8 | Nov 24 2021 | Fix some minor bugs & add more guide on interface for better experience.
| 1.1.2 | Nov 20 2021 | Add user guide for first-time launch & fix some minor bugs.
| 1.0.0 | Nov 19 2021 | Launch MVP to App Store.

# Requirement
* Xcode 13.0 or any higher version.
* Swift 5.0 or any higher version.
* iOS 13.0 or any higher version.

# Libraries

# Contact

Morgan Yu nihao0705@gmail.com

# License

