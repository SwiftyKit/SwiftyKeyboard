//
//  SwiftyKeyboard.swift
//  SwiftyKeyboard
//
//  Created by SwiftyKit on 1/10/22.
//  Copyright © 2021 SwiftyKit. All rights reserved.
//

import UIKit

// check only one decimal point
// keyInput how to set when textField is become first responder

/// A simple keyboard to use with numbers and, optionally, a decimal point.
@available(iOS 9.0, *)
@objcMembers public class SwiftyKeyboard: UIInputView, UIInputViewAudioFeedback {

    // MARK: - UIInputViewAudioFeedback
    private var enableInputClicksWhenVisible: Bool = true

    // MARK: - Constants
    private let keyboardRows                = 4
    private let keyboardColumns             = 4
    private let rowHeight: CGFloat          = 55.0
    private let keyboardPadBorder: CGFloat  = 7.0
    private let keyboardPadSpacing: CGFloat = 8.0

    // MARK: - Public Properties
    /// The receiver key input object. If nil the object at top of the responder chain is used.
    public weak var keyInput: UIKeyInput?

    /// Delegate to change text insertion or return key behavior.
    public weak var delegate: SwiftyKeyboardDelegate?

    private var _allowsDecimalPoint = false {
        didSet {
            // configurate zero number
            self.setNeedsLayout()
        }
    }

    /**
     If true, the decimal separator key will be displayed.
     - note: The default value of this property is **false**.
     */
    public var allowsSpecialKey: Bool {
        get {
            return _allowsSpecialKey
        }
        set {
            guard _allowsSpecialKey != newValue else { return }
            _allowsSpecialKey = newValue
        }
    }

    private var _allowsSpecialKey = false {
        didSet {
            // configurate zero number
            self.setNeedsLayout()
        }
    }

    /**
     If true, the decimal separator key will be displayed.
     - note: The default value of this property is **false**.
     */
    public var allowsDecimalPoint: Bool {
        get {
            return _allowsDecimalPoint
        }
        set {
            guard _allowsDecimalPoint != newValue else { return }
            _allowsDecimalPoint = newValue
        }
    }

    // UIKitLocalizedString(@"Done")
    private lazy var _returnKeyTitle: String = "Done"

    /**
     The visible title of the Return key.
     - note: The default visible title of the Return key is "**Done**".
     */
    public var returnKeyTitle: String {
        get {
            return _returnKeyTitle
        }
        set {
            guard _returnKeyTitle != newValue else { return }
            _returnKeyTitle = newValue

            guard let button = self.buttons[NumberKeyboardButtonType.done.rawValue] else { return }
            button.setTitle(_returnKeyTitle, for: .normal)
        }
    }


    /**
     The button style of the Return key.
     - note: The default value of this property is **NumberKeyboardButtonStyleDone**.
     */
    public var returnKeyButtonStyle: NumberKeyboardButtonStyle = .done


    // MARK: - Private Properties
    lazy private(set) var locale = Locale.current

    private lazy var buttons : [Int: UIButton] = {
        let buttonFont = UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.light)
        let doneButtonFont = UIFont.systemFont(ofSize: 17.0)

        var buttons = [Int: UIButton]()

