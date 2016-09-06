//
//  Mapping.swift
//  Vloom
//
//  Created by Mariano on 3/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import CoreData
import MagicalRecord

/// Convenience typealias for the tuple that forms the rules needed for mapping
typealias Mapping = (ObjectKey, ObjectType)

typealias MappingResults = [AnyObject?]

/// Determines the object to be mapped
enum ObjectType {
    
    /// Gets the raw value
    case Value
    
    /// Gets the raw value, then transforms it using a value transformer
    case Transform(ValueTransformer)
    
    /// Gets the dictionary and converts it into a local domain object using a NSManagedObject type
    case Object(NSManagedObject.Type)
    
    /// Gets the array and converts it into a list of local domain objects using a NSManagedObject type
    case Array(NSManagedObject.Type)
    
    case ObjectUpdate(NSManagedObject)
    
    case ArrayUpdate([NSManagedObject])
    
}

/// Determines where to read the value from
enum ObjectKey {
    
    /// Gets the root value/object
    case Root
    
    /// Gets the value at a given path
    case Path(String)
    
}

infix operator => {}

/// Convenience operator to create a mapping tuple to make it less verbose
func =>(left: ObjectKey, right: ObjectType) -> Mapping {
    return (left, right)
}

protocol Mapper {
    
    func map(object: AnyObject?, mapping: [Mapping], completion: ((results: MappingResults) -> Void)?)
    
}

class ObjectMapper : NSObject, Mapper {
    
    /// - description Maps an object/s into local domain object/s following the rules specified by the mapping
    /// - parameter object: The object expected to be mapped. Must be either an array or dictionary
    /// - parameter mapping: A list of mapping definitions that will be used in order to determine which objects must be mapped
    /// - parameter completion: An optional block to be called once mapping and saving completes. The mapping results are passed as an argument
    
    func map(object: AnyObject?, mapping: [Mapping], completion: ((results: MappingResults) -> Void)? = nil) {
        
        var results = [AnyObject?]()
        
        let importBlock: (NSManagedObjectContext?) -> Void = { context in
            
            for (objectKey, objectType) in mapping {
                
                var objectToMap: AnyObject?
                
                switch (objectKey) {
                    
                case .Root:
                    
                    objectToMap = object
                    
                case .Path(let keyPath):
                    
                    objectToMap = (object as? NSDictionary)?.valueForKeyPath(keyPath)
                    
                }
                
                switch (objectType) {
                    
                case .Value:
                    
                    results.append(objectToMap)
                    
                case .Transform(let transformer):
                    
                    results.append(transformer.convert(objectToMap))
                    
                case .Object(let objectType):
                    
                    results.append(context?.importObject(objectToMap as? NSDictionary, type: objectType))
                    
                case .Array(let objectsType):
                    
                    results.append(context?.importObjects(objectToMap as? NSArray, type: objectsType))
                    
                case .ObjectUpdate(let objectToUpdate):
                    
                    results.append(context?.updateObject(objectToMap as? NSDictionary, object: objectToUpdate))
                    
                case .ArrayUpdate(let objectsToUpdate):
                    
                    results.append(context?.updateObjects(objectToMap as? NSArray, objects: objectsToUpdate))
                    
                }
                
            }
            
        }

    
        
        MagicalRecord.saveWithBlock({ (context) in
                // This import is performed in a new temporal context in a background thread
                importBlock(context)
            }) { (success, error) in
                
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    
                    // in this background I restore from the main context, the coradata objects created in the temporal context
                    
                    var resultInDefaultContext:[AnyObject?] = []
                    
                    for result in results {
                        
                        if result is [AnyObject] {
                            var subResult:[NSManagedObject] = []
                            
                            for obj in result as! [NSManagedObject] {
                                subResult.insert(obj.MR_inContext(NSManagedObjectContext.MR_defaultContext()) as! NSManagedObject,
                                    atIndex: subResult.count)
                            }
                            resultInDefaultContext.insert(subResult, atIndex: resultInDefaultContext.count)
                            
                        }else if result is NSDictionary {
                            resultInDefaultContext.insert(result, atIndex: resultInDefaultContext.count)
                        }else if result != nil {
                            resultInDefaultContext.insert(result!.MR_inContext(NSManagedObjectContext.MR_defaultContext()) as! NSManagedObject,
                                atIndex: resultInDefaultContext.count)
                        }
                        
                    } 
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        // report in the main thread
                        completion?(results: resultInDefaultContext)
                   })
                })
                
        }
    }
    
    
}