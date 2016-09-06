//
//  PhoneVerification.swift
//  Vloom
//
//  Created by Mariano on 13/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit

enum PhoneVerificationViewState {
    
    case Normal
    case Loading
    case Error
    
}

class PhoneVerificationViewController : BaseViewController, CountdownViewDelegate, MySpinnerDelegate {
    
    @IBOutlet weak var codeInputView: CodeInputView!
    @IBOutlet weak var acceptButton: UIBarButtonItem!
    @IBOutlet weak var countdownView: CountdownView!
    @IBOutlet weak var validationText: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var moreImage: UIImageView!
    
    //MARK: - Dependencies
    var flowState : FlowState = FlowState.FromSignUp
    
    var user: User!
    
    //MARK: - State properties
    
    var numberOfCalls: Int = 0
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
 
        super.viewDidLoad()
        
        self.title = "Código de validación"
        
        setup()
                
        //Start the countdown to call
        self.countdownView.start()
        
    }
    
    func setup()
    {
        MySpinner.sharedInstance.delegate = self
        
        if self.flowState == FlowState.FromAlert
        {
            let leftAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Cerrar", style: UIBarButtonItemStyle.Plain, target: self, action: "back")
            
            self.navigationItem.setLeftBarButtonItem(leftAddBarButtonItem, animated: true)
        }
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
    }
    
    func back()
    {
       self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Actions
    
    @IBAction func onCodeInputViewValueChanged() {
        
        self.acceptButton.enabled = self.codeInputView.isFilled
        
    }
    
    @IBAction func onAccept() {
        
        self.codeInputView.resignFirstResponder()
        self.verifyCode(self.codeInputView.code)
    }
    
    //MARK: - Countdown delegate
    
    func countdownViewDidFinish(countdownView: CountdownView) {
        self.checkCountdown()
        self.callForVerificationCode()
    }
    
    func checkCountdown() {
        if self.codeInputView.code.characters.count > 0
        {
            self.codeInputView.resignFirstResponder()
            self.verifyCode(self.codeInputView.code)
        } else
        {
            self.numberOfCalls += 1
            
            self.viewState = .Normal
            
            if (self.numberOfCalls < MaxNumberOfCallsForVerificationCode)
            {
                self.countdownView.notificateInOneMinute = true
                self.countdownView.performSelector("start", withObject: nil, afterDelay: 5)
            }
        }
    }
    
    func countdownViewDidFinishInOneMinute(countdownView: CountdownView)
    {
        self.countdownView.hidden = true
        self.continueButton.hidden = false
        self.validationText.hidden = false
        self.moreImage.hidden = false
    }
    
    //MARK: - Helpers
    
    private func verifyCode(code: String) {
        
        self.viewState = .Loading
        
        //If countdown is running, stop it while we are making the network call to verify the code
        let countdownRunning = self.countdownView.isRunning
        if (countdownRunning) {
            self.countdownView.stop()
        }
        
        self.user.verifyCode(code) { (succeeded, error) -> Void in
            
            if (succeeded)
            {
                self.viewState = .Normal
                
            } else
            {
                self.viewState = .Error
                
                //If countdown was running and we got an error, resume the timer
                if (countdownRunning)
                {
                    self.countdownView.resume()
                }
                
                self.codeInputView.reset()
                
                let alert = UIAlertController(title: "", message: "Error al verificar el código.", preferredStyle: .Alert)
                alert.addAcceptAction()
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func callForVerificationCode() {
        
        self.user.callForVerificationCode { (succeeded, error) -> Void in
            print("Finish callForVerificationCode: \(error)")
        }
        
    }
    
    //MARK: - Private vars
    
    private var viewState = PhoneVerificationViewState.Normal {
        
        didSet {
            
            switch(self.viewState) {
                
            case .Normal:
                self.countdownView.hidden = false
                MySpinner.sharedInstance.showChecked()
                //UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
            case .Loading:
                self.countdownView.hidden = true
                MySpinner.sharedInstance.showTitle("Cargando")
                //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            case .Error:
                self.countdownView.hidden = false
                 MySpinner.sharedInstance.hide()
                //UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
        }
    }
    
    @IBAction func ContinueButton(sender: AnyObject)
    {
        if self.flowState == FlowState.FromAlert
        {
            UIApplication.sharedApplication().keyWindow?.rootViewController!.dismissViewControllerAnimated(false, completion: nil)
            UIApplication.sharedApplication().keyWindow?.rootViewController!.dismissViewControllerAnimated(false, completion: nil)
        } else
        {
            flowManager.homeFlow((UIApplication.sharedApplication().delegate as? AppDelegate)?.window, storyboard: UIStoryboard(name: "Main", bundle: nil))
        }
    }
    
    func shouldShowNextView()
    {
        
        MySpinner.sharedInstance.hide()
            
        flowManager.homeFlow((UIApplication.sharedApplication().delegate as? AppDelegate)?.window, storyboard: UIStoryboard(name: "Main", bundle: nil))
            
        if flowState == FlowState.FromSettings
        {
            let window = UIApplication.sharedApplication().windows.first!
            let tabBarController = window.rootViewController as! UITabBarController
                
            tabBarController.selectedIndex = 2
        }
    }
    
    func shouldShowCountdown() {
        if self.countdownView.notificateInOneMinute {
            self.checkCountdown()
        }
    }
    
    class func instantiate()->UIViewController
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("PhoneVerificationViewController")
        
        return vc
    }
}