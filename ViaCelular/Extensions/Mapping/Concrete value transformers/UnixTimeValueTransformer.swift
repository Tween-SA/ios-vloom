//
//  UnixTimeValueTransformer.swift
//  Vloom
//
//  Created by Mariano on 5/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation

@objc(UnixTimeValueTransformer)
class UnixTimeValueTransformer : NSObject, ValueTransformer {
    
    required override init() {
        super.init()
    }
    
    func convert(sourceValue: AnyObject?) -> AnyObject? {

        guard let timestamp = sourceValue as? NSTimeInterval else {
            return nil
        }
        
        return NSDate(timeIntervalSince1970: timestamp)
        
    }
    
    func revert(sourceValue: AnyObject?) -> AnyObject? {
        
        guard let date = sourceValue as? NSDate else {
            return nil
        }
        
        return date.timeIntervalSince1970
        
    }
    
}