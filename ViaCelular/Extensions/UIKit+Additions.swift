//
//  UIKit+Additions.swift
//  Vloom
//
//  Created by Mariano on 12/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//


extension UIView {
    
    var borderColor: UIColor? {
        get {
            guard let borderColor = self.layer.borderColor else {
                return nil
            }
            
            return UIColor(CGColor: borderColor)
        }
        set (value) {
            self.layer.borderColor = value?.CGColor
        }
    }
    
    func setupXib() {
        
        let view = self.loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        self.addSubview(view)
        
    }
    
    func loadViewFromNib() -> UIView {
        let nibName =  NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    
    
    func sortByTag(var array: [UIView]) {
        array.sortInPlace { (view1, view2) -> Bool in
            return view1.tag < view2.tag
        }
    }
    
}

extension UIApplication {
    
    var appVersion: String {
        
        get {
            return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        }
        
    }
    
    var buildVersion: String {
        
        get {
            return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
        }
        
    }
    
    var versionBuild: String {
        
        get {
            
            let appVersion = self.appVersion
            let buildVersion = self.buildVersion
            
            var versionBuild = appVersion
            
            if (appVersion != buildVersion) {
                versionBuild = "\(appVersion).\(buildVersion)"
            }
            
            return versionBuild
        }
        
    }
    
}

extension UIAlertController {
    
    func addCancelAction(title: String = "Cancel", handler: ((UIAlertAction) -> Void)? = nil) {
        
        let action = UIAlertAction(title: title, style: .Cancel, handler: handler)
        self.addAction(action)
        
    }
    
    func addAcceptAction(title: String = "OK", handler: ((UIAlertAction) -> Void)? = nil) {
        
        let action = UIAlertAction(title: title, style: .Default, handler: handler)
        self.addAction(action)
        
    }
    
    func addAction(title: String, handler: ((UIAlertAction) -> Void)? = nil) {
        
        let action = UIAlertAction(title: title, style: .Default, handler: handler)
        self.addAction(action)
        
    }
    
}



extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        var start:String.CharacterView.Index
        var finalHexColor = hexString

        if hexString.hasPrefix("#") {
            start = hexString.startIndex.advancedBy(1)
        }else{
            start = hexString.startIndex
        }
        
        let hexColor = hexString.substringFromIndex(start)

        if hexColor.characters.count == 6 {
            finalHexColor = hexColor+"FF"
        }
        
        let scanner = NSScanner(string: finalHexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexLongLong(&hexNumber) {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
            
            self.init(red: r, green: g, blue: b, alpha: a)
            return
        }
        
        
        return nil
    }
    
    func isLightColor() -> Bool{

        var red:CGFloat = 0
        var green:CGFloat = 0
        var blue:CGFloat = 0
        var alpha:CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        red = red * 255 * red * 255 * 0.241
        green = green * 255 * green * 255 * 0.691
        blue = blue * 255 * blue * 255 * 0.068
        let brightness:Int	= Int(sqrt(red + green + blue))
    
        if(brightness >= 215) {
            return true
        }else{
            return false
        }
    }
}
    
