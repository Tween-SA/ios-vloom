//
//  Vloom
//
//  Created by Mariano on 21/11/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func importObject(object: NSDictionary?, type: NSManagedObject.Type) -> NSManagedObject? {
        return self.importObject(object, type: NSStringFromClass(type))
    }
    
    func updateObject(dict: AnyObject?, object: NSManagedObject, context: NSManagedObjectContext? = nil) -> NSManagedObject {
        
        //Ensure dictionary is not null
        guard let dict = dict as? NSDictionary else {
            print("Unable to update object because of null dictionary \(object)")
            return object
        }
        
        //Get a reference to the entity
        let entity = object.entity
        
        for (attributeName, attribute) in entity.attributesByName {
            
            guard let allKeys = dict.allKeys as? [String] where allKeys.contains(attribute.remoteKey) else {
                continue
            }

            if let local = attribute.userInfo!["localdata"] as? String{
                if local == "true" {
                    print("\(attribute.remoteKey): \(object.valueForKeyPath(attribute.remoteKey))")
                    continue
                }
            }
            //Convert the value and set it to the instance
            let value = dict.valueForKeyPath(attribute.remoteKey)
            object.setValue(attribute.convert(value), forKey: attributeName)
            
        }
        
        //For each relationship...
        for (relationshipName, relationship) in entity.relationshipsByName {
            
            guard let allKeys = dict.allKeys as? [String] where allKeys.contains(relationship.remoteKey) else {
                continue
            }
            
            //This is the value that will be set
            var valueToSet: AnyObject?
            
            //To many...
            if (relationship.toMany) {
                
                //Check if value exists...
                if let value = dict.valueForKeyPath(relationship.remoteKey) as? [NSDictionary] {
                    
                    //Ensure objects are mapped
                    guard let objects = self.importObjects(value, type: relationship.destinationEntity!.name!, context: object.managedObjectContext) else {
                        print("Warning: unable to map array of objects \(value)")
                        continue
                    }
                    
                    //Check if it is ordered in order to create the proper set
                    if relationship.ordered {
                        
                        valueToSet = NSOrderedSet(array: objects)
                        
                    } else {
                        
                        valueToSet = NSSet(array: objects)
                        
                    }
                    
                } else {
                    
                    //No value existed, so create an empty set
                    valueToSet = NSSet(array: [])
                    
                }
                
            } else {
                
                //Check if value exists
                if let value = dict.valueForKeyPath(relationship.remoteKey) as? NSDictionary {
                    
                    //Ensure object is mapped
                    guard let object = self.importObject(value, type: relationship.destinationEntity!.name!, context: object.managedObjectContext) else {
                        print("Warning: unable to map object \(value)")
                        continue
                    }
                    
                    //Update value to set with the mapped object
                    valueToSet = object
                    
                }
                
            }
            
            //Finally, set the value for the corresponding key
            object.setValue(valueToSet, forKey: relationshipName)
            
        }
        
        return object
        
    }
    
    func importObjects(array: AnyObject?, type: NSManagedObject.Type) -> [NSManagedObject]? {
        return self.importObjects(array as? NSArray, type: NSStringFromClass(type))
    }
    
    func updateObjects(array: AnyObject?, var objects: [NSManagedObject], context: NSManagedObjectContext? = nil) -> [NSManagedObject] {
        
        guard let array = array as? NSArray else {
            print("Warning: unable to parse array of objects")
            return objects
        }
        
        for (index, object) in objects.enumerate() {
            
            objects[index] = self.updateObject(array[index] as? NSDictionary, object: object)
            
        }
        
        return objects
        
    }
    
    private func importObject(dict: NSDictionary?, type: String, context: NSManagedObjectContext? = nil) -> NSManagedObject? {
        
        //Ensure the object to be mapped isn't nil
        guard let dict = dict else {
            print("Warning: unable to convert dictionary because it is null")
            return nil
        }
        
        guard let entityClass = NSClassFromString(type) as? NSManagedObject.Type else {
            print("Warning: unable to get entity class")
            return nil
        }
        
        if (entityClass.canImport(dict) == false) {
            return nil
        }
        
        let contextToUse = (context == nil) ? self : context!
        
        //Ensure there's an entity for the given type
        guard let entity = NSEntityDescription.entityForName(type, inManagedObjectContext: contextToUse) else {
            print("Warning: Unable to convert dictionary because of null entity \(dict)")
            return nil
        }
        
        //Check required properties are present. If not there will be no further processing on this object
        for (_, property) in entity.propertiesByName {
            
            if (property.isRequired && dict.allKeys.contains({ (obj) -> Bool in
                return (obj as! String) == property.remoteKey
            }) == false) {
                return nil
            }
            
        }
        
        //Make sure to remove all instances of the same entity if it's a singleton
        if (entity.isSingleton) {
            
            let fetchRequest = NSFetchRequest(entityName: entity.name!)
            
            do {
                
                let instances = try contextToUse.executeFetchRequest(fetchRequest) as! [NSManagedObject]

                for instance in instances {
                    
                    contextToUse.deleteObject(instance)
                    
                }
                
            } catch {
                
            }
            
        }
        
        //Build up the sub-predicates to get an existing instance
        var primaryKeyPredicates = [NSPredicate]()
        
        //For each attribute...
        for (attributeName, attribute) in entity.attributesByName {
            
            if (attribute.isPrimaryKey) {
                
                guard let value = attribute.convert(dict[attribute.remoteKey]) else {
                    
                    return nil
                    
                }
            
                //Create the sub-predicate that compares the attribute against the value given in the object to be mapped
                let predicate = NSPredicate(format: "%K == %@", argumentArray: [attributeName, value])
                
                //Append the predicate created above
                primaryKeyPredicates.append(predicate)
                
            }
            
        }
        
        //This is the instance that will either be updated or inserted
        var instance: NSManagedObject!
        
        //If we have some sub-predicates to build a compound predicate...
        if (primaryKeyPredicates.count > 0) {
            
            //Create a compound predicate to try fetching an existing instance
            let keyPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: primaryKeyPredicates)
            
            //Create the fetch request and set its predicate to the compound predicate created above
            let fetchRequest = NSFetchRequest(entityName: entity.name!)
            fetchRequest.predicate = keyPredicate
            
            //Perform the fetch
            do {
                
                //Get the list of objects matching this predicate. Ideally, we should always get one or none
                let objects = try contextToUse.executeFetchRequest(fetchRequest)

                //Get the first instance (if any)
                instance = objects.first as? NSManagedObject
                
                //If we found more than one instance, print a warning. This states that something went wrong
                if objects.count > 1 {
                    print("Warning: more than one object returned, only one was expected")
                }
                
            } catch {
                
            }
            
        }
        
        //If there weren't any existing instance, then create one
        if (instance == nil) {
            
            instance = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: contextToUse)
            
        }
        
        //Update the object with the data coming in the dict
        return self.updateObject(dict, object: instance)
    }
    
    private func importObjects(array: NSArray?, type: String, context: NSManagedObjectContext? = nil) -> [NSManagedObject]? {
        
        guard let array = array else {
            return nil
        }
        
        var convertedObjects = [NSManagedObject]()
        
        for element in array {
            
            guard let dict = element as? NSDictionary else {
                continue
            }
            
            guard let convertedObject = self.importObject(dict, type: type) else {
                continue
            }
            
            convertedObjects.append(convertedObject)
            
        }
        
        return convertedObjects
        
    }
    
}

