//
//  Utils.swift
//  Vloom
//
//  Created by Mariano on 28/11/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import CoreData
import MagicalRecord

struct Utils {
        
    /// - description Provides a thread-safe way to lock an object and execute a block of code in a thread-safe manner.
    /// - parameter lock: The object that will be locked
    /// - parameter closure: The code of block to execute in a thread-safe manner
    func sync(lock: AnyObject, closure: () -> Void) {
        objc_sync_enter(lock)
        defer { objc_sync_exit(lock) }
        closure()
    }
    
    /// - description Convenience method to take advantage of Swift closures and make a save call less verbose
    /// - parameter saveBlock: A block of code that performs the inserts/updates/deletions on the given context
    static func save(saveBlock: (context: NSManagedObjectContext!) -> Void) {
        MagicalRecord.saveWithBlock(saveBlock)
    }
    
    
    
}