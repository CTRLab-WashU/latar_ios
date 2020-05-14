//
//  Worker.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 5/14/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import Foundation

public class Worker:NSObject
{
    public var deltas:Array<Int64> = Array();
    public var start:TimeInterval = 0;
    public var stop:TimeInterval = 0;
    
    private var workload:Workload!;
    private var interval:TimeInterval = 0;
    private var running:Bool = false;
    private var thread:Thread?;
    private var group:DispatchGroup?;
    
    init(workload:String, interval:UInt64, group:DispatchGroup)
    {
        super.init();
        switch workload
        {
        case "regex":
            self.workload = RegexWorkload();
            break;
        case "matrix":
            self.workload = MatrixWorkload();
            break;
        default:
            self.workload = MatrixWorkload();
        }
        self.interval = TimeInterval(interval) / 1000;
        self.thread = Thread(target: self, selector: #selector(run), object: nil);
        self.group = group;
    }
    
    public func startThread()
    {
        self.group?.enter();
        self.thread?.start();
    }
    
    @objc public func run()
    {
        var before:TimeInterval = 0;
        var after:TimeInterval = 0;
        
        var next:TimeInterval = 0;
        var delta:Int64 = 0;
        
        self.running = true;
        workload.setup();
        self.start = Date().timeIntervalSince1970;
        
        while running
        {
            before = Date().timeIntervalSince1970;
            workload.run();
            after = Date().timeIntervalSince1970;
            delta = Int64((after - before) * 1000);
            self.deltas.append(delta);
            
            next = before + self.interval;
            after = Date().timeIntervalSince1970;
            if after < next
            {
                let interval:TimeInterval = next - after;
                Thread.sleep(forTimeInterval: interval);
            }
        }
        
        self.stop = Date().timeIntervalSince1970;
        self.group?.leave();
    }
    
    public func shutdown()
    {
        self.running = false;
    }
}
