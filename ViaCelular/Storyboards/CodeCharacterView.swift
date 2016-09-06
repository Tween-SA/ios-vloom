//
//  CodeCharacterView.swift
//  Vloom
//
//  Created by Mariano on 13/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CodeCharacterView : UIControl {
    
    @IBOutlet weak var dashLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    var text: String? {
        didSet {
            self.dashLabel.hidden = (self.text != nil)
            self.textLabel.hidden = !self.dashLabel.hidden
            self.textLabel.text = self.text
        }
    }
    
    //MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupXib()
    }
    
}