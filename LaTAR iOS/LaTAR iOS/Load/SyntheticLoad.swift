//
//  SyntheticLoad.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 5/14/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import Foundation

public class SyntheticLoad:NSObject
{
    private var workers:Array<Worker> = [];
    private var params:LoadParameters!;
    private var group:DispatchGroup!;
    
    
    init (params:LoadParameters)
    {
        super.init();
        self.params = params;
        self.group = DispatchGroup();
        
        for _ in 0..<params.threadCount
        {
            let worker:Worker = Worker(workload: params.workload, interval: UInt64(params.interval), group:self.group);
            self.workers.append(worker);
        }
    }
    
    public func start()
    {
        for worker in workers
        {
            worker.startThread();
        }
    }
    
    public func stop() -> LoadResult
    {
        var workerResults:Array<WorkerResult> = [];
        for worker in workers
        {
            worker.shutdown();
        }
        self.group.wait();
        
        for worker in workers
        {
            let result:WorkerResult = WorkerResult(start: worker.start, stop: worker.stop, deltas: worker.deltas);
            workerResults.append(result);
        }
        
        let loadResult:LoadResult = LoadResult(results: workerResults);
        
        return loadResult;
    }
}
