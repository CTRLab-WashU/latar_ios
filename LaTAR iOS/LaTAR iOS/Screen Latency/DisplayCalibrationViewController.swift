//
//  DisplayCalibrationViewController.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 5/7/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import UIKit

class DisplayCalibrationViewController: LatarViewController {
    

    public var count:Int = 0;       // number of times to change color
    public var interval:Int = 0;    // interval in ms between color changes
    public var testIndex:Int = 0;   // current index (once this reaches count, we're done)
    public var color:Int = 1;       // current color (1 = white, 0 = black)
    
    public var timer: DispatchSourceTimer!
    private var previousBrightness:CGFloat = 0;
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self.view.backgroundColor = UIColor.white;
        
        self.previousBrightness = UIScreen.main.brightness;
        UIScreen.main.brightness = CGFloat(1.0);
        LaTARSocket.shared.acknowledgeCommand(.CALIBRATION_DISPLAY_START);
    }
    
    @objc override func handleStart(notification: Notification?)
    {
        HMLog("starting calibration");
        self.count = 3;
        self.interval = 500;
        self.setupTimer();
    }
    
    @objc override func handleStop(notification: Notification?) {
        UIScreen.main.brightness = self.previousBrightness;
        HMLog("ending calibration");
    }
    
    func setupTimer()
    {
        
        let queue = DispatchQueue(label: "com.latar.timer", qos: .userInteractive)
        let intervalSeconds = (Double(self.interval) / 1000);
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        
        timer.schedule(deadline: .now() + intervalSeconds, repeating: intervalSeconds, leeway: .nanoseconds(0))
        timer.setEventHandler {
            self.updateDisplay();
            HMLog("updating Display");
        }
        timer.resume()
    }
    
    @objc func updateDisplay()
    {
        
        self.performSelector(onMainThread: #selector(toggleScreenColor), with: nil, waitUntilDone: true);
        
        
        self.testIndex += 1;
        if(self.testIndex > self.count)
        {
            NotificationCenter.default.post(Notification(name:teardownNotification, object:nil,
                                                         userInfo: ["command": cmd_byte.CALIBRATION_DISPLAY_STOP.rawValue]));
            self.timer.cancel();
            return;
        }
    }
    
    @objc func toggleScreenColor()
    {
        
        if self.color == 0
        {
            self.view.backgroundColor = UIColor.black;
            self.color = 1;
        }
        else
        {
            self.view.backgroundColor = UIColor.white;
            self.color = 0;
        }
        
    }
    
}
