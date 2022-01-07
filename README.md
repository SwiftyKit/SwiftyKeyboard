# SwiftyKeyboard

[![License](https://img.shields.io/:license-mit-blue.svg)](https://doge.mit-license.org)
[![Language](https://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift)

## Overview

SwiftyKeyboard is an iOS customized enhanced keyboard. This keyboard view is intended to replace the default keyboard on iPhone/iPad for entering numerical values. As the default keyboard on iPad still shows all keys even for numerical entry modes, this keyboard only focuses on numeric keys.

And it supports customize the UI of keys, and the positions etc. In the other word, SwiftyKeyboard is a full customized numeric keyboard for iOS.



iPad ScreenShot:

![enter image description here](https://github.com/SwiftyKit/SwiftyKeyboard/raw/master/Images/shot1.gif)



iPhone ScreenShot:

![enter image description here](https://github.com/SwiftyKit/SwiftyKeyboard/raw/master/Images/shot2.gif)

 
## Installation
 
### CocoaPods 

SwiftyKeyboard is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftyKeyboard'
```

### Manual

Drag 'n drop SwiftyTextView.swift into your project.
 

## Usage 

 
```swift
        let numbericKeyboard = SwiftyKeyboard(frame: CGRect.zero)
        yourTextField.inputView = numbericKeyboard  // yourTextField is the pre defined textField
        numbericKeyboard.keyInput = yourTextField
        numbericKeyboard.delegate = self
        numbericKeyboard.allowsDecimalPoint = true  // can set the true of false
```

## Requirements
- Swift 5.0+
- iOS 10.0+

## Contact & Contribute

 - Feel free to contact me with ideas or suggestions at swiftykit@gmail.com
 - Fork the project and make your own changes

 
## License

SwiftyTextView is available under the MIT license. See the LICENSE file for more info.
