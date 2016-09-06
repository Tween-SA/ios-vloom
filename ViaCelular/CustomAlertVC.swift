//
//  CustomAlertVC.swift
//  Vloom
//
//  Created by Luciano on 4/14/16.
//  Copyright © 2016 ViaCelular. All rights reserved.
//

import UIKit

protocol CustomAlertDelegate {
    
    func cancelDidTapped(VC: CustomAlertVC)
    func okDidTapped(phoneNumber: PhoneInputView)
}

class CustomAlertVC: UIViewController, PhoneInputViewDelegate, CountriesListViewControllerDelegate
{
    @IBOutlet weak var backgroundAlert: UIView!
    @IBOutlet weak var phoneNumber: PhoneInputView!
    @IBOutlet weak var tmp: UIImageView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var alertYposition: NSLayoutConstraint!
    
    var delegate : CustomAlertDelegate?
    var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    var customImage: UIImage!
    private var countriesList: [Country]!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.activity.startAnimating()
        self.setup()
    }

    func setup()
    {
        activity.color = UIColor.grayColor()
        registerForKeyboardNotifications()
        
        self.backgroundAlert.layer.cornerRadius = 8
        
        let x = UIScreen.mainScreen().bounds.width / 2
        let y = UIScreen.mainScreen().bounds.height / 2
        
        blur.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        blur.layer.cornerRadius = 2
        blur.center = CGPoint(x: x, y: y)
        blur.clipsToBounds = true
        
        self.tmp.image = self.customImage
        self.tmp.addSubview(blur)
        
        phoneNumber.delegate = self
        phoneNumber.configure()
        
        self.view .bringSubviewToFront(self.backgroundAlert)
        phoneNumber.loadDefaultLocation()
    }
    
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWasShown:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillBeHidden:",
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification)
    {
        NSLog("Show Keyborad")
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                
                let tmpY : CGFloat  = (self.view.frame.size.height ) -  (keyboardSize.height + 10 + self.backgroundAlert.frame.height)
                
                let tmpNewY : CGFloat =  tmpY - self.backgroundAlert.frame.origin.y
                
                self.alertYposition.constant = tmpNewY
                }, completion: { finished in
            })
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification)
    {
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.alertYposition.constant = 0
            }, completion: { finished in
        })
    }
    
    class func instantiate()->CustomAlertVC
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("CustomAlertVC") as! CustomAlertVC
        
        return vc
    }
    
    //MARK: - Phone input delegate
    
    func phoneInputView(phoneInputview: PhoneInputView, didSelectCountries countries: [Country])
    {
        self.countriesList = countries
        
        let vc : CountriesListViewController  = CountriesListViewController.instantiate() as! CountriesListViewController
        vc.delegate = self
        
        let nav = UINavigationController.init(rootViewController: vc)
        
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func phoneInputView(phoneInputView: PhoneInputView, didFailToDetermineLocation error: NSError?)
    {
        
    }
    
    func shouldShowActivity(phoneInputview: PhoneInputView)
    {
        self.activity.startAnimating()
    }
    
    func shouldHideActivity(phoneInputview: PhoneInputView)
    {
        self.activity.stopAnimating()
    }
    
    //MARK: - Countries list delegate
    
    func countriesList(countriesListViewController: CountriesListViewController, didSelectCountry country: Country?)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        phoneNumber.selectedCountry = country
    }
    
    func addCustomImage(Image: UIImage)
    {
        self.customImage = Image
    }
    
    @IBAction func cancelTapped(sender: AnyObject)
    {
        self.delegate?.cancelDidTapped(self)
    }
    
    @IBAction func okTapped(sender: AnyObject)
    {
        self.delegate?.okDidTapped(self.phoneNumber)
    }
    
    @IBAction func phoneUpdate(sender: AnyObject)
    {
        self.okButton.enabled = self.phoneNumber.isFilled
    }
}