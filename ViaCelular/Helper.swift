//
//  Helper.swift
//  Vloom
//
//  Created by Luciano on 3/24/16.
//  Copyright © 2016 Vloom. All rights reserved.
//

import UIKit

class Helper
{
    static func createDate(Value: NSNumber)-> String
    {
        var ret = ""
        
        let tmpValue: String = String(Value)
        let currentDate = (tmpValue as NSString).substringWithRange(NSMakeRange(0, 10))
        
        let createdTimeInterval = NSTimeInterval(currentDate)
        let created = NSDate(timeIntervalSince1970:createdTimeInterval!)
        
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        
        let todayDate: NSDate = calendar.startOfDayForDate(NSDate())
        
        let units: NSCalendarUnit = [NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
        
        let components = calendar.components(units, fromDate:created, toDate:todayDate, options: [])
        
        let year    = components.year
        let month   = components.month
        let day     = components.day
        let hour    = components.hour
        let minute  = components.minute
        
        let yearStr    = String(year)
        let monthStr   = String(month)
        let dayStr     = String(day)
        let hourStr    = String(hour)
        let minuteStr  = String(minute)
        
        if year > 0
        {
            ret = yearStr
            
            if year > 1
            {
                ret += " años"
            } else
            {
                ret += " año"
            }
            
        } else if month > 0
        {
            ret = monthStr
            
            if month > 1
            {
                ret += " meses"
            } else
            {
                ret += " mes"
            }
            
        } else if day > 0
        {
            ret = dayStr
            
            if day > 1
            {
                ret += " días"
            } else
            {
                ret += " día"
            }
        } else if hour > 0
        {
            ret = hourStr
            
            if hour > 1
            {
                ret += " hs"
            } else
            {
                ret += " h"
            }
            
        } else if minute > 0
        {
            ret = minuteStr
            
            if minute > 1
            {
                ret += " ms"
            } else
            {
                ret += " m"
            }
            
        } else
        {
            ret = "1m"
        }
        
        return ret
    }

    static func completeSpace(Value: String)->String
    {
        var ret: String = ""
        
        if Value.characters.count == 1
        {
            ret = "0\(Value)"
        }
        
        return ret
    }

}
