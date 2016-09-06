// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Country.swift instead.

import Foundation
import CoreData

public enum CountryAttributes: String {
    case code = "code"
    case isoCode = "isoCode"
    case locales = "locales"
    case name = "name"
    case phoneFormat = "phoneFormat"
    case phoneMaxLength = "phoneMaxLength"
    case phoneMinLength = "phoneMinLength"
}

public enum CountryRelationships: String {
    case user = "user"
}

public class _Country: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Country"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Country.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var code: String?

    @NSManaged public
    var isoCode: String?

    @NSManaged public
    var locales: AnyObject?

    @NSManaged public
    var name: String?

    @NSManaged public
    var phoneFormat: String?

    @NSManaged public
    var phoneMaxLength: NSNumber?

    @NSManaged public
    var phoneMinLength: NSNumber?

    // MARK: - Relationships

    @NSManaged public
    var user: User?

}

