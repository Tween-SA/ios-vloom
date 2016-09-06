//
//  CustomAlertManager.swift
//  Vloom
//
//  Created by Luciano on 4/23/16.
//  Copyright © 2016 ViaCelular. All rights reserved.
//

import UIKit

class CustomAlertManager : AnyObject, CustomAlertDelegate
{
    private var countriesList: [Country]!
    private var customAlertVC : CustomAlertVC!
    private var timeToShowAlert: NSTimeInterval = 60
    private var timer: NSTimer?
    internal var shouldShowAlert: Bool = false
    
    static let shareInstance = CustomAlertManager()
    
    @objc private func show()
    {
        let window = UIApplication.sharedApplication().windows.first!
        let tmpImage = window.capture()
        
        if self.shouldShowAlert {
            self.customAlertVC = CustomAlertVC.instantiate()
            customAlertVC.delegate = self
            customAlertVC.addCustomImage(tmpImage)
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "firstTimeShowCustomAlert")
            window.rootViewController?.presentViewController(customAlertVC, animated: false, completion: nil)
        }
    }
    
    func cancelShowCustomAlert() {
        self.shouldShowAlert = false
    }
    
    func showCustomAlert()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let firstTimeShowCustomAlert = defaults.boolForKey("firstTimeShowCustomAlert")
        
        if !firstTimeShowCustomAlert
        {
            self.shouldShowAlert = true
            self.timer = NSTimer.scheduledTimerWithTimeInterval(timeToShowAlert, target: self, selector:"show", userInfo: nil, repeats: false)
            //show()
        } else
        {
            self.shouldShowAlert = true
            show()
        }
    }

    func cancelDidTapped(VC: CustomAlertVC)
    {
        UIApplication.sharedApplication().keyWindow?.rootViewController!.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func okDidTapped(phoneNumber: PhoneInputView)
    {
        
        //UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
        User.signup(country: phoneNumber.selectedCountry!, phone: phoneNumber.phoneNumber! /*, appTokenRegistrator: GCM*/) { (succeeded, error) -> Void in
            
            //UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if (succeeded) {
                
                let vc : PhoneVerificationViewController = PhoneVerificationViewController.instantiate() as! PhoneVerificationViewController
                vc.user = User.currentUser
                vc.flowState = FlowState.FromAlert
                
                let nav = UINavigationController.init(rootViewController: vc)
                
                self.customAlertVC.presentViewController(nav, animated: true, completion: nil)
                
            } else {
                
                let window = UIApplication.sharedApplication().windows.first!
                let alertController = UIAlertController(title: "", message: "Se produjo un error al registrar el usuario", preferredStyle: .Alert)
                alertController.addAcceptAction()
                window.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}

public extension UIWindow {
    
    func capture() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.opaque, UIScreen.mainScreen().scale)
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}