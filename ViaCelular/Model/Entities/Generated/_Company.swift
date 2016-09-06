// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Company.swift instead.

import Foundation
import CoreData

public enum CompanyAttributes: String {
    case blocked = "blocked"
    case colorHex = "colorHex"
    case countryCode = "countryCode"
    case id = "id"
    case imageURL = "imageURL"
    case industry = "industry"
    case industryCode = "industryCode"
    case mute = "mute"
    case name = "name"
    case type = "type"
    case userSuscribe = "userSuscribe"
}

public enum CompanyRelationships: String {
    case employees = "employees"
    case info = "info"
}

public class _Company: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Company"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Company.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var blocked: NSNumber?

    @NSManaged public
    var colorHex: String?

    @NSManaged public
    var countryCode: String?

    @NSManaged public
    var id: String?

    @NSManaged public
    var imageURL: String?

    @NSManaged public
    var industry: String?

    @NSManaged public
    var industryCode: String?

    @NSManaged public
    var mute: NSNumber?

    @NSManaged public
    var name: String?

    @NSManaged public
    var type: NSNumber?

    @NSManaged public
    var userSuscribe: NSNumber?

    // MARK: - Relationships

    @NSManaged public
    var employees: NSOrderedSet

    @NSManaged public
    var info: CompanyInfo?

}

extension _Company {

    func addEmployees(objects: NSOrderedSet) {
        let mutable = self.employees.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.employees = mutable.copy() as! NSOrderedSet
    }

    func removeEmployees(objects: NSOrderedSet) {
        let mutable = self.employees.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.employees = mutable.copy() as! NSOrderedSet
    }

    func addEmployeesObject(value: CompanyEmployee) {
        let mutable = self.employees.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.employees = mutable.copy() as! NSOrderedSet
    }

    func removeEmployeesObject(value: CompanyEmployee) {
        let mutable = self.employees.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.employees = mutable.copy() as! NSOrderedSet
    }

}

