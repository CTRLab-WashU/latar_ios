//
//  TapLatencyViewController.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 1/20/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import UIKit

class TapLatencyViewController: UIViewController {

    public var count:Int = 0;
    public var interval:Int = 0;
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        NotificationCenter.default.addObserver(self, selector: #selector(handleStart(notification:)), name: tapLatenceyStartNotification, object: nil);
        
        LaTARSocket.shared.acknowledgeCommand(.TAP_START);
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        NotificationCenter.default.removeObserver(self);
    }
    
    
    @objc func handleStart(notification: Notification)
    {
        // TODO: do we need to do anything when we start?
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let e = event
        {
            self.processEvent(e);
            count += 1;
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let e = event
//        {
//            self.processEvent(e);
//        }
    }
    
    func processEvent(_ event:UIEvent)
    {
        guard let touch = event.allTouches?.first else { return; }
        
        let actionTime = DeviceClock.convertToOffsetTime(event.timestamp);
        let callbackTime = DeviceClock.getCurrentTime();
        
        let t = LATouch(index: self.count, actionTime: actionTime, callbackTime: callbackTime, touchPhase: touch.phase, touchRadius: touch.majorRadius);
        
        LaTARSocket.shared.sendTouch(t);
    }
    
}
