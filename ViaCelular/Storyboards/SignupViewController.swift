//
//  SignupViewController.swift
//  Vloom
//
//  Created by Mariano on 6/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit

enum SignupViewState {
    
    case Normal
    case Loading
    
}

class SignupViewController : BaseViewController, PhoneInputViewDelegate, CountriesListViewControllerDelegate {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var acceptButton: UIBarButtonItem!
    @IBOutlet var phoneInputView: PhoneInputView!
    @IBOutlet weak var loader: UIActivityIndicatorView?
    
    var flowState : FlowState = FlowState.FromSignUp
    var retryCount : Int = 0
    let retryCountLimit : Int = 3
    private var countriesList: [Country]!
    
    private var viewState = SignupViewState.Normal {
        didSet {
            
            switch(self.viewState) {
                
            case .Normal:
                    self.loader?.stopAnimating()
                    //UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
            case .Loading:
                    self.loader?.startAnimating()
                    //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Tú número de teléfono"
        self.loader?.startAnimating()
        self.phoneInputView.delegate = self
        self.phoneInputView.loadDefaultLocation()
        CustomAlertManager.shareInstance.cancelShowCustomAlert()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        super.prepareForSegue(segue, sender: sender)
        
        switch (segue.identifier!) {
            
            case "Show countries list":
            let vc = segue.destinationViewController as! CountriesListViewController
            vc.countriesList = self.countriesList
            vc.delegate = self
            
            case "Show phone verification":
            let vc = segue.destinationViewController as! PhoneVerificationViewController
            vc.flowState = self.flowState
            vc.user = User.currentUser
            
            default:
            break
            
        }
        
    }
    
    //MARK: - Phone input delegate
    
    func phoneInputView(phoneInputview: PhoneInputView, didSelectCountries countries: [Country]) {
        
        self.countriesList = countries
        self.performSegueWithIdentifier("Show countries list", sender: self)
        
    }
    
    func phoneInputView(phoneInputView: PhoneInputView, didFailToDetermineLocation error: NSError?) {
        
    }
    
    func shouldShowActivity(phoneInputview: PhoneInputView)
    {
       self.loader?.startAnimating()
    }
    
    func shouldHideActivity(phoneInputview: PhoneInputView)
    {
        self.loader?.stopAnimating()
    }
    
    //MARK: - Countries list delegate
    
    func countriesList(countriesListViewController: CountriesListViewController, didSelectCountry country: Country?) {
        
        self.navigationController?.popViewControllerAnimated(true)
        self.phoneInputView.selectedCountry = country
        
    }
    
    //MARK: - Actions
    
    @IBAction func onPhoneInputViewValueChanged() {
        
        self.acceptButton.enabled = self.phoneInputView.isFilled
        
    }
    
    @IBAction func onAccept() {


        self.loader?.startAnimating()
        self.phoneInputView.phoneTextField.resignFirstResponder()
        
        if (GCM.registrationToken == nil && GCM.latestConnectError == nil) {
            //Listen GCM Registration
            NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: "GCMRegistrationComplete:",
                name: GCM.registrationKey,
                object: nil)
            (UIApplication.sharedApplication().delegate as! AppDelegate).registerGCM()

        }else if (GCM.latestConnectError != nil){
            self.loader?.stopAnimating()
            if retryCount < retryCountLimit {
                print("GCMRegistrationComplete RETRY =>  \(retryCount)")
                retryCount += 1
                self.retry()
            }else{
                self.loader?.stopAnimating()
                self.alertAndRetry(GCM.latestConnectError?.description)
            }

        }else{
            //Continue Signup
            self.callSignup()
        }
    }
    
    func GCMRegistrationComplete(notification: NSNotification){
        NSNotificationCenter.defaultCenter().removeObserver(self);

        if let error = notification.userInfo!["error"] {
            if retryCount < retryCountLimit {
                print("GCMRegistrationComplete RETRY =>  \(retryCount)")
                retryCount += 1
                self.retry()
            }else{
                self.loader?.stopAnimating()
                self.alertAndRetry(error.description)
            }
        }else if  notification.userInfo!["registrationToken"]  != nil{
            //Continue Signup
            self.callSignup()
        }else{
            self.loader?.stopAnimating()
            let alertController = UIAlertController(title: "Error Google Cloud Message", message: "Undefined error.", preferredStyle: .Alert)
            alertController.addAcceptAction()
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func alertAndRetry(errorMessage:String?){
        let alertController = UIAlertController(title: "Error Google Cloud Message", message: errorMessage ?? "Empty Error"+" - ¿Desea reintentar?", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "No", style: .Cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Si", style: .Default) { (action) in
            self.retry()
        }
        alertController.addAction(OKAction)
        
        retryCount = 0
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func retry(){
        self.loader?.startAnimating()
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "GCMRegistrationComplete:",
            name: GCM.registrationKey,
            object: nil)
        (UIApplication.sharedApplication().delegate as! AppDelegate).registerGCM()
    }
    
    func callSignup() -> Void {
        User.signup(country: self.phoneInputView.selectedCountry!, phone: self.phoneInputView.phoneNumber! /*, appTokenRegistrator: GCM*/) { (succeeded, error) -> Void in
            
            self.loader?.stopAnimating()
            
            if (succeeded) {
                
                self.performSegueWithIdentifier("Show phone verification", sender: self)
                
            } else {
                var alertController:UIAlertController
                if(error?.code == 500){
                    alertController = UIAlertController(title: "", message: "Invalid Google Cloud Message Id", preferredStyle: .Alert)
                }else{
                    alertController = UIAlertController(title: "", message: "Se produjo un error al registrar el usuario: "+error?.description, preferredStyle: .Alert)
                }
                alertController.addAcceptAction()
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: Constructor
    
    class func instantiate()->UIViewController
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("SignupViewController")
        
        return vc
    }
}
