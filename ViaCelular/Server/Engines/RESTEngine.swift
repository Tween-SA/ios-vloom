//
//  APIEngine.swift
//  Vloom
//
//  Created by Mariano on 3/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import BrightFutures

enum Response {
    
    case Success(ServerResponse)
    
    case Error(NSError)
    
}

typealias ServerResponse = (raw: AnyObject, mappingResults: MappingResults?)

typealias CompletionBlock = (response: Response) -> Void

typealias RESTEnginePromise = Promise<MappingResults, NSError>
typealias RESTEngineFuture = Future<MappingResults, NSError>

class ExpirableFuture {
    
    var expirationDate: NSDate!
    var future: RESTEngineFuture!
    
    var expired: Bool {
        get {
            return expirationDate.timeIntervalSinceNow < 0
        }
    }
    
}

protocol RESTEngine {
    
    typealias T : RawRepresentable
    
    var mapper: Mapper! { get set }
    
    init(baseURL: String, mapper: Mapper)
    
    func GET(endPoint: T, params: AnyObject?, mapping: [Mapping]) -> RESTEngineFuture
    func POST(endPoint: T, params: AnyObject?, mapping: [Mapping]) -> RESTEngineFuture
    func PUT(endPoint: T, params: AnyObject?, mapping: [Mapping]) -> RESTEngineFuture
    
}