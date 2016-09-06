//
//  PushManager.swift
//  Vloom
//
//  Created by Mariano on 5/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import Google.CloudMessaging

class GCMManager : NSObject, GGLInstanceIDDelegate, GCMReceiverDelegate /*, AppGCMTokenRegistrator*/ {
    
    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    var latestConnectError: NSError?
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"
    let subscriptionTopic = "/topics/global"
    
    
    let instanceIdConfig = GGLInstanceIDConfig.defaultConfig()
    var instanceId: GGLInstanceID!
    var apnsToken: NSData?
    var application: UIApplication?
    var delegate: UIApplicationDelegate?
    
    override init() {

        super.init()
        
        print(" -> (GCM) -> INIT FUNC...")
        
        self.instanceIdConfig.delegate = self
        GGLInstanceID.sharedInstance().startWithConfig(self.instanceIdConfig)
        self.instanceId = GGLInstanceID.sharedInstance()
    }
    
    func registerForRemoteNotifications(application: UIApplication, withDelegate: UIApplicationDelegate) {
        // [START register_for_remote_notifications]
        
        // [START_EXCLUDE]
        // Configure the Google context: parses the GoogleService-Info.plist, and initializes the services that have entries in the file
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, " -> (GCM) -> Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        // [END_EXCLUDE]
        
        // Register for remote notifications
        if #available(iOS 8.0, *) {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // Fallback
            let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
            application.registerForRemoteNotificationTypes(types)
        }
        // [END register_for_remote_notifications]
        
        self.application = application
        self.delegate = withDelegate
        
