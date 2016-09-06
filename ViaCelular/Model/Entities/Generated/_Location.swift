// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Location.swift instead.

import Foundation
import CoreData

public enum LocationAttributes: String {
    case city = "city"
    case country = "country"
    case countryCode = "countryCode"
    case lat = "lat"
    case lon = "lon"
}

public enum LocationUserInfo: String {
    case singleton = "singleton"
}

public class _Location: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Location"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Location.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var city: String?

    @NSManaged public
    var country: String?

    @NSManaged public
    var countryCode: String?

    @NSManaged public
    var lat: NSNumber?

    @NSManaged public
    var lon: NSNumber?

    // MARK: - Relationships

}

