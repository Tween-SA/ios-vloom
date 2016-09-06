//
//  CompanyModel.swift
//  Vloom
//
//  Created by Luciano on 5/9/16.
//  Copyright © 2016 ViaCelular. All rights reserved.
//

class CompanyModel {
    
    var id: String?
    var name: String?
    var about: String?
    var countryCode: String?
    var industryCode: String?
    var industry: String?
    var type : NSNumber?
    var image: String?
    var colorHex: String?
    var info: InfoModel?
    
    required init(Id: String, Name: String, About: String, CountryCode: String, IndustryCode: String, Industry: String, Type: NSNumber, Image : String, ColorHex: String, Info: InfoModel){
        
        self.id = Id
        self.name = Name
        self.about = About
        self.countryCode = CountryCode
        self.industryCode = IndustryCode
        self.industry = Industry
        self.type = Type
        self.image = Image
        self.colorHex = ColorHex
        self.info = Info
    }
    
    func getNumbers() -> [String] {
        
        var ret = [String]()
        
        for numbersModel in (self.info?.fromNumbers)! {
            ret.append(numbersModel.from!)
        }
        
        return ret
    }
}

class InfoModel {
    
    var fromNumbers: [FromNumbersModel]?
    var keywords: String?
    var unsuscribe: String?
    var web: String?
    var phone : String?
    var email : String?
    
    required init(FromNumbers: [FromNumbersModel], Keywords: String, Unsuscribe : String, Web: String, Phone: String, Email: String) {
        
        self.fromNumbers = FromNumbers
        self.keywords = Keywords
        self.unsuscribe = Unsuscribe
        self.web = Web
        self.phone = Phone
        self.email = Email
    }
}

class FromNumbersModel {
    
    var from: String?
    var type: String?
    
    required init(From: String, Type: String) {
        self.from = From
        self.type = Type
    }
}