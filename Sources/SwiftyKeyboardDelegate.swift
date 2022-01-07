//
//  SwiftyKeyboardDelegate.swift
//  SwiftyKeyboard
//
//  Created by SwiftyKit on 1/10/22.
//  Copyright © 2021 SwiftyKit. All rights reserved.
//

import Foundation


/// Defines the messages sent to a delegate object as part of the sequence of editing text. All of the methods of this protocol are optional.
@objc public protocol SwiftyKeyboardDelegate : AnyObject {

    /// Asks whether the specified text should be inserted.
    ///
    /// - Parameters:
    ///   - numberKeyboard: The keyboard instance proposing the text insertion.
    ///   - text: The proposed text to be inserted.
    /// - Returns: true if the text should be inserted or false if it should not.
    @objc optional func numberKeyboard(_ numberKeyboard: SwiftyKeyboard, shouldInsertText text: String) -> Bool

    /// Asks the delegate if the keyboard should process the pressing of the return button.
    ///
    /// - Parameter numberKeyboard: The keyboard whose return button was pressed.
    /// - Returns: true if the keyboard should implement its default behavior for the return button; otherwise, false.
    @objc optional func numberKeyboardShouldReturn(_ numberKeyboard: SwiftyKeyboard) -> Bool

    /// Asks the delegate if the keyboard should remove the character just before the cursor.
    ///
    /// - Parameter numberKeyboard: The keyboard whose return button was pressed.
    /// - Returns: true if the keyboard should implement its default behavior for the delete backward button; otherwise, false.
    @objc optional func numberKeyboardShouldDeleteBackward(_ numberKeyboard: SwiftyKeyboard) -> Bool

}
