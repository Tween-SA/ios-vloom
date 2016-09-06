import Foundation
import MagicalRecord

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

@objc(User)
public class User: _User {
    
    //MARK - Session
    
    static var currentUser: User? {
        get {
            return MR_findFirstByAttribute("isCurrent", withValue: true) as? User
        }
    }
    
    static func signup(country country: Country, phone: Int64, handler: (succeeded: Bool, error: NSError?) -> Void) {
        
        //Make sure to remove current user if any
        self.currentUser?.managedObjectContext?.deleteObject(self.currentUser!)
        
        let user = User.MR_createEntity() as! User
        let userInfo = UserInfo.MR_createEntity() as! UserInfo
        
//        appTokenRegistrator.getGCMToken { (token, error) -> Void in
        
            var gcmId = GCM.registrationToken //appTokenRegistrator.registrationToken
        
            if ((gcmId) != nil) {
                print(" -> GCM -> Token obtained == \(gcmId!)")
            }
            else {
                
                if Platform.isSimulator {
                    gcmId = AppGCMIdToken
                } else {
                    gcmId = ""
                    handler(succeeded: false, error: NSError(domain: "Vloom.Model.User.signup", code: 500, userInfo: nil))
                    return
                }
            }
            
            print(" -> GCM -> Token obtained == \(gcmId)")
            
            user.gcmId = gcmId
            
            user.phone = String(phone)
            
            let phoneStr : String = "+" + String(phone)
            let countryCode : String = country.isoCode!
            
            userInfo.countryCode = countryCode
            userInfo.firstName = ""
            userInfo.lastName = ""
            userInfo.status = 0
            userInfo.email = ""
            
            user.info = userInfo
        
        // TODO: Get the carrier name or send an empty value
        let params = ["gcmId" : gcmId!, "phone" : phoneStr, "info": ["countryCode": countryCode, "os" : "ios", "carrier" : "PERSONAL", "countryLanguage":User.localeIdentifier()]]
        
        engine.POST(.Users, params: params).onSuccess { (results) -> Void in
            
            let jsonDictionary = results.first as? NSDictionary
            
            var userId : String = ""
            
            if isEnvDev {
                userId = jsonDictionary?.objectForKey("id") as! String
                user.id = userId
            }
            
            let gcmId : String    = jsonDictionary?.objectForKey("gcmId") as! String
            
            
            user.gcmId = gcmId
            user.isCurrent = true
            user.country = country
            user.managedObjectContext?.MR_saveToPersistentStoreWithCompletion(nil)
            handler(succeeded: true, error: nil)
            }.onFailure { (error) -> Void in
                handler(succeeded: false, error: error)
        }
    
    }

    func logout() {
        
        self.isCurrent = false
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion(nil)
        
    }
    
    func saveGCMToken(gcmToken: String, handler: ((succeeded: Bool, error: NSError?) -> Void)? = nil) {
        
        let oldToken = self.gcmId
        self.gcmId = gcmToken
        
        self.save(["gcmId"]) { (succeeded, error) -> Void in
            
            if (succeeded == false) {
                self.gcmId = oldToken
            }
            
            handler?(succeeded: succeeded, error: error)
            
        }
        
    }
    
    //MARK - Verification code
    
    func callForVerificationCode(handler: (succeeded: Bool, error: NSError?) -> Void) {
        
        let aPhone : String = "+"+self.phone!

        engine.POST(.UsersCall, params: ["phone" : aPhone, "info": ["countryLanguage":User.localeIdentifier()]], mapping: [(.Root => .Value)]).onSuccess { (results) -> Void in
            
            self.isCurrent = true
            self.managedObjectContext?.MR_saveToPersistentStoreWithCompletion(nil)
            handler(succeeded: true, error: nil)
            
        }.onFailure { (error) -> Void in
            
            handler(succeeded: false, error: error)
            
        }
        
    }
    
    
    func verifyCode(code: String, handler: (succeeded: Bool, error: NSError?) -> Void) {
        
        let aUser : User = User.currentUser!
        
        let aPhone : String = "+"+aUser.phone!
        let osTmp : String = "ios"

        let params = ["gcmId" : aUser.gcmId! , "phone" : aPhone, "code" : code, "info" : ["os" : osTmp,"countryLanguage":User.localeIdentifier()]]
        
        engine.PUT(.Users, params: params, mapping: [(.Root => .ObjectUpdate(self))]).onSuccess { (results) -> Void in
            
            self.isCurrent = true
            self.managedObjectContext?.MR_saveToPersistentStoreWithCompletion(nil)
            handler(succeeded: true, error: nil)
            
            }.onFailure { (error) -> Void in
                
                DLog(error.localizedDescription)
                handler(succeeded: false, error: error)
                
        }
        
    }
    

