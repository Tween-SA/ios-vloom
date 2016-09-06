//
//  Consts.swift
//  Vloom
//
//  Created by Mariano on 3/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation

/// MARK - App engine

let isEnvDev: Bool = false

let AppEngineAccessToken = "d32f7a8d983b442f608bcdbef27e41c32bf0d9a8"
let AppGCMIdToken = "fT7ge95a-6k:APA91bFJWoP5dXfXFW-UEih-OppYAtMBnBnw1lVuiyCk8q-yFXtS1nI2UXqTtdCNU5gynjXGuFBUgX-hEdjbw_7xlcaH4gZWioWFCa_DjnDdHgUbtz267EEQ6tNKhcYU1Gw-HbCNpSIz"

enum AppEndPoint : String, CustomStringConvertible {
    
    case Users                      = "users"
    case UserById                   = "users/:userId"
    case UserMessages               = "users/:userId/messages"
    case UserCompanies              = "users/:userId/subscriptions/"
    case UserCompanyById            = "users/:userId/companies/:id"
    case UsersCall                  = "users/tts"
    case Companies                  = "companies"
    case CompaniesByCountryCode     = "companies/countryCode"
    case CompanyById                = "companies/:companyId"
    case CompanyMessages            = "companies/:companyId/messages"
    case CompanyMessageById         = "companies/:companyId/messages/:id"
    case Countries                  = "countries"
    case Message                    = "messages/:id"
    case Messages                   = "messages"
    
    var description: String {
        return self.rawValue
    }
    
}

enum FlowState {
    
    case FromAlert
    case FromSettings
    case FromSignUp
}

/// MARK - URLS

let BusinessRegister = "https://vloom.io/us/business"
let SupportEmailAddress = "soporte@vloom.io"

/// MARK - IP engine

let IPEngineBaseURL = "http://ip-api.com"

enum IPEndPoint : String {
    
    case Location = "json"
    
}

/// Notifications

enum Notification : String, CustomStringConvertible {
    
    case AppDidReceiveNotification = "DidReceiveMessage"
    
    var description: String {
        return self.rawValue
    }
    
}

/// Business rules

let MaxNumberOfCallsForVerificationCode = 2

/// GCM

let GCMSenderId = "189459365557"

#if PROD

let GCMSandbox = false

#else

let GCMSandbox = true
    
#endif

/// Logging

func DLog(message: String?, function: String = __FUNCTION__) {
    #if DEBUG
        print("\(function): \(message)")
    #endif
}
