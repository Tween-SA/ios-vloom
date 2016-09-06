//
//  StringValueTransformer.swift
//  Vloom
//
//  Created by Juan on 2/6/16.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation



@objc(StringValueTransformer)
class StringValueTransformer : NSObject, ValueTransformer {
    
    required override init() {
        super.init()
    }
    
    func convert(sourceValue: AnyObject?) -> AnyObject? {
        
        return sourceValue?.stringValue
        
    }
    
    func revert(sourceValue: AnyObject?) -> AnyObject? {
        
        return "\(sourceValue)"
        
    }
    
}