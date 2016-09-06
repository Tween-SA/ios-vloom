//
//  NumberValueTransformer.swift
//  Vloom
//
//  Created by Mariano on 12/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation

@objc(NumberValueTransformer)
class NumberValueTransformer : NSObject, ValueTransformer {
    
    required override init() {
        super.init()
    }
    
    func convert(sourceValue: AnyObject?) -> AnyObject? {
        
        return Int(sourceValue as! String)
        
    }
    
    func revert(sourceValue: AnyObject?) -> AnyObject? {
        
        return "\(sourceValue)"
        
    }
    
}