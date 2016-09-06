//
//  CodeInputView.swift
//  Vloom
//
//  Created by Mariano on 13/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CodeInputView : UIControl, UIKeyInput, UITextInputTraits {
    
    @IBOutlet var characterViews: [CodeCharacterView]!
    
    //MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupXib()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sortByTag(self.characterViews)
    }
    
    @IBAction func onTap() {
        self.becomeFirstResponder()
    }
    
    //MARK: - UIKeyInput implementation
    
    func hasText() -> Bool {
        return self.code.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
    }
    
    func insertText(text: String) {
        if self.code.characters.count < 4
        {
            self.code += text
        }
    }
    
    func deleteBackward() {
        self.code = String(self.code.characters.dropLast(1))
    }
    
    //MARK: - UITextInputTraits implementation
    
    var keyboardType: UIKeyboardType {
        get {
            return .NumberPad
        }
        set (value) {
            
        }
    }
    
    func reset() {
        self.code = ""
    }
    
    private func update() {
        for charView in self.characterViews {
            if (charView.tag < self.code.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)) {
                let startIndex = self.code.startIndex.advancedBy(charView.tag)
                let endIndex = startIndex.advancedBy(1)
                charView.text = self.code.substringWithRange(Range(start:startIndex, end:endIndex))
            } else {
                charView.text = nil
            }
        }
        self.sendActionsForControlEvents(.ValueChanged)
    }
    
    var code: String = "" {
        
        didSet {
            
            self.update()
            
        }
        
    }
    
    var isFilled: Bool {
        get {
            return self.code.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == self.characterViews.count
        }
    }
    
}