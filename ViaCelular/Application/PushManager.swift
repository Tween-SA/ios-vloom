//
//  PushManager.swift
//  Vloom
//
//  Created by Juan on 21/6/16.
//  Copyright © 2016 Vloom. All rights reserved.
//

//------------------------------------------------------------------------------
// MARK: Imports
import Foundation

//------------------------------------------------------------------------------
// MARK: Types


/**
 *  PushManager
 */
class PushManager {

    //------------------------------------------------------------------------------
    // MARK: Class default
    class var defaultManager: PushManager {
        struct Static {
            static let instance = PushManager()
        }
        return Static.instance
    }

    //------------------------------------------------------------------------------
    // MARK: Private Properties

    //------------------------------------------------------------------------------
    // MARK: Public Properties
    static let notificationReceivedKey:String = "notificationReceivedKey"
    
    //------------------------------------------------------------------------------
    // MARK: Setup & Teardown

    //------------------------------------------------------------------------------
    // MARK: Class Methods

    //------------------------------------------------------------------------------
    // MARK: Override Methods

    //------------------------------------------------------------------------------
    // MARK: Private Methods

    //------------------------------------------------------------------------------
    // MARK: public Methods
    
    func testNotification(){
        let notif:[NSObject : AnyObject] = ["payload":"iOS push de prueba 100",
                                            "notification": [
                                                "body":"iOS push de prueba 100",
                                                "e":"1",
                                                "sound":"default",
                                                "sound2":"default",
                                                "title":"Vloom.io"],
                                            "from":"189459365557",
                                            "type":"iOS push test 100",
                                            "companyId":"561fa8d734dea37a1dc73908",
                                            "msgId":"4ea60db260090c255448d7198d934030",
                                            "timestamp":"1472598913937",
                                            "status":"1",
                                            "collapse_key": "com.tween.vloom"]
        
        self.didReceiveRemoteNotification(UIApplication.sharedApplication(),userInfo: notif)

    }
    
    func didReceiveRemoteNotification(application: UIApplication, userInfo: [NSObject : AnyObject]){
        
        guard let user = User.currentUser where user.id != nil && user.id != "" else {
            return
        }
        
        // Check that the company id was sent
        var companyId:String = ""
        if let comp = userInfo["companyId"] as? String {
            companyId = comp
        }else{
            companyId = "57029b3381576d943c9dc9d3"
        }
        
        if let company = Company.getCompanyById(companyId) {
            // Company exist in cache
            self.presentCompany(company, user: user, userInfo: userInfo)
        }else{
            // Update local info of the company
            Company.getCompanyDetail(companyId){ (company, error) in
                if company != nil {
                    self.presentCompany(company!, user: user, userInfo: userInfo)
                }
            }
        }
        
        self.confirmReceivedMessage(userInfo)
        self.updateBadgesCount()
        
        NSNotificationCenter.defaultCenter().postNotificationName(PushManager.notificationReceivedKey, object: nil)
    }
    
    func confirmReceivedMessage(userInfo: [NSObject : AnyObject]) {
        // Get current country
        Location.fetchCurrentLocation({ (location, error) -> Void in
            // report message as Recibido=3
            if let lat = location?.lat , let lng = location?.lon{
                Message.setMessageState(userInfo["msgId"] as! String, Latitude: lat.floatValue, Longitude: lng.floatValue, Status: MessageStatus.Recibido.rawValue, handler: { (succeeded, error) in
                    print("Message.setMessageState Recibido: \(succeeded) \(error)")
                })
            }
        })
    }

    func reportMessageAsSpam(msgId: String) {
        Message.setMessageState(msgId, Status: MessageStatus.Spam.rawValue, handler: { (succeeded, error) in
            print("Message.setMessageState Spam: \(succeeded) \(error)")
        })
    }

    func updateBadgesCount () {
        if let currentUser = User.currentUser {
            Company.list(currentUser.country!.isoCode!) { ( companies, error) -> Void in
                User.getMessages(currentUser.id!) { (messages, error) -> Void in
                    if messages != nil {
                        UIApplication.sharedApplication().applicationIconBadgeNumber = messages!.filter({$0.unRead}).count
                    }
                }
            }
        }
    }
    
    func displayNoficationIfNotMuted(company:Company, userInfo:[NSObject : AnyObject]){
        // If we have the company info, check the muted flag to display notification info
        var companyMuted = false
        if company.mute != nil {
            companyMuted = company.mute!.boolValue
        }
        
        if !companyMuted {
            let alert = UIAlertView()
            alert.title = "Mensaje nuevo"
            alert.message = "\(userInfo["payload"]!)"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    func presentCompany(company:Company, user:User, userInfo:[NSObject : AnyObject]){
        
        if company.blocked != nil && company.blocked!.boolValue {
            if let id = userInfo["msgId"] as? String {
                self.reportMessageAsSpam(id)
            }
        }else if company.userSuscribe!.boolValue {
            let notification: NotificationModel = NotificationModel.init(CompanyObj: company, CompanyID: company.id!, aCompany: company.name!, Unsuscribe: false, Locked: false, LastMsgDate: 1, Image: company.imageURL)
            self.displayNoficationIfNotMuted(company, userInfo: userInfo)
            flowManager.pushNotificationFlow(notification)
        }else{
            User.setCompanySuscribe(company, UserId: user.id!, Suscribe: true) {(succeeded, error) -> Void in
                if succeeded {
                    let notification: NotificationModel = NotificationModel.init(CompanyObj: company, CompanyID: company.id!, aCompany: company.name!, Unsuscribe: false, Locked: false, LastMsgDate: 1, Image: company.imageURL)
                    self.displayNoficationIfNotMuted(company, userInfo: userInfo)
                    flowManager.pushNotificationFlow(notification)
                }else{
                    let alert = UIAlertView()
                    alert.title = "Error"
                    alert.message = "Error subscribiendo a compania"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
            }
        }
    }

    
}
