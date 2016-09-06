//
//  FlowManager.swift
//  Vloom
//
//  Created by Mariano on 6/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit

public class FlowManager
{
    func initialFlow(window: UIWindow?, storyboard: UIStoryboard, user: User?) {
        
        let signupFlow = (user == nil || user!.id == nil || user!.id == "")
        
        if (signupFlow) {
            self.signupFlow(window, storyboard: storyboard, user: user)
        }
        else {
            let tmpUser: User = User.currentUser!
            User.getById(tmpUser.id!){(user, error) -> Void in
            
                if (user != nil) {
                    let aUser : User = User.currentUser!
                    let aPhone : String = "+"+aUser.phone!
                    let aId : String = aUser.id!
                    
                    let params = ["userId" : aId ,"gcmId" : aUser.gcmId! , "phone" : aPhone, "info": ["countryLanguage":User.localeIdentifier()]]
                    
                    engine.PUT(.UserById, params: params).onSuccess {(results) -> Void in
                        
                    }.onFailure { (error) -> Void in
                        DLog(error.localizedDescription)
                    }
                }
            }
                
            self.homeFlow(window, storyboard: storyboard)
        }
    }
    
    func signupFlow(window: UIWindow?, storyboard: UIStoryboard, user: User?) {
        
        let rootViewController = storyboard.instantiateViewControllerWithIdentifier("Navigation from signup")
        window?.rootViewController = rootViewController
        
        if let navController = rootViewController as? UINavigationController, user = user where user.phoneVerified == false {
            navController.viewControllers.first?.performSegueWithIdentifier("Show phone verification", sender: navController)
        }
    }
    
    func homeFlow(window: UIWindow?, storyboard: UIStoryboard) {
        let rootViewController = storyboard.instantiateViewControllerWithIdentifier("Home tab bar")
        window?.rootViewController = rootViewController
        
        let tabBarController = window?.rootViewController as! UITabBarController
        
        tabBarController.tabBar.translucent = true
        
        if (User.currentUser!.id == nil ||  User.currentUser!.id == "") {
            tabBarController.tabBar.items?[2].badgeValue = " "
            CustomAlertManager.shareInstance.showCustomAlert()
        }
        else {
            tabBarController.tabBar.items?[2].badgeValue = nil
        }
    }
    
    func pushNotificationFlow(notification: NotificationModel) {
        let window = UIApplication.sharedApplication().windows.first!
        let tabBarController = window.rootViewController as! UITabBarController
        
        // Switch to the Notifications tab
        tabBarController.selectedIndex = 0
        let navigationController = tabBarController.viewControllers![0] as! UINavigationController
        navigationController.popToRootViewControllerAnimated(false)
        
        if (navigationController.topViewController is NotificationViewController) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let notificationDetailViewController = storyboard.instantiateViewControllerWithIdentifier("NotificationDetailViewController") as? NotificationDetailViewController
            
            // Read the notification and pass it to the detailVC:
            
            notificationDetailViewController?.currentNotification = notification;
            
            navigationController.pushViewController(notificationDetailViewController!, animated: true)
        }
    }
    
    func updateBadge() {
        let window = UIApplication.sharedApplication().windows.first!
        let tabBarController = window.rootViewController as! UITabBarController
        
        if (User.currentUser!.id == nil ||  User.currentUser!.id == "") {
            tabBarController.tabBar.items?[2].badgeValue = " "
        }
        else {
            tabBarController.tabBar.items?[2].badgeValue = nil
        }
    }
    
}