extension NSManagedObject {
    
    static func canImport(src: NSDictionary) -> Bool {
        
        return true
        
    }
    
    final func export(fields fields: [String]) -> NSDictionary {
        
        //This will be the return value
        let object = NSMutableDictionary(capacity: fields.count)
        
        //For each field...
        for field in fields {
            
            //Act depending on the property type
            let property = self.entity.propertiesByName[field]
            
            if property == nil || property!.exportable == false {
                continue
            }
            
            switch (property) {
                
            //Attribute
            case let attribute as NSAttributeDescription:
                
                //Set the reverted value
                object.setValue(attribute.revert(self.valueForKey(field)), forKey: attribute.exportKey)
                
            //Relationship
            case let relationship as NSRelationshipDescription:
                
                //Many relationship...
                if (relationship.toMany) {

                    //These are the objects that will be converted
                    var objectsToConvert: [NSManagedObject]!
                    
                    //Depending on the set's type, grab a reference to the objects to convert accordingly
                    if (relationship.ordered) {
                        
                        objectsToConvert = (self.valueForKey(field) as? NSOrderedSet)?.array as! [NSManagedObject]
                        
                    } else {
                        
                        objectsToConvert = (self.valueForKey(field) as? NSSet)?.allObjects as! [NSManagedObject]
                        
                    }
                    
                    //Converted objects will be added here
                    var convertedObjects = [NSDictionary]()
                    
                    for objectToConvert in objectsToConvert {
                        
                        convertedObjects.append(objectToConvert.export(includeRelationships: true))
                        
                    }
                    
                    object.setValue(convertedObjects, forKey: relationship.exportKey)

                } else {
                    
                    let childObject = self.valueForKey(field) as? NSManagedObject
                    
                    object.setValue(childObject?.export(includeRelationships: true), forKey: relationship.exportKey)
                    
                }
                
            default:
                continue
                
            }
            
        }
        
        return object
        
    }
    
