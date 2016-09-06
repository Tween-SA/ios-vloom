//
//  NotificationModel.swift
//  Vloom
//
//  Created by Luciano on 3/12/16.
//  Copyright © 2016 Vloom. All rights reserved.
//

import UIKit

class NotificationModel
{
    var companyObj: Company?
    var companyId: String=""
    var company: String=""
    var isUnsuscribe: Bool = false
    var isLocked: Bool = false
    var lastMsgDate: NSNumber = 0
    var image: String?
    var totalUnreadMessage : Int=0
    var messages:[Message] = []
    
    required init(CompanyObj: Company ,CompanyID: String, aCompany: String, Unsuscribe: Bool,  Locked: Bool, LastMsgDate: NSNumber, Image: String?)
    {
        companyId          = CompanyID
        company            = aCompany
        isUnsuscribe       = Unsuscribe
        isLocked           = Locked
        lastMsgDate        = LastMsgDate
        totalUnreadMessage = 0
        image              = Image
        companyObj         = CompanyObj
    }
    
}


extension NotificationModel: Equatable{}
    
func ==(lhs: NotificationModel, rhs: NotificationModel) -> Bool {
    return lhs.companyId == rhs.companyId
}

