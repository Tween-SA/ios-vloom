//
//  AppDelegate.swift
//  Vloom
//
//  Created by Mariano on 2/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import UIKit
import MagicalRecord
import AFNetworkActivityLogger
import Crittercism
import Google.Analytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate /*, AppGCMTokenRegistratorDelegate*/ {

    var window: UIWindow?

    override init() {
       // AFNetworkActivityLogger.sharedLogger().startLogging();
       // AFNetworkActivityLogger.sharedLogger().level = AFHTTPRequestLoggerLevel.AFLoggerLevelDebug
        MagicalRecord.setupCoreDataStackWithAutoMigratingSqliteStoreNamed("ViaCelular")
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Crittercism .enableWithAppID("c463fa8d5d1c4a7592461826bc2b4f9700555300")
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true          // report uncaught exceptions
        gai.logger.logLevel = GAILogLevel.Verbose   // remove before app release
        
        Style.customizeAppeareance()
        flowManager.initialFlow(self.window, storyboard: UIStoryboard(name: "Main", bundle: nil), user: User.currentUser)
        
        self.registerGCM()

        return true
    }
    
    func registerGCM(){
        GCM.registerForRemoteNotifications(UIApplication.sharedApplication(), withDelegate: self/*UIApplication.sharedApplication().delegate as! AppDelegate*/)
    }
    
    func applicationDidBecomeActive( application: UIApplication) {
        GCM.connectToService()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        GCM.disconnectFromService()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        GCM.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
        
        let deviceTokenString = String(format: "%@", deviceToken)
        
        print(" -> (GCM) -> DEVICE TOKEN == \(deviceToken)")
    }
    
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
            
        // TODO: REMOVE THIS, IS JUST FOR DEBUGGING
        let alert = UIAlertView()
        alert.title = "APNS DID FAIL"
        alert.message = "ERROR = \(error)"
        alert.addButtonWithTitle("OK")
        alert.show()
        
        GCM.didFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        GCM.didReceiveRemoteNotificationWithUserInfo(userInfo)
        PushManager.defaultManager.didReceiveRemoteNotification(application, userInfo: userInfo)
        
        print(" -> (GCM) -> APNS RECEIVED == \(userInfo)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
        
        GCM.didReceiveRemoteNotificationWithUserInfo(userInfo, fetchCompletionHandler: handler)
        PushManager.defaultManager.didReceiveRemoteNotification(application, userInfo: userInfo)
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(application: UIApplication) {
        MagicalRecord.cleanUp()
    }
    
    //MARK - App token registrator delegate
    
//    func appGCMTokenRegistrator(appTokenRegistrator: AppGCMTokenRegistrator, didRefreshGCMToken token: String) {
//        
//        User.currentUser?.saveGCMToken(token)
//        
//        print(" -> (GCM) -> REFRESHED TOKEN == \(token)")
//    }
}

