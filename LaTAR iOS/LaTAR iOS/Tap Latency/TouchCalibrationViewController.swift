//
// TouchCalibrationViewController.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

import UIKit

class TouchCalibrationViewController: LatarViewController {

    public var count:Int = 0;
    public var interval:Int = 0;
    
    private var startTime:UInt64 = 0;
    private var stopTime:UInt64 = 0;
    private var occurences:Array<UInt64> = [];
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
          
        LaTARSocket.shared.acknowledgeCommand(.CALIBRATION_TOUCH_START);
    }
    
    
    @objc override func handleStart(notification: Notification?)
    {
        self.startTime = DeviceClock.getCurrentTime();
    }
    
    @objc override func handleStop(notification: Notification?) {
        self.stopTime = DeviceClock.getCurrentTime();
        
        let d:LATouchCalibrationData = LATouchCalibrationData(startTime: self.startTime, stopTime: self.stopTime, occurences: self.occurences);
        
        LaTARSocket.shared.sendTouchCalibration(d);
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if event != nil
        {
            count += 1;
            let now = DeviceClock.getCurrentTime();
            self.occurences.append(now);
        }
    }
    

}
