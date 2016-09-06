//
//  SettingsViewController.swift
//  Vloom
//
//  Created by Mariano on 13/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class SettingsViewController : BaseViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var silenceSwitch: UISwitch!
    
    @IBOutlet weak var withoutChecking: UIButton!
    @IBOutlet weak var chevronImage: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Ajustes"
        
        self.tabBarController?.tabBar.hidden = false
        self.silenceSwitch.on = !GCM.notificationsSilenced
        self.displayUserInfo()
        self.displayVersion()
    }
    
    override func viewWillAppear(animated:Bool){
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    private func displayUserInfo()
    {
        if (User.currentUser!.id == nil ||  User.currentUser!.id == "")
        {
            self.withoutChecking.hidden = false
            self.chevronImage.hidden = false
            self.phoneLabel.text = ""
        } else
        {
            self.withoutChecking.hidden = true
            self.chevronImage.hidden = true
            self.phoneLabel.text = User.currentUser?.phoneString
        }
    }
    
    private func displayVersion()
    {
        self.versionLabel.text = "Vloom versión \(UIApplication.sharedApplication().versionBuild)"
    }
    
    @IBAction func onSilenceNotifications()
    {
        GCM.notificationsSilenced = self.silenceSwitch.on
    }
    
    @IBAction func withoutCheckingTapped(sender: AnyObject)
    {
        self.tabBarController?.tabBar.hidden = true
        let vc : SignupViewController = SignupViewController.instantiate() as! SignupViewController
        vc.flowState = FlowState.FromSettings
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func sendFeedback(sender: AnyObject)
    {
        
        PushManager.defaultManager.testNotification()
/*        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([SupportEmailAddress])
        mailComposerVC.setSubject("Comentarios")

        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposerVC, animated: true, completion: nil)
        } else {
            let sendMailErrorAlert = UIAlertView(title: "No pudo enviarse el correo", message: "Se ha producido un error al enviar el correo, intente nuevamente.", delegate: self, cancelButtonTitle: "OK")
            sendMailErrorAlert.show()
        }
 */
    }
    
    @IBAction func register(sender: AnyObject)
    {
        UIApplication.sharedApplication().openURL(NSURL(string: BusinessRegister)!)
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}