    //MARK - Update
    
    func save(fields: [String]? = nil, handler: (succeeded: Bool, error: NSError?) -> Void) {
        
        let dictToSave = (fields == nil) ? self.export() : self.export(fields: fields!)

        engine.PUT(.Users, params: dictToSave, mapping: [(.Root => .ObjectUpdate(self))]).onSuccess { (results) -> Void in
            
            handler(succeeded: true, error: nil)
            
        }.onFailure { (error) -> Void in

            handler(succeeded: false, error: error)
            
        }
        
    }
    
    //MARK - Companies
    
    static func setCompanySuscribe(aCompany: Company, UserId: String, Suscribe: Bool, identificationValue:String? = nil, handler: (succeeded: Bool, error: NSError?) -> Void) {
        
        let oldValue = aCompany.userSuscribe
        aCompany.blocked = Suscribe
        var params = []

        if identificationValue != nil {
            params = [["companyId" : aCompany.id!, "info": ["countryLanguage":User.localeIdentifier()], "suscribe" : Suscribe ? 1:0, "identificationValue" : identificationValue!]]
        }else{
            params = [["companyId" : aCompany.id!, "info": ["countryLanguage":User.localeIdentifier()], "suscribe" : Suscribe ? 1:0]]
        }
        
        engine.PUT(.UserCompanies, headers : ["userId" : UserId] ,params: params).onSuccess { (results) -> Void in
            
            handler(succeeded: true, error: nil)
            
            }.onFailure { (error) -> Void in
                
                aCompany.userSuscribe = oldValue
                handler(succeeded: false, error: error)
        }
    }
    
    //MARK - Messages
    
    static func getMessages(UserID: String, handler: (messages: [Message]?, error: NSError?) -> Void) {
        
        print(" USER ID \(UserID)");
        
        let params = ["userId" : UserID]
        
        engine.GET(.UserMessages, params: params, mapping: [.Root => .Array(Message.self)]).onSuccess { (results) -> Void in
            
            handler(messages: Message.listLocalMessages(), error: nil)
            
        }.onFailure { (error) -> Void in
            
            
            let mesages =  Message.listLocalMessages()
            handler(messages: mesages, error: error)
        }
        
    }
    
    //MARK - Listing
    
    static func getById(userId: String, handler: (user: User?, error: NSError?) -> Void) {
        
        engine.GET(.UserById, params: ["userId" : userId]).onSuccess { (results) -> Void in
            
            let jsonDictionary = results.first as? NSDictionary
            var userId: String = ""
            
            if isEnvDev {
                userId   = jsonDictionary?.objectForKey("id") as! String
            } else {
                userId = jsonDictionary?.objectForKey("_id") as! String
            }
            
            let gcmId : String = jsonDictionary?.objectForKey("gcmId") as! String
            let currentUser = User.currentUser
            
            currentUser?.id = userId
            currentUser?.gcmId = gcmId
            
            let companySuscribed = (jsonDictionary?.objectForKey("subs")) as? NSArray
            
            for companyId in companySuscribed! {
                let aCompany = Company.MR_findFirstByAttribute("id", withValue: companyId) as? Company
                aCompany?.userSuscribe = true
            }
            
            handler(user: currentUser,error: nil)
            
        }.onFailure { (error) -> Void in
            
            handler(user: nil, error: error)
                
        }
        
    }
    
    var phoneVerified: Bool {
        get {
            if let status = self.info?.status?.integerValue {
                return status == 1
            } else {
                return false
            }
        }
    }
    
    var fullName: String? {
        get {
            return self.info?.firstName + " " + self.info?.lastName
        }
    }
    
    var phoneString: String {
        get {
            return "+\(self.phone!)"
        }
    }
    
    func setIdentificationValue(value:String?, company:Company?){
        guard let companyId = company!.id else {
            return
        }
        guard let selfId = self.id else {
            return
        }
        
        if value != nil {
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: companyId + selfId)
            NSUserDefaults.standardUserDefaults().synchronize()
        }else{
            NSUserDefaults.standardUserDefaults().removeObjectForKey(companyId + selfId)
            NSUserDefaults.standardUserDefaults().synchronize()
        
        }
    }
    
    func identificationValue(company:Company?) -> String? {
        guard let companyId = company!.id else {
            return nil
        }
        guard let selfId = self.id else {
            return nil
        }
        return NSUserDefaults.standardUserDefaults().objectForKey(companyId + selfId) as? String
    }
    
    static func localeIdentifier() -> String{
        let locale = NSLocale.currentLocale()
        let localeIdentifier:String = (locale.objectForKey(NSLocaleIdentifier) ?? "") as! String
        return localeIdentifier.stringByReplacingOccurrencesOfString("_", withString:"-")
    }
    
}
