// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CompanyEmployee.swift instead.

import Foundation
import CoreData

public enum CompanyEmployeeAttributes: String {
    case email = "email"
    case firstName = "firstName"
    case lastName = "lastName"
    case password = "password"
}

public enum CompanyEmployeeRelationships: String {
    case company = "company"
}

public class _CompanyEmployee: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "CompanyEmployee"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CompanyEmployee.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var email: String?

    @NSManaged public
    var firstName: String?

    @NSManaged public
    var lastName: String?

    @NSManaged public
    var password: String?

    // MARK: - Relationships

    @NSManaged public
    var company: NSSet

}

extension _CompanyEmployee {

    func addCompany(objects: NSSet) {
        let mutable = self.company.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.company = mutable.copy() as! NSSet
    }

    func removeCompany(objects: NSSet) {
        let mutable = self.company.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.company = mutable.copy() as! NSSet
    }

    func addCompanyObject(value: Company) {
        let mutable = self.company.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.company = mutable.copy() as! NSSet
    }

    func removeCompanyObject(value: Company) {
        let mutable = self.company.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.company = mutable.copy() as! NSSet
    }

}

