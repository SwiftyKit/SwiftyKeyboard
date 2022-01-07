//
//  SwiftyKeyboardButton+Styles.swift
//  SwiftyKeyboardExample
//
//  Created by SwiftyKit on 1/10/22.
//  Copyright © 2021 SwiftyKit. All rights reserved.
//

import Foundation
import UIKit

extension SwiftyKeyboardButton {

    convenience init(numberKey title: String, font: UIFont, target: Any?, action: Selector) {
        self.init(style: .white)
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = font
        self.addTarget(target, action: action, for: .touchUpInside)
    }

    convenience init(doneKeyTitle title: String, font: UIFont, target: Any?, action: Selector) {
        self.init(style: .done)
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = font
        self.addTarget(target, action: action, for: .touchUpInside)
    }

    convenience init(bgImage image: UIImage?, target: Any?, action: Selector) {
        self.init(style: .gray)
        self.addTarget(target, action: action, for: .touchUpInside)
        self.setImage(image, for: .normal)
    }

    convenience init(decimalPoint point: String, font: UIFont, target: Any?, action: Selector) {
        self.init(style: .white)
        self.setTitle(point, for: .normal)
        self.titleLabel?.font = font
        self.addTarget(target, action: action, for: .touchUpInside)
    }
}
