//
// DisplayLatencyViewController.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

import UIKit

class DisplayLatencyViewController: LatarViewController {
    
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
        LaTARSocket.shared.acknowledgeCommand(.DISPLAY_START);
    }
    
    @objc override func handleStart(notification: Notification?)
    {
        guard let response = notification?.object as? SocketResponse,
            let response_data:Data = response.body?.data(using: .utf8)
        else
        {
            HMLog("Error! Display Latency could not decode count and interval values", logLevel: .Error);
            return;
        }
        do
        {
            let displayParams:Dictionary<String, Int> = try LaTARSocket.shared.decoder.decode(Dictionary<String, Int>.self, from: response_data);
            let count:Int = displayParams["count"]!;
            let interval:Int = displayParams["interval"]!;
            
            self.count = count;
            self.interval = interval;
            self.setupTimer();
        }
        catch
        {
            HMLog("Error trying to decode response data: \(error) \(response)", logLevel: .Error);
        }
        
    }
    
    @objc override func handleStop(notification: Notification?) {
        UIScreen.main.brightness = self.previousBrightness;
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
        let callbackTime = DeviceClock.getCurrentTime();
        let currentColor = self.color;
        self.performSelector(onMainThread: #selector(toggleScreenColor), with: nil, waitUntilDone: true);
        let displayTime = DeviceClock.getCurrentTime();
        let screenAction:LAScreenAction = LAScreenAction(index: self.testIndex, color: currentColor, callbackTime: callbackTime, displayTime: displayTime);
        LaTARSocket.shared.sendScreenAction(screenAction);
        
        self.testIndex += 1;
        if(self.testIndex > self.count)
        {
            NotificationCenter.default.post(Notification(name:teardownNotification, object:nil,
                                                         userInfo: ["command": cmd_byte.DISPLAY_STOP.rawValue]));
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
