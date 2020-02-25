//
//  ScreenLatencyViewController.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 1/22/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import UIKit

class DisplayLatencyViewController: UIViewController {
    
    public var count:Int = 0;       // number of times to change color
    public var interval:Int = 0;    // interval in ms between color changes
    public var testIndex:Int = 0;   // current index (once this reaches count, we're done)
    public var color:Int = 1;       // current color (1 = white, 0 = black)
    
    public var timer: DispatchSourceTimer!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self.view.backgroundColor = UIColor.white;
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleStart(notification:)), name: displayLatenceyStartNotification, object: nil);
        
        LaTARSocket.shared.acknowledgeCommand(.DISPLAY_START);
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
        let intervalSeconds = (Double(self.interval) / 1000);
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        
        timer.schedule(deadline: .now() + intervalSeconds, repeating: intervalSeconds, leeway: .nanoseconds(0))
        timer.setEventHandler {
            self.updateDisplay();
        
        }
        timer.resume()
    }
    
    @objc func updateDisplay()
    {
        self.performSelector(onMainThread: #selector(toggleScreenColor), with: nil, waitUntilDone: true);
        self.testIndex += 1;
        if(self.testIndex >= self.count)
        {
            self.timer.cancel();
            return;
        }
    }
    
    @objc func toggleScreenColor()
    {
        let time = DeviceClock.getCurrentTime();
        let screenAction:LAScreenAction = LAScreenAction(index: self.testIndex, color: self.color, timestamp: time);
        
        if self.color == 0
        {
            self.view.backgroundColor = UIColor.white;
            self.color = 1;
        }
        else
        {
            self.view.backgroundColor = UIColor.black;
            self.color = 0;
        }
        
        LaTARSocket.shared.sendScreenAction(screenAction);
    }
}
