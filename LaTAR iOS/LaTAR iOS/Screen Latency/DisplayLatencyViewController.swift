//
//  ScreenLatencyViewController.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 1/22/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import UIKit

class DisplayLatencyViewController: UIViewController {

    public var count:Int = 0;
    public var currentIteration:Int = 0;
    public var interval:Int = 0;
    public var timer: DispatchSourceTimer!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self.view.backgroundColor = UIColor.white;
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleStart(notification:)), name: displayLatenceyStartNotification, object: nil);
        
        LaTARSocket.shared.acknowledgeCommand(.DISPLAY_SETUP);
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        NotificationCenter.default.removeObserver(self);
    }

    @objc func handleStart(notification: Notification)
    {
        // TODO: do we need to do anything when we start?
        // get count, interval ms from response
        
        self.setupTimer();
        
    }
    
    func setupTimer()
    {
        
        let queue = DispatchQueue(label: "com.latar.timer", qos: .userInteractive)
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        timer.schedule(deadline: .now(), repeating: Double(self.interval / 1000), leeway: .nanoseconds(0))
        timer.setEventHandler {
            self.updateDisplay();
        
        }
        timer.resume()
    }
    
    @objc func updateDisplay()
    {
        self.currentIteration += 1;
        if(self.currentIteration >= self.count)
        {
            self.timer.cancel();
            return;
        }
        
        self.performSelector(onMainThread: #selector(toggleScreenColor), with: nil, waitUntilDone: true);
        //TODO: send update?
        
    }
    
    @objc func toggleScreenColor()
    {
        if self.view.backgroundColor == UIColor.black
        {
            self.view.backgroundColor = UIColor.white;
        }
        else
        {
            self.view.backgroundColor = UIColor.black;
        }
    }
}
