//
//  AppGCMTokenRegistrator.swift
//  Vloom
//
//  Created by Mariano on 5/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation

protocol AppGCMTokenRegistrator {
    
    var apnsToken: NSData? { get set }
    var registrationToken: String? { get set }
    
//    func getGCMToken(handler: (token: String?, error: NSError?) -> Void)
    
}

protocol AppGCMTokenRegistratorDelegate {
    
    func appGCMTokenRegistrator(appTokenRegistrator: AppGCMTokenRegistrator, didRefreshGCMToken token: String)
    
}