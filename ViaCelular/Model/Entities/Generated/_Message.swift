// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.swift instead.

import Foundation
import CoreData

public enum MessageAttributes: String {
    case areaCode = "areaCode"
    case channel = "channel"
    case companyId = "companyId"
    case countryCode = "countryCode"
    case created = "created"
    case deliveryMecanism = "deliveryMecanism"
    case erase = "erase"
    case flags = "flags"
    case gcmId = "gcmId"
    case id = "id"
    case msgId = "msgId"
    case payload = "payload"
    case phone = "phone"
    case status = "status"
    case trace = "trace"
    case ttd = "ttd"
    case type = "type"
    case user = "user"
}

public enum MessageRelationships: String {
    case timestamp = "timestamp"
}

public class _Message: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Message"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Message.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var areaCode: String?

    @NSManaged public
    var channel: String?

    @NSManaged public
    var companyId: String?

    @NSManaged public
    var countryCode: String?

    @NSManaged public
    var created: NSNumber?

    @NSManaged public
    var deliveryMecanism: String?

    @NSManaged public
    var erase: NSNumber?

    @NSManaged public
    var flags: String?

    @NSManaged public
    var gcmId: String?

    @NSManaged public
    var id: String?

    @NSManaged public
    var msgId: String?

    @NSManaged public
    var payload: String?

    @NSManaged public
    var phone: String?

    @NSManaged public
    var status: NSNumber?

    @NSManaged public
    var trace: String?

    @NSManaged public
    var ttd: NSNumber?

    @NSManaged public
    var type: String?

    @NSManaged public
    var user: String?

    // MARK: - Relationships

    @NSManaged public
    var timestamp: MessageTimestamp?

}

