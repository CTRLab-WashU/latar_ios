//
//  LoadParameters.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 5/13/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import Foundation


public class LoadParameters
{

    
    public var interval:Int64 = 0;
    public var threadCount:Int = 0;
    public var workload:String = "matrix";
    
    init(workload:String, interval:Int64, threadCount:Int) {
        self.workload = workload;
        self.interval = interval;
        
        if threadCount <= 0
        {
            self.threadCount = ProcessInfo.processInfo.processorCount * 2;
        }
        else
        {
            self.threadCount = threadCount;
        }
    }
    init()
    {
        self.interval = 0;
        self.threadCount = ProcessInfo.processInfo.processorCount * 2;
        self.workload = "matrix";
    }
    
    
}
