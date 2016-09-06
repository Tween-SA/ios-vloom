// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CompanyInfo.swift instead.

import Foundation
import CoreData

public enum CompanyInfoAttributes: String {
    case email = "email"
    case identificationKey = "identificationKey"
    case keywords = "keywords"
    case phone = "phone"
    case type = "type"
    case unsubscribe = "unsubscribe"
    case url = "url"
}

public enum CompanyInfoRelationships: String {
    case company = "company"
    case fromNumbers = "fromNumbers"
    case linkedIn = "linkedIn"
}

public enum CompanyInfoUserInfo: String {
    case remoteKey = "remoteKey"
}

public class _CompanyInfo: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "CompanyInfo"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CompanyInfo.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var email: String?

    @NSManaged public
    var identificationKey: String?

    @NSManaged public
    var keywords: String?

    @NSManaged public
    var phone: String?

    @NSManaged public
    var type: NSNumber?

    @NSManaged public
    var unsubscribe: String?

    @NSManaged public
    var url: String?

    // MARK: - Relationships

    @NSManaged public
    var company: Company?

    @NSManaged public
    var fromNumbers: NSManagedObject?

    @NSManaged public
    var linkedIn: NSManagedObject?

}

