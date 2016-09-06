//
//  PhoneInputView.swift
//  Vloom
//
//  Created by Mariano on 12/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit
import libPhoneNumber_iOS

enum PhoneInputViewState {
    
    case Normal
    case Error(message: String)
    case Loading
    
}

@IBDesignable
class PhoneInputView : UIControl, UITextFieldDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var locationRequestStateLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var arrowView: UIView!
    
    //MARK: - Dependencies
    @IBOutlet weak var delegate: PhoneInputViewDelegate?
    
    //MARK: - Private vars
    private var countries: [Country]?
    private var phoneFormatter: NBAsYouTypeFormatter?
    
    //MARK: - View events
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupXib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - Textfield delegate    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        guard let selectedCountry = self.selectedCountry else {
            return true
        }
        
        var canProcessChar = true
        
        if let maxLength = selectedCountry.phoneMaxLength?.integerValue {
            canProcessChar = (string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) + range.location <= maxLength)
        }
        
        if (canProcessChar) {
            
            //Something entered by user
            if (range.length == 0) {
                
                textField.text = self.phoneFormatter?.inputDigit(string)
                
            } else if (range.length == 1) {
                
                textField.text = self.phoneFormatter?.removeLastDigit()
                
            }
            
            self.sendActionsForControlEvents(.ValueChanged)
            
        }
        
        return false
    }
    
    //MARK: - Actions
    @IBAction func onCountrySelected() {
    
        self.delegate?.phoneInputView(self, didSelectCountries: self.countries!)
    
    }
    
    @IBAction func onRetry() {
        
        self.loadDefaultLocation()
        
    }
    
    //MARK: - Helpers
    func loadDefaultLocation() {
        
        self.viewState = .Loading
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        Country.fetchCurrentCountry { (country, location, countries, error) -> Void in
            
            self.countries = countries
            self.selectedCountry = country
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if (country == nil) {
                
                self.viewState = .Error(message: "Error al determinar ubicación actual")
                self.delegate?.phoneInputView(self, didFailToDetermineLocation: error)
                
            } else {
                
                self.viewState = .Normal
                
            }
        }
    }
    
    func configure()
    {
        countryCodeLabel.font = UIFont(name: countryCodeLabel.font.fontName, size: 14)
        countryLabel.font = UIFont(name: countryLabel.font.fontName, size: 14)
        phoneTextField.font = UIFont(name: phoneTextField.font!.fontName, size: 14)
        locationRequestStateLabel.font = UIFont(name: locationRequestStateLabel.font.fontName, size: 14)
        errorMessageLabel.font = UIFont(name: errorMessageLabel.font.fontName, size: 14)
        retryButton.titleLabel?.font = UIFont(name: (retryButton.titleLabel?.font.fontName)!, size: 14)
    }
    
    //MARK: - Public vars
    
    var selectedCountry: Country? {
        
        didSet {
            self.countryLabel.text = self.selectedCountry?.name
            self.countryCodeLabel.text = self.selectedCountry?.code
            self.phoneFormatter = NBAsYouTypeFormatter(regionCode: self.selectedCountry?.isoCode)
            self.sendActionsForControlEvents(.ValueChanged)
        }
        
    }
    
    var phoneNumber: Int64? {
        get {
            guard let phoneNumber = self.selectedCountry?.code + self.phoneTextField.text else {
                return nil
            }
            
            let phoneNumberWithoutSpecialChars = phoneNumber.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
            return Int64(phoneNumberWithoutSpecialChars)
        }
    }
    
    var isFilled: Bool {
        
        get {
            
            return self.phoneTextField.text != nil && self.phoneTextField.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 && self.selectedCountry != nil
            
        }
        
    }
    
    private var viewState: PhoneInputViewState = .Normal {

        didSet {
        
            switch (self.viewState) {
                
            case .Normal:
            self.delegate?.shouldHideActivity(self)
            self.locationRequestStateLabel.hidden = true
            self.retryButton.hidden = true
            self.errorMessageLabel.hidden = true
            self.arrowView.hidden = false
            
            case .Loading:
            self.delegate?.shouldShowActivity(self)
            self.locationRequestStateLabel.hidden = false
            self.retryButton.hidden = true
            self.errorMessageLabel.hidden = true
            self.arrowView.hidden = true
                
            case .Error(let message):
            self.delegate?.shouldHideActivity(self)
            self.locationRequestStateLabel.hidden = true
            self.errorMessageLabel.hidden = false
            self.errorMessageLabel.text = message
            self.retryButton.hidden = false
            self.arrowView.hidden = true
                
            }
            
        }
        
    }
    
}

@objc(PhoneInputViewDelegate)
protocol PhoneInputViewDelegate {
    
    func phoneInputView(phoneInputview: PhoneInputView, didSelectCountries countries: [Country])
    func phoneInputView(phoneInputView: PhoneInputView, didFailToDetermineLocation error: NSError?)
    
    func shouldShowActivity(phoneInputview: PhoneInputView)
    func shouldHideActivity(phoneInputview: PhoneInputView)
}