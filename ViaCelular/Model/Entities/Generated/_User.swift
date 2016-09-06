// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.swift instead.

import Foundation
import CoreData

public enum UserAttributes: String {
    case gcmId = "gcmId"
    case id = "id"
    case isCurrent = "isCurrent"
    case phone = "phone"
}

public enum UserRelationships: String {
    case country = "country"
    case info = "info"
}

public class _User: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "User"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _User.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var gcmId: String?

    @NSManaged public
    var id: String?

    @NSManaged public
    var isCurrent: NSNumber?

    @NSManaged public
    var phone: String?

    // MARK: - Relationships

    @NSManaged public
    var country: Country?

    @NSManaged public
    var info: UserInfo?

}