        // [START start_gcm_service]
        let gcmConfig = GCMConfig.defaultConfig()
        gcmConfig.receiverDelegate = self
        GCMService.sharedInstance().startWithConfig(gcmConfig)
        // [END start_gcm_service]
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData) {
        
        apnsToken = deviceToken
        
        // [START get_gcm_reg_token]
        // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self
        
        // Start the GGLInstanceID shared instance with that config and request a registration token to enable reception of notifications
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        
        print(" -> (GCM) -> ENVIRONMENT == SANDBOX?: \(GCMSandbox)")
        
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken, kGGLInstanceIDAPNSServerTypeSandboxOption:true]
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID, scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
        // [END get_gcm_reg_token]
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(error: NSError) {
        // [START receive_apns_token_error]
        print(" -> (GCM) -> Registration for remote notification failed with error: \(error.localizedDescription)")
        // [END receive_apns_token_error]
        let userInfo = ["error": error.localizedDescription]
        NSNotificationCenter.defaultCenter().postNotificationName(registrationKey, object: nil, userInfo: userInfo)
    }
    
    func didReceiveRemoteNotificationWithUserInfo(userInfo: [NSObject : AnyObject]) {
        print(" -> (GCM) -> Notification received: \(userInfo)")
        
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
        
        // Handle the received message
        // [START_EXCLUDE]
        NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil, userInfo: userInfo)
        // [END_EXCLUDE]
    }
    
    func didReceiveRemoteNotificationWithUserInfo(userInfo: [NSObject : AnyObject], fetchCompletionHandler: (UIBackgroundFetchResult) -> Void) {
        print(" -> (GCM) -> Notification received: \(userInfo)")
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
        
        // Handle the received message. Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
        // [START_EXCLUDE]
        NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil, userInfo: userInfo)
        fetchCompletionHandler(UIBackgroundFetchResult.NoData);
        // [END_EXCLUDE]
    }
    // [END ack_message_reception]
    
    // TODO: See if this applies to the current GCM implementation...
    /*func getGCMToken(handler: (token: String?, error: NSError?) -> Void) {

        print("     (GCM LOG) GET TOKEN FUNC...")
        
        guard let apnsToken = self.apnsToken else {
            print("     (GCM LOG) Warning: apns token is null... not requesting a GCM token")
            handler(token: nil, error: nil)
            return
        }
                
        let registrationOptions = [kGGLInstanceIDRegisterAPNSOption : apnsToken, kGGLInstanceIDAPNSServerTypeSandboxOption : GCMSandbox]
        self.instanceId.tokenWithAuthorizedEntity(GCMSenderId, scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: handler)
    }*/
    
    func connectToService() {
        // [START connect_gcm_service]
        self.latestConnectError = nil
        
        // Connect to the GCM server to receive non-APNS notifications
        GCMService.sharedInstance().connectWithHandler({(error:NSError?) -> Void in
            if let error = error {
                self.latestConnectError = error
                print(" -> (GCM) -> Could not connect to GCM: \(error.localizedDescription)")
            } else {
                self.connectedToGCM = true
                print(" -> (GCM) -> Connected to GCM")
                // [START_EXCLUDE]
                self.subscribeToTopic()
                // [END_EXCLUDE]
            }
        })
        // [END connect_gcm_service]
    }
    
    func disconnectFromService() {
        // [START disconnect_gcm_service]
        
        GCMService.sharedInstance().disconnect()
        // [START_EXCLUDE]
        self.connectedToGCM = false
        // [END_EXCLUDE]
        
        // [END disconnect_gcm_service]
    }
    
    var notificationsSilenced: Bool {
        
        get {
            if let currentSettings = self.application?.currentUserNotificationSettings() where currentSettings.types.contains(UIUserNotificationType.Sound) {

                return true
            
            } else {
                
                return false
            }
        }
        set (value) {
            
            var types: UIUserNotificationType!
            
            if (value) {
        
                types = [.Alert, .Sound, .Badge]
                
            } else {
                
                types = [.Alert, .Badge]
                
            }
            
            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
            self.application?.registerUserNotificationSettings(settings)
        }
    }
    
    // MARK - Helper Methods
    
    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the topic
        if(registrationToken != nil && connectedToGCM) {
            GCMPubSub.sharedInstance().subscribeWithToken(self.registrationToken, topic: subscriptionTopic, options: nil, handler: {(error:NSError?) -> Void in
                if let error = error {
                    // Treat the "already subscribed" error more gently
                    if error.code == 3001 {
                        print(" -> (GCM) -> Already subscribed to \(self.subscriptionTopic)")
                    } else {
                        print(" -> (GCM) -> Subscription failed: \(error.localizedDescription)");
                    }
                } else {
                    self.subscribedToTopic = true;
                    NSLog(" -> (GCM) -> Subscribed to \(self.subscriptionTopic)");
                }
            })
        }
    }
    
    func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            self.registrationToken = registrationToken
            print(" -> (GCM) -> Registration Token: \(registrationToken)")
            self.subscribeToTopic()
            let userInfo = ["registrationToken": registrationToken]
            NSNotificationCenter.defaultCenter().postNotificationName(self.registrationKey, object: nil, userInfo: userInfo)
        } else {
            print(" -> (GCM) -> Registration to GCM failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(self.registrationKey, object: nil, userInfo: userInfo)
        }
    }
    
    // [START on_token_refresh]
    func onTokenRefresh() {
        
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        print(" -> (GCM) -> The GCM registration token needs to be changed.")
        
        print(" -> (GCM) -> CURRENT GCM SENDER ID = \(gcmSenderID)")
        
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID, scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)

        print(" -> (GCM) -> NEW GCM SENDER ID ??? = \(gcmSenderID)")
        
        let tmpUser: User = User.currentUser!
        
        User.getById(tmpUser.id!){(user, error) -> Void in
            
            if (user != nil)
            {
                let aUser : User = User.currentUser!
                let aPhone : String = "+"+aUser.phone!
                let aId : String = aUser.id!
                
                let params = ["userId" : aId ,"gcmId" : aUser.gcmId! , "phone" : aPhone, "info": ["countryLanguage":User.localeIdentifier()]]
                
                engine.PUT(.UserById, params: params).onSuccess {(results) -> Void in
                        DLog(" -> (GCM) Updated successfully")
                    }.onFailure { (error) -> Void in
                        DLog(error.localizedDescription)
                }
            }
        }
        
        // TODO: See if this applies to the current GCM implementation...
        /*self.getGCMToken { (token, error) -> Void in
         if let token = token {
                self.delegate?.appGCMTokenRegistrator(self, didRefreshGCMToken: token)
            }
         }*/
    }
    // [END on_token_refresh]
    
    // [START upstream_callbacks]
    func willSendDataMessageWithID(messageID: String!, error: NSError!) {
        if (error != nil) {
            // Failed to send the message.
            print(" -> (GCM) -> Failed to send the message with error: \(error.localizedDescription)")
        } else {
            // Will send message, you can save the messageID to track the message
            print(" -> (GCM) -> Will send message, you can save the messageID to track the message")
        }
    }
    
    func didSendDataMessageWithID(messageID: String!) {
        // Did successfully send message identified by messageID
        print(" -> (GCM) -> Did successfully send message identified by messageID: \(messageID)")
    }
    // [END upstream_callbacks]
    
    func didDeleteMessagesOnServer() {
        // Some messages sent to this device were deleted on the GCM server before reception, likely
        // because the TTL expired. The client should notify the app server of this, so that the app
        // server can resend those messages.
        print(" -> (GCM) -> did Delete Messages On Server")
    }
}