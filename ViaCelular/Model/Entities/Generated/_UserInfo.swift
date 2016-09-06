// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UserInfo.swift instead.

import Foundation
import CoreData

public enum UserInfoAttributes: String {
    case countryCode = "countryCode"
    case email = "email"
    case firstName = "firstName"
    case lastName = "lastName"
    case status = "status"
}

public enum UserInfoRelationships: String {
    case user = "user"
}

public class _UserInfo: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "UserInfo"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _UserInfo.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var countryCode: String?

    @NSManaged public
    var email: String?

    @NSManaged public
    var firstName: String?

    @NSManaged public
    var lastName: String?

    @NSManaged public
    var status: NSNumber?

    // MARK: - Relationships

    @NSManaged public
    var user: User?

}

