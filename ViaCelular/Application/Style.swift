//
//  Style.swift
//  Vloom
//
//  Created by Mariano on 12/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit

class Style {
    
    static func customizeAppeareance() {
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 1, green: 143.0/255.0, blue: 1.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        UINavigationBar.appearance().translucent = false
    }
    
}