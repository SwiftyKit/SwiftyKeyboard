//
//  ViewController.swift
//  Demo
//
//  Created by SiwftyKit on 2022/1/6.
//  Copyright © 2022 apple. All rights reserved.
//

import UIKit
import SwiftyKeyboard

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 1.0

        let numbericKeyboard = SwiftyKeyboard(frame: CGRect.zero)
        textField.inputView = numbericKeyboard
        numbericKeyboard.keyInput = textField
        numbericKeyboard.delegate = self
        numbericKeyboard.allowsDecimalPoint = true
        
        let numbericKeyboard2 = SwiftyKeyboard(frame: CGRect.zero)
        textView.inputView = numbericKeyboard2
        numbericKeyboard2.keyInput = textView
        numbericKeyboard2.delegate = self
        numbericKeyboard2.allowsDecimalPoint = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeKeyboard() {
        self.view.endEditing(true)
    }
}

extension ViewController: SwiftyKeyboardDelegate {
    func numberKeyboard(_ numberKeyboard: SwiftyKeyboard, shouldInsertText text: String) -> Bool {
        return true
    }
}

