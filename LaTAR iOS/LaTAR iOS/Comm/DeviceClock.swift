//
//  DeviceClock.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 2/25/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import Foundation


public class DeviceClock
{
    public static var timeOffset:UInt64 = 0;
    
    
    public static func zero()
    {
        let time:UInt64 = UInt64( ProcessInfo.processInfo.systemUptime * 1000000);
        DeviceClock.timeOffset = time;
    }
    
    public static func convertToOffsetTime(_ time:TimeInterval) -> UInt64
    {
        let utime:UInt64 = UInt64( time * 1000000);
        return utime - DeviceClock.timeOffset;
    }
    
    public static func getCurrentTime() -> UInt64
    {
        return DeviceClock.convertToOffsetTime(ProcessInfo.processInfo.systemUptime);
        
    }
}
