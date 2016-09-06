//
//  AppEngine.swift
//  Vloom
//
//  Created by Mariano on 3/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation

class AppEngine : Engine<AppEndPoint> {
    
    required init(baseURL: String, mapper: Mapper) {
        super.init(baseURL: baseURL, mapper: mapper)
        self.manager.requestSerializer.setValue("Bearer \(AppEngineAccessToken)", forHTTPHeaderField:"Authorization")
    }
    
}