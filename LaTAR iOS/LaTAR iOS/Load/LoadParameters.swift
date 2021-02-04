//
// LoadParameters.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

import Foundation


public struct LoadParameters:Codable
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
