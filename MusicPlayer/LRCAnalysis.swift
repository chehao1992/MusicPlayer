//
//  LRCAnalysis.swift
//  MusicPlayer
//
//  Created by lanou3g on 15/9/7.
//  Copyright (c) 2015年 chehao. All rights reserved.
//

import UIKit

class LRCAnalysis: NSObject {
   
    class func GetLRCTimeArray(LRCStr:String) -> NSDictionary {
        
        var timeArray:NSMutableArray = NSMutableArray();
        var otherArray:NSMutableArray = NSMutableArray();
        
        if(LRCStr != ""){
            
            let tempArray:NSArray = LRCStr.componentsSeparatedByString("\n");
            for str in tempArray{
                let LRCstring:NSString = str as! NSString;
                
                if(LRCstring.length <= 0){
                    continue;
                }
                
                let range:NSRange = LRCstring.rangeOfString("]");
                if(range.length > 0){
                    //time 不要  []
                    let time:NSString = LRCstring.substringToIndex(range.location);
                    let other:NSString = LRCstring.substringFromIndex(range.location + 1);
                    timeArray.addObject(timeToSecond(time.substringFromIndex(1)));
                    otherArray.addObject(other);
//                    println(timeArray);
//                    println(otherArray);
                }
                
            }
            
        }
        return NSDictionary(objectsAndKeys: otherArray,"other",timeArray,"time");//(objects: otherArray as [AnyObject], forKeys: timeArray as [AnyObject]);
    }
    
    class func timeToSecond(str:NSString) -> NSString {
        let minutes:NSString = str.substringToIndex(2);
//        println(minutes)
        let second:NSString = str.substringFromIndex(3);
//        println(second)
        let finishSecond:Float = minutes.floatValue * 60 + second.floatValue;
        
        let str:String = String(stringInterpolationSegment: finishSecond)
//        println(str)
        return String(stringInterpolationSegment: finishSecond);
    }
    
}
