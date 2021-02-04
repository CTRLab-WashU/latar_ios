//
// LoadResult.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

import Foundation

public struct LoadResult:Codable
{
    public var threads: Array<WorkerResult> = [];

    public var min:Int64 = 0;
    public var max:Int64 = 0;
    public var sum:Int64 = 0;
    public var count:Int = 0;
    public var threadCount:Int = 0;

    public var avg:Double = 0;
    public var variance:Double = 0;
    public var stddeviation:Double = 0;
    
    init(results:Array<WorkerResult>) {
        self.threads = results;
        threadCount = results.count;
        
        self.count = 0;
        for result in results
        {
            self.count += result.deltas.count;
        }
        
        if self.count == 0
        {
            return;
        }
        
        min = results[0].min;
        max = results[0].max;
        sum = 0;
        
        for result in results
        {
            if result.max > max
            {
                max = result.max;
            }
            if result.min < min
            {
                min = result.min;
            }
            
            for delta in result.deltas
            {
                sum += delta;
            }
        }
        
        avg = Double(sum) / Double(count);
        
        var sumv:Double = 0;
        
        for result in results
        {
            for delta in result.deltas
            {
                sumv += pow(Double(delta) - avg, 2);
            }
        }
        
        variance = sumv / Double(count);
        stddeviation = sqrt(variance);

    }
    
}
