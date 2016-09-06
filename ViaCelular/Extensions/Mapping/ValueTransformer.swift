//
//  ValueTransformer.swift
//  Vloom
//
//  Created by Mariano on 19/11/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import CoreData

protocol ValueTransformer {
    
    init()
    func convert(sourceValue: AnyObject?) -> AnyObject?
    func revert(sourceValue: AnyObject?) -> AnyObject?
    
}

@objc(DateTransformer)
class DateTransformer : NSObject, ValueTransformer {
    
    var dateFormat: String = "yyyy-MM-dd'T'hh:mm:ss'Z'"
    
    required override init() {
        super.init()
    }
    
    init(dateFormat: String) {
        self.dateFormat = dateFormat
    }
    
    func convert(sourceValue: AnyObject?) -> AnyObject? {
        return nil
    }
    
    func revert(sourceValue: AnyObject?) -> AnyObject? {
        return nil
    }
    
}