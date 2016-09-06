//
//  CompositionRoot.swift
//  Vloom
//
//  Created by Mariano on 3/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation

//Helper functions
let utils = Utils()

//Object mapper
let mapper = ObjectMapper()

//Vloom API
let engine = AppEngine(baseURL: isEnvDev ? "https://dev.vloom.io/v1/" : "https://dev.vloom.io/v1/" , mapper: mapper)

//IP API
let ipEngine = Engine<IPEndPoint>(baseURL: IPEngineBaseURL, mapper: mapper)

//Push via GCM
let GCM = GCMManager()

//Flow 
let flowManager = FlowManager()