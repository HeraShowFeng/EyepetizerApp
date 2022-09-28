//
//  NSDate+Eye.swift
//  EyepetizerApp
//
//  Created by 梁亦明 on 16/3/14.
//  Copyright © 2016年 xiaoming. All rights reserved.
//

import Foundation

extension NSDate {
    /**
     获取当前时间戳
     */
    class func getCurrentTimeStamp() -> String {
        let timeStamp : String = "\(Int64(floor(NSDate().timeIntervalSince1970 * 1000)))"
        return timeStamp
    }
    
    /**
     获取当前年月日
     */
    class func getCurrentDate() -> String {
        let formatter : DateFormatter = DateFormatter()
        formatter.date(from: "yyyy-MM-dd")
        return formatter.string(from: NSDate() as Date)
    }
    
    /**
     将时间转换为时间戳
     
     - parameter date: 要转化的时间
     
     - returns: 时间戳
     */
    class func change2TimeStamp(date : String) -> String {
        let formatter : DateFormatter = DateFormatter()
        formatter.date(from: "yyyy-MM-dd")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let dateNow = formatter.date(from: date)
        return "\(dateNow?.timeIntervalSince1970)000"
    }
    
    /**
     将时间戳转化成时间
     
     - parameter timestamp: 要转化的时间戳
     
     - returns: 时间
     */
    class func change2Date(timestamp : String) -> String {
        guard timestamp.length > 3 else {
            return ""
        }
        
        let newTimestamp = (timestamp as NSString).substring(from: timestamp.length - 3)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.date(from: "yyyy-MM-dd HH:mm:ss")
        
        let dateStart = NSDate(timeIntervalSince1970: Double(newTimestamp)!)
        return formatter.string(from: dateStart as Date)
    }
}
