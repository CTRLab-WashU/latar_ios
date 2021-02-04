//
// WorkerResult.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

import Foundation

public struct WorkerResult:Codable
{
    public var min: Int64 = 0;
    public var max: Int64 = 0;
    public var sum: Int64 = 0;
    public var count: Int = 0;

    public var avg: Double = 0;
    public var variance: Double = 0;
    public var stddeviation: Double = 0;

    public var startTime: String = "";
    public var stopTime: String = "";
    public var duration: Int64 = 0;

    public var timeUtilization: String = "";

    public var deltas: Array<Int64> = [];
    
    init(start:TimeInterval, stop:TimeInterval, deltas:Array<Int64>) {
        
        let formatter:DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        duration = Int64((stop - start) * 1000);
        
        startTime = formatter.string(from: Date(timeIntervalSince1970: start));
        stopTime = formatter.string(from: Date(timeIntervalSince1970: stop));
        self.deltas = deltas;

        self.count = self.deltas.count;
        if(count==0){
            return;
        }

        sum = 0;
        max = deltas[0];
        min = deltas[0];
        
        
        for delta in deltas
        {
            if delta > max
            {
                max = delta;
            }
            if delta  < min
            {
                min = delta;
            }
            sum += delta;
        }
        
        avg = Double(sum) / Double(count);
        
        var sumv:Double = 0;
        for delta in deltas
        {
            sumv += pow(Double(delta) - avg, 2);
        }
        
        variance = sumv / Double(count);
        stddeviation = sqrt(variance);

        let utilization = (Double(sum) / Double(duration)) * 100;
        timeUtilization = "\(utilization) %";
    }
}
