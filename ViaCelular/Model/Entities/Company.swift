import Foundation

@objc(Company)
public class Company: _Company {

    static func list(countryCode: String, handler: ((companies: [Company]?, error: NSError?) -> Void)? = nil) {
        
        engine.GET(.CompaniesByCountryCode, params: ["code" : countryCode], mapping: [(.Root => .Array(Company.self))]).onSuccess { (results) -> Void in
            
            handler?(companies: results.first as? [Company], error: nil)
            
        }.onFailure { (error) -> Void in
            
            let companies =  Company.MR_findAll()
            if companies != nil{
                handler?(companies: companies as? [Company], error: error)
            }else{
                handler?(companies: nil, error: error)
            }
        }
        
    }
    
    static func getCompanyDetail(companyId:String, handler: (company: Company?, error: NSError?) -> Void) {
        
        engine.GET(.CompanyById, params: ["companyId" : companyId], mapping: [(.Root => .Object(Company.self))]).onSuccess { (results) -> Void in
                handler(company: results.first as? Company, error: nil)
            }.onFailure { (error) -> Void in
                handler(company: nil, error: error)
        }
    }
    
    func getDetail(handler: (company: CompanyModel?, error: NSError?) -> Void) {
        
        engine.GET(.CompanyById, params: ["companyId" : self.id!], mapping: [(.Root => .Object(Company.self))]).onSuccess { (results) -> Void in
            
            let jsonDictionary = results.first as? NSDictionary
            
            var web: String = ""
            var keywords: String = ""
            var unsuscribe: String = ""
            var phone : String = ""
            var email : String = ""
            var fromNumbersModel:[FromNumbersModel] = []
            var userId : String = ""
            var name : String = ""
            var about : String = ""
            var countryCode : String = ""
            var industryCode : String = ""
            var industry : String = ""
            var type : NSNumber = 0
            var image : String = ""
            var colorHex : String = ""
            var info : NSDictionary?
            
            if let tmpId  =  jsonDictionary?.objectForKey("id") {
                userId = tmpId as! String
            }
            
            if let tmpName  =  jsonDictionary?.objectForKey("name") {
                name = tmpName as! String
            }
            
            if let tmpAbout  =  jsonDictionary?.objectForKey("about") {
                about = tmpAbout as! String
            }
            
            if let tmpcCountryCode  =  jsonDictionary?.objectForKey("countryCode") {
                countryCode = tmpcCountryCode as! String
            }
            
            if let tmpIndustryCode  =  jsonDictionary?.objectForKey("industryCode") {
                industryCode = tmpIndustryCode as! String
            }
            
            if let tmpIndustry  =  jsonDictionary?.objectForKey("industry") {
                industry = tmpIndustry as! String
            }
            
            if let tmpType  =  jsonDictionary?.objectForKey("type") {
                type = tmpType as! NSNumber
            }

            if let tmpImage  =  jsonDictionary?.objectForKey("image") {
                image = tmpImage as! String
            }
            
            if let tmpColorHex  =  jsonDictionary?.objectForKey("colorHex") {
                colorHex = tmpColorHex as! String
            }
            
            if let  tmpInfo = jsonDictionary?.objectForKey("info")
            {
                let info    = jsonDictionary?.objectForKey("info") as! NSDictionary
                
                if let tmpKeywords  =  info.objectForKey("keywords") {
                    keywords = tmpKeywords as! String
                }
                
                if let tmpUnsuscribe = info.objectForKey("unsuscribe") {
                    unsuscribe   = tmpUnsuscribe as! String
                }
                
                if let tmpWeb = info.objectForKey("web"){
                    web = tmpWeb as! String
                }
                
                if let tmpPhone  =  info.objectForKey("phone") {
                    phone = tmpPhone as! String
                }
                
                if let tmpEmail  =  info.objectForKey("email") {
                    email = tmpEmail as! String
                }
                if let tmpAbout  =  info.objectForKey("about") {
                    about = tmpAbout as! String
                }
                
                if let tmpFromNumbers = info.objectForKey("fromNumbers") {
                    let fromNumbers = tmpFromNumbers as! NSArray
                    
                    for fromDic in fromNumbers{
                        
                        let from = fromDic.objectForKey("from") as! String
                        let type = fromDic.objectForKey("type") as! String
                        
                        let fromNumbersModelA = FromNumbersModel.init(From: from, Type: type)
                        fromNumbersModel.append(fromNumbersModelA)
                    }
                }

            }
            
            
            let infoModel : InfoModel = InfoModel.init(FromNumbers: fromNumbersModel, Keywords: keywords, Unsuscribe: unsuscribe, Web: web, Phone: phone, Email: email)
            
            let companyModel: CompanyModel = CompanyModel.init(Id: userId, Name: name, About: about, CountryCode: countryCode, IndustryCode: industryCode, Industry: industry, Type: type, Image: image, ColorHex: colorHex, Info: infoModel)
            
            handler(company: companyModel, error: nil)
            
        }.onFailure { (error) -> Void in
            
            handler(company: nil, error: error)
            
        }
    }
    
    func listMessages(handler: (messages: [Message]?, error: NSError?) -> Void) {

        engine.GET(.CompanyMessages, params: ["companyId" : self.id!], mapping: [.Root => .Array(Message.self)]).onSuccess { (results) -> Void in
         
            let messages = Message.MR_findAllWithPredicate(NSPredicate(format: "status < 5"))
            
            handler(messages: messages as? [Message], error: nil)
            
        }.onFailure { (error) -> Void in
            
            handler(messages: nil, error: error)
        
        }
        
    }
    
    func listLocalMessages() -> [Message]{
        return Message.listLocalMessages(self.id!)
    }
    
    static func updateCompanyStatus(CompanyId: String, Status: Int, handle handler: (succeded: Bool, error: NSError?) -> Void) {
        
        let params = ["companyId": CompanyId,"status" : Status]
        
        engine.PUT(.CompanyById, params: params).onSuccess { (results) -> Void in
            
            handler(succeded: true, error: nil)
            
            }.onFailure { (error) -> Void in
                handler(succeded: false, error: error)
                
        }
    }
    
    
    static func getCompanyById(CompanyId: String) -> Company?
    {
        return MR_findFirstByAttribute("id", withValue: CompanyId) as? Company
    }
    
}
