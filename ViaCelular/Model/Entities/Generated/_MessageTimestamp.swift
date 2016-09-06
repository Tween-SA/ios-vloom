// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MessageTimestamp.swift instead.

import Foundation
import CoreData

public enum MessageTimestampAttributes: String {
    case acknowledged = "acknowledged"
    case created = "created"
    case delivered = "delivered"
    case processing = "processing"
    case received = "received"
}

public enum MessageTimestampRelationships: String {
    case message = "message"
}

public enum MessageTimestampUserInfo: String {
    case transformer = "transformer"
}

public class _MessageTimestamp: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "MessageTimestamp"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _MessageTimestamp.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var acknowledged: NSDate?

    @NSManaged public
    var created: NSDate?

    @NSManaged public
    var delivered: NSDate?

    @NSManaged public
    var processing: NSDate?

    @NSManaged public
    var received: NSDate?

    // MARK: - Relationships

    @NSManaged public
    var message: Message?

}

