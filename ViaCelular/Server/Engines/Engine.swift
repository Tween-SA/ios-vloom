//
//  Engine.swift
//  Vloom
//
//  Created by Mariano on 3/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import AFNetworking

enum HTTPMethod {
    
    case GET
    case POST
    case PUT
    
}

class Engine<T : RawRepresentable where T.RawValue == String> : RESTEngine
{
    //Used to create requests to the server
    let manager : AFHTTPRequestOperationManager!
    var mapper: Mapper!
        
    required init(baseURL: String, mapper: Mapper) {
        
        self.manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: baseURL))
        self.mapper = mapper
        
        let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.None)
        securityPolicy.allowInvalidCertificates = true
        self.manager.securityPolicy = securityPolicy
        
        let jsonSerializer = AFJSONResponseSerializer()
        jsonSerializer.readingOptions = NSJSONReadingOptions.AllowFragments
        self.manager.responseSerializer = jsonSerializer
        self.manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
        
    }
    
    func GET(endPoint: T, params: AnyObject? = nil, mapping: [Mapping] = [.Root => .Value]) -> RESTEngineFuture {

        return self.performHTTPRequest(.GET, endPoint: endPoint, params: params, mapping: mapping)
        
    }
    
    func POST(endPoint: T, params: AnyObject?, mapping: [Mapping] = [.Root => .Value]) -> RESTEngineFuture {

        return self.performHTTPRequest(.POST, endPoint: endPoint, params: params, mapping: mapping)
        
    }
    
    func PUT(endPoint: T, params: AnyObject?, mapping: [Mapping] = [.Root => .Value]) -> RESTEngineFuture {
        
        return self.performHTTPRequest(.PUT, endPoint: endPoint, params: params, mapping: mapping)
        
    }
    
    func PUT(endPoint: T, headers: AnyObject? ,params: AnyObject?, mapping: [Mapping] = [.Root => .Value]) -> RESTEngineFuture {
        
        return self.performHTTPRequestM(.PUT, endPoint: endPoint, headers: headers, params: params, mapping: mapping)
        
    }
    
    private func performHTTPRequest(method: HTTPMethod, endPoint: T, params: AnyObject?, mapping: [Mapping]) -> RESTEngineFuture {
        
        let promise = RESTEnginePromise()
        
        let successClosure = {(operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            
            self.mapper.map(response, mapping: mapping, completion: { (results) -> Void in
                
                promise.success(results)
                
            })
            
        }
        
        let failureClosure = {(operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            
            promise.failure(error)
            
        }
        
        let paramEncode = self.encode(endPoint, params: params)
        
        switch (method) {
            
        case .GET:
            self.manager.GET(paramEncode.rawValue, parameters: paramEncode.params, success: successClosure, failure: failureClosure)
            
        case .POST:
            self.manager.POST(paramEncode.rawValue, parameters: paramEncode.params, success: successClosure, failure: failureClosure)
            
        case .PUT:
            self.manager.PUT(paramEncode.rawValue, parameters: paramEncode.params, success: successClosure, failure: failureClosure)
            
        }
        
        return promise.future
        
    }
    
    private func performHTTPRequestM(method: HTTPMethod, endPoint: T, headers: AnyObject?, params: AnyObject?, mapping: [Mapping]) -> RESTEngineFuture {
        
        let promise = RESTEnginePromise()
        
        let successClosure = {(operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            
            self.mapper.map(response, mapping: mapping, completion: { (results) -> Void in
                
                promise.success(results)
                
            })
            
        }
        
        let failureClosure = {(operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            
            promise.failure(error)
            
        }
        
        let paramEncode = self.encodeM(endPoint, headers: headers ,params: params)
        
        switch (method) {
            
        case .GET:
            self.manager.GET(paramEncode.rawValue, parameters: paramEncode.params, success: successClosure, failure: failureClosure)
            
        case .POST:
            self.manager.POST(paramEncode.rawValue, parameters: paramEncode.params, success: successClosure, failure: failureClosure)
            
        case .PUT:
            self.manager.PUT(paramEncode.rawValue, parameters: paramEncode.params, success: successClosure, failure: failureClosure)
            
        }
        
        return promise.future
        
    }
    
    private func encode(endPoint: T, params: AnyObject?) -> (rawValue: String, params: AnyObject?) {
        
        var stringToReturn = endPoint.rawValue
        
        guard let paramsDict = params as? NSDictionary else {
            return (rawValue: stringToReturn, params: params)
        }
        
        let finalParams = NSMutableDictionary(dictionary: paramsDict)
        
        for (key, value) in paramsDict {
            
            if let range = stringToReturn.rangeOfString(":\(key)") {
                stringToReturn = stringToReturn.stringByReplacingCharactersInRange(range, withString: "\(value)")
                finalParams.removeObjectForKey(key)
            }
            
        }
        
        return (rawValue: stringToReturn, params: finalParams)
        
    }
    
    private func encodeM(endPoint: T, headers: AnyObject?, params: AnyObject?) -> (rawValue: String, params: AnyObject?) {
        
        var stringToReturn = endPoint.rawValue
        
        guard let headersDict = headers as? NSDictionary else {
            return (rawValue: stringToReturn, params: headers)
        }
        
        for (key, value) in headersDict {
            
            if let range = stringToReturn.rangeOfString(":\(key)") {
                stringToReturn = stringToReturn.stringByReplacingCharactersInRange(range, withString: "\(value)")
            }
        }

        guard let paramsDict = params as? NSDictionary else {
            return (rawValue: stringToReturn, params: params)
        }
        
        let finalParams = NSMutableDictionary(dictionary: paramsDict)
        
        return (rawValue: stringToReturn, params: finalParams)
    }

}