    final func export(excludeFields excludeFields: [String]) -> NSDictionary {
        
        var fields = [String]()
        
        fields.appendContentsOf(self.entity.attributesByName.keys)
        fields.appendContentsOf(self.entity.relationshipsByName.keys)
        
        for excludeField in excludeFields {
            
            fields.removeAtIndex(fields.indexOf(excludeField)!)
            
        }
        
        return self.export(fields: fields)
    }
    
    final func export(includeRelationships includeRelationships: Bool = false) -> NSDictionary {
        
        var fields = [String]()
        
        fields.appendContentsOf(self.entity.attributesByName.keys)
        
        if (includeRelationships) {
            
            fields.appendContentsOf(self.entity.relationshipsByName.keys)
            
        }
        
        return self.export(fields: fields)
    }
    
}

extension NSEntityDescription {
    
    var isSingleton: Bool {
        
        if let singleton = self.userInfo?["singleton"] as? String where singleton == "true" {
            return true
        } else {
            return false
        }
        
    }
    
    func propertyWithRemoteKey(remoteKey: String) -> NSPropertyDescription? {
        
        for (_, property) in self.propertiesByName {
            
            if (property.remoteKey == remoteKey) {
                return property
            }
            
        }
        
        return nil
        
    }
    
}

extension NSPropertyDescription {
    
    var remoteKey: String {
        get {
            if let remoteKey = self.userInfo?["remoteKey"] as? String {
                return remoteKey
            } else {
                return self.name
            }
        }
    }
    
    var isRequired: Bool {
        get {
            if let required = self.userInfo?["required"] as? String where required == "true" {
                return true
            } else {
                return false
            }
        }
    }
    
    var exportKey: String {
        get {
            if let exportKey = self.userInfo?["exportKey"] as? String {
                return exportKey
            } else {
                return self.remoteKey
            }
        }
    }
    
    var exportable: Bool {
        get {
            if let exportable = self.userInfo?["exportable"] as? String where exportable == "false" {
                return false
            } else {
                return true
            }
        }
    }
    
}

extension NSAttributeDescription {
    
    var isPrimaryKey: Bool {
        get {
            if let primaryKey = self.userInfo?["primaryKey"] as? String where primaryKey == "true" {
                return true
            } else {
                return false
            }
        }
    }
    
    var dateFormat: String? {
        get {
            return self.userInfo?["dateFormat"] as? String
        }
    }
    
    var valueTransformer: ValueTransformer? {
        get {
            guard let transformerClassName = self.userInfo?["transformer"] as? String else {
                return nil
            }

            guard let instClass = NSClassFromString(transformerClassName) as? ValueTransformer.Type else {
                print("Warning: unable to find class for value transformer \(transformerClassName)")
                return nil
            }
            
            return instClass.init()
        }
    }
    
    func convert(srcValue: AnyObject?) -> AnyObject? {
        
        if (srcValue is NSNull) {
            return nil
        }
        
        var value = srcValue
        
        if let dateFormat = self.dateFormat where self.attributeType == .DateAttributeType {
            value = DateTransformer(dateFormat: dateFormat).convert(value)
        } else if let transformer = self.valueTransformer {
            value = transformer.convert(value)
        }
        
        return value
    }
    
    func revert(srcValue: AnyObject?) -> AnyObject? {
        
        if (srcValue == nil) {
            return NSNull()
        }
        
        var value = srcValue
        
        if let dateFormat = self.dateFormat where self.attributeType == .DateAttributeType {
            value = DateTransformer(dateFormat: dateFormat).revert(value)
        } else if let transformer = self.valueTransformer {
            value = transformer.revert(value)
        }
        
        return value
        
    }
    
}