        let numberMin = NumberKeyboardButtonType.numberMin.rawValue
        let numberMax = NumberKeyboardButtonType.numberMax.rawValue
        for key in numberMin...numberMax {
            let button = SwiftyKeyboardButton(numberKey: String(key), font: buttonFont, target: self, action: #selector(tapKeyNumber(button:)))
            buttons[key] = button
        }

        let backspaceImage = SwiftyKeyboard.keyboardImageNamed("numberKeyboard_delete")?.withRenderingMode(.alwaysTemplate)

        let backspaceButton = SwiftyKeyboardButton(bgImage: backspaceImage, target: self, action: #selector(tapBackspaceKey(button:)))
        backspaceButton.addTarget(self, action: #selector(tapBackspaceRepeat(button:)), forContinuousPress: 0.15)
        buttons[NumberKeyboardButtonType.backspace.rawValue] = backspaceButton

        let dismissImage = SwiftyKeyboard.keyboardImageNamed("numberKeyboard_dismiss")?.withRenderingMode(.alwaysTemplate)
        let specialButton = SwiftyKeyboardButton(bgImage: dismissImage, target: self, action: #selector(tapSpecialKey(button:)))
        buttons[NumberKeyboardButtonType.special.rawValue] = specialButton


        let doneButton = SwiftyKeyboardButton(bgImage: dismissImage, target: self, action: #selector(tapDoneKey(button:)))
        buttons[NumberKeyboardButtonType.done.rawValue] = doneButton

        let decimalPointButton = SwiftyKeyboardButton(decimalPoint: ".", font: buttonFont, target: self, action: #selector(tapDecimalPointKey(button:)))
        buttons[NumberKeyboardButtonType.decimalPoint.rawValue] = decimalPointButton

        for (_, button) in buttons {
            button.isExclusiveTouch = true
            button.addTarget(self, action: #selector(playClick(button:)), for: .touchDown)
            button.layer.cornerRadius = 5.0
        }

        return buttons
    }()

    /// Initialize an array for the separators.
    private lazy var separatorViews : [UIView] = {
        var separatorViews = [UIView]()
        var numberOfSeparators = self.keyboardColumns + self.keyboardRows - 1

        for index in 0..<numberOfSeparators {
            let separator = UIView(frame: CGRect.zero)
            separator.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
            separatorViews.append(separator)
        }

        return separatorViews
    }()

    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
        Initializes and returns a number keyboard view using the specified style information and locale.
     
        An initialized view object or nil if the view could not be initialized.
        - parameters:
            - frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it.
            - inputViewStyle: The style to use when altering the appearance of the view and its subviews. For a list of possible values, see **UIInputViewStyle**
            - locale: An **Locale** object that specifies options (specifically the **LocaleDecimalSeparator**) used for the keyboard. Specify nil if you want to use the current locale.

     */
    convenience init(frame: CGRect, inputViewStyle: UIInputView.Style, locale: Locale) {
        self.init(frame: frame, inputViewStyle: inputViewStyle)
        self.locale = locale
    }

    override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        self.initialSetup()
    }

    // MARK: - Accessing keyboard images.
    private class func keyboardImageNamed(_ imageName: String) -> UIImage? {
        let imageExtension = "png"

        var image : UIImage?
        let bundle = Bundle(for: SwiftyKeyboard.self)
        if let imagePath = bundle.path(forResource: imageName, ofType: imageExtension) {
            image = UIImage(contentsOfFile: imagePath)
        }
        else {
            image = UIImage(named: imageName)
        }

        return image
    }

    func initialSetup() {

        for (_, button) in self.buttons {
            self.addSubview(button)
        }

        if UI_USER_INTERFACE_IDIOM() == .phone {
            for separatorView in self.separatorViews {
                self.addSubview(separatorView)
            }
        }

        let highlightGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleHighlight(gestureRecognizer:)))
        self.addGestureRecognizer(highlightGestureRecognizer)

        // Size to fit.
        self.sizeToFit()
    }

    // MARK: -
    /**
        Configures the special key with an image and an action block.
        - parameters:
            - image: The image to display in the key.
            - handler: A handler block.
     */
    func configureSpecialKey(image: UIImage?, actionHandler handler: ()->()) {
//        if (image) {
//            self.specialKeyHandler = handler
//        } else {
//            self.specialKeyHandler = NULL
//        }

        guard let button = self.buttons[NumberKeyboardButtonType.special.rawValue] else { return }
        button.setImage(image, for: .normal)
    }

    // MARK: - Handle pan gesture
    func handleHighlight(gestureRecognizer : UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)

        guard gestureRecognizer.state == .changed || gestureRecognizer.state == .ended else { return }

        for (_, button) in self.buttons {
            let points = button.frame.contains(point) && !button.isHidden

            if gestureRecognizer.state == .changed {
                button.isHighlighted = points
            }
            else {
                button.isHighlighted = false
            }

            if gestureRecognizer.state == .ended && points {
                button.sendActions(for: .touchUpInside)
            }
        }
    }

    // MARK: - Handle Actions
    func playClick(button: SwiftyKeyboardButton) {
        UIDevice.current.playInputClick()
    }

    func tapKeyNumber(button: SwiftyKeyboardButton) {
        guard self.buttons.values.contains(button) else { return }

        // Get first responder.
        guard let keyInput = self.keyInput else { return }
        guard let title = button.title(for: .normal) else { return }

        // Handle number.
        if shouldChangeCharacter(for: title) {
            keyInput.insertText(title)
        }
    }

    func tapSpecialKey(button: SwiftyKeyboardButton) {
        guard self.buttons.values.contains(button) else { return }
        self.dismissKeyboard()
    }

    func tapDecimalPointKey(button: SwiftyKeyboardButton) {
        guard self.buttons.values.contains(button) else { return }

        // Get first responder.
        guard let keyInput = self.keyInput else { return }
        guard let decimalText = button.title(for: .normal) else { return }

        // Handle decimal point.
        if shouldChangeCharacter(for: decimalText) {
            keyInput.insertText(decimalText)
        }
    }

    func tapBackspaceKey(button: SwiftyKeyboardButton) {
        guard self.buttons.values.contains(button) else { return }

        // Get first responder.
        guard let keyInput = self.keyInput else { return }

        // Handle backspace.
        if let shouldDeleteBackward = self.delegate?.numberKeyboardShouldDeleteBackward?(self) {
            guard shouldDeleteBackward == true else { return }
        }

        keyInput.deleteBackward()
    }

    func tapDoneKey(button: SwiftyKeyboardButton) {
        guard self.buttons.values.contains(button) else { return }

        // Handle done.
        if let shouldReturn = self.delegate?.numberKeyboardShouldReturn?(self) {
            guard shouldReturn == true else { return }
        }

        self.dismissKeyboard()
    }

    func tapBackspaceRepeat(button: SwiftyKeyboardButton) {
        guard self.buttons.values.contains(button) else { return }

        // Get first responder.
        guard let keyInput = self.keyInput else { return }
        guard keyInput.hasText else { return }

        self.playClick(button: button)
        self.tapBackspaceKey(button: button)
    }

    private func shouldChangeCharacter(for text: String) -> Bool {
        guard let keyInput = self.keyInput else { return false}
        if let shouldInsert = self.delegate?.numberKeyboard?(self, shouldInsertText: text), shouldInsert == true{
            return true
        }

        if keyInput.isKind(of: UITextField.self), let textField = keyInput as? UITextField {
            //let range = NSRange(location: textField.selectedTextRange?.start ?? UITextPosition, length: 1)
            if let selectedRange = textField.selectedRange {
                let shouldInsert = textField.delegate?.textField?(textField, shouldChangeCharactersIn: selectedRange, replacementString: text) ?? true
                return shouldInsert
            }
        }

        return false
    }

    // MARK: -
    func dismissKeyboard() {
        guard let keyInput = self.keyInput as? UIResponder else { return }
        keyInput.resignFirstResponder()
    }

    // MARK: - Layout
    @inline(__always) func convertButtonRect(rect: CGRect, contentOrigin: CGPoint, interfaceIdiom: UIUserInterfaceIdiom) -> CGRect {
        var newRect = rect.offsetBy(dx: contentOrigin.x, dy: contentOrigin.y)

        if interfaceIdiom == .pad {
            let inset : CGFloat = self.keyboardPadSpacing / 2.0
            newRect = newRect.insetBy(dx: inset, dy: inset)
        }

        return newRect
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let buttons = self.buttons

        let bounds = self.bounds

        // Settings.
        let interfaceIdiom = UI_USER_INTERFACE_IDIOM()
        let spacing : CGFloat = (interfaceIdiom == .pad) ? self.keyboardPadBorder : 0.0
        let allowsDecimalPoint = self.allowsDecimalPoint

        let width = bounds.width - spacing * 2
        let contentRect = CGRect(x: round(bounds.width - width) / 2.0,
                                 y: spacing,
                                 width: width,
                                 height: (bounds.height - spacing * 2.0))

        // Layout.

        var columnWidth = contentRect.width / 4.0
        let utilityColumnWidth  = columnWidth / 2.0
        if interfaceIdiom == .pad {
            columnWidth = (contentRect.width - utilityColumnWidth) / 3.0
        }
        let rowHeight = self.rowHeight

        let numberSize = CGSize(width: columnWidth, height: rowHeight)

        // Layout numbers.
        let numberMin = NumberKeyboardButtonType.numberMin.rawValue
        let numberMax = NumberKeyboardButtonType.numberMax.rawValue
        let numbersPerLine = 3

        for key in numberMin...numberMax {
            let button = buttons[key]

            let digit = key - numberMin

            var rect = CGRect(origin: CGPoint.zero, size: numberSize)

            if digit == 0 {
                rect.origin.y = numberSize.height * 3
                rect.origin.x = numberSize.width

                if !allowsDecimalPoint {
                    rect.size.width += numberSize.width
                }
            }
            else {
                let idx = digit - 1

                let line = idx / numbersPerLine
                let pos = idx % numbersPerLine

                rect.origin.y = CGFloat(line) * numberSize.height
                rect.origin.x = CGFloat(pos) * numberSize.width
            }

            button?.frame = self.convertButtonRect(rect: rect, contentOrigin: contentRect.origin, interfaceIdiom: interfaceIdiom)
        }

        // Layout special key.
        if let specialKey = buttons[NumberKeyboardButtonType.special.rawValue] {
            var rect = CGRect(origin: CGPoint.zero, size: numberSize)
            rect.origin.y = numberSize.height * 3

            specialKey.frame = self.convertButtonRect(rect: rect, contentOrigin: contentRect.origin, interfaceIdiom: interfaceIdiom)
            specialKey.isHidden = !allowsSpecialKey
        }

        // Layout decimal point.
        if let decimalPointKey = buttons[NumberKeyboardButtonType.decimalPoint.rawValue] {
            var rect = CGRect(origin: CGPoint.zero, size: numberSize)
            rect.origin.x = numberSize.width * 2
            rect.origin.y = numberSize.height * 3

            decimalPointKey.frame = self.convertButtonRect(rect: rect, contentOrigin: contentRect.origin, interfaceIdiom: interfaceIdiom)
            decimalPointKey.isHidden = !allowsDecimalPoint
        }

        // Layout utility column.
        let utilityButtonKeys = [NumberKeyboardButtonType.backspace.rawValue, NumberKeyboardButtonType.done.rawValue]
        let utilitySize = CGSize(width: interfaceIdiom == .pad ? utilityColumnWidth : columnWidth, height: rowHeight * 2.0)

        for (index, key) in utilityButtonKeys.enumerated() {
            let button = buttons[key]
            var rect = CGRect(origin: CGPoint.zero, size: utilitySize)
            rect.origin.x = columnWidth * 3.0
            rect.origin.y = CGFloat(index) * utilitySize.height
            button?.frame = self.convertButtonRect(rect: rect, contentOrigin: contentRect.origin, interfaceIdiom: interfaceIdiom)
        }

        // Layout separators if phone.
        if interfaceIdiom == .phone {
            self.layoutSeparators(separators: self.separatorViews, contentRect: contentRect, columnWidth: columnWidth)
        }
    }

    func layoutSeparators(separators: [UIView], contentRect: CGRect, columnWidth: CGFloat) {
        var scale : CGFloat = 1.0
        if let window = self.window {
            scale = window.screen.scale
        }
        let separatorDimension : CGFloat = 1.0 / scale

        let totalRows = self.keyboardRows

        for (index, separator) in separators.enumerated() {
            var rect = CGRect.zero

            if index < totalRows {
                rect.origin.y = CGFloat(index) * rowHeight

                if index % 2 == 1 {
                    // to not cross backspace and done buttons
                    rect.size.width = contentRect.width - CGFloat(columnWidth)
                }
                else {
                    rect.size.width = contentRect.width
                }

                rect.size.height = separatorDimension
            }
            else {
                let columnIndex = index - totalRows

                rect.origin.x = CGFloat(columnIndex + 1) * columnWidth
                rect.size.width = separatorDimension

                if columnIndex == 1, !self.allowsDecimalPoint {
                    rect.size.height = contentRect.height - rowHeight
                }
                else if columnIndex == 0, !self.allowsSpecialKey {
                    rect.size.height = contentRect.height - rowHeight
                }
                else {
                    rect.size.height = contentRect.height
                }
            }

            separator.frame = self.convertButtonRect(rect: rect, contentOrigin: contentRect.origin, interfaceIdiom: .phone)
        }
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let interfaceIdiom = UI_USER_INTERFACE_IDIOM()
        let spacing = (interfaceIdiom == .pad) ? self.keyboardPadBorder : 0.0

        var newSize = size
        newSize.height = self.rowHeight * CGFloat(self.keyboardRows) + spacing * 2.0

        if (newSize.width == 0.0) {
            newSize.width = UIScreen.main.bounds.size.width
        }

        return newSize
    }
}


extension UITextInput {
    var selectedRange: NSRange? {
        guard let range = selectedTextRange else { return nil }
        let location = offset(from: beginningOfDocument, to: range.start)
        let length = offset(from: range.start, to: range.end)
        return NSRange(location: location, length: length)
    }
}
