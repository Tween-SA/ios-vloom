//
//  File.swift
//  Vloom
//
//  Created by Mariano on 13/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation

func +(left: String?, right: String?) -> String? {
    
    guard let string1 = left else {
        return right
    }
    
    guard let string2 = right else {
        return left
    }
    
    return string1 + string2
}


extension NSTimeInterval {
    
    var minuteSeconds: String {
        return String(format:"%02d:%02d", self.minute , self.second)
    }
    
    var minute: Int {
        return Int((self/60.0)%60)
    }
    
    var second: Int {
        return Int(self % 60)
    }

}

extension NSDate {
    func elapsedTime() -> String{
        
        let minute = 60.0
        let hora = minute * 60.0
        let dia = hora * 24.0
        
        if timeIntervalSinceNow > -60.0  { //=> Menos de un minuto
            return "Ahora"
        }
        if timeIntervalSinceNow > -60.0 * minute  {
            return "\((Int)(-timeIntervalSinceNow / minute))m"
        }
        if timeIntervalSinceNow > -60.0 * hora  {
            return "\((Int)(-timeIntervalSinceNow / hora))h"
        }
        if (Int)(-timeIntervalSinceNow / dia) == 1 {
            return "\((Int)(-timeIntervalSinceNow / dia)) día"
        }
        return "\((Int)(-timeIntervalSinceNow / dia)) días"
    }
    
}


extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object: Element) {
        if let index = indexOf(object) {
            removeAtIndex(index)
        }
    }
}
