//
//  BaseViewController.swift
//  Vloom
//
//  Created by Luciano on 5/16/16.
//  Copyright © 2016 ViaCelular. All rights reserved.
//

import UIKit
import Google.Analytics

class BaseViewController: UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // [START screen_view_hit_swift]
        let tracker = GAI.sharedInstance().defaultTracker
        if let theTitle = self.title {
            tracker.set(kGAIScreenName, value: theTitle)
            
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])
        }
        // [END screen_view_hit_swift]
    }
    
}