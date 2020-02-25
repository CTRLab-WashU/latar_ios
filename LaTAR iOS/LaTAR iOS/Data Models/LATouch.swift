//
//  LATouch.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 1/20/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import Foundation
import UIKit

public struct LATouch: Codable
{
    /*
     
     public class TapLatencyData {
         public int index;
         public int action;
         public String actionName;
         public long actionTime;
         public long callbackTime;
         public float touchMajor;
         public float touchMinor;
     }


     */
    public var index:Int;
    public var action:Int;
    public var actionName: String;
    public var actionTime: UInt64;
    public var callbackTime: UInt64;
    public var touchMajor: CGFloat;
    public var touchMinor: CGFloat;
    
//    public var timestamp:TimeInterval;
//    public var touchPhase:String;
//    public var touchLocation:CGPoint;
//    public var touchRadius:CGFloat;
//    public var touchRadiusTolerance:CGFloat;

    
    init(index: Int, timestamp: UInt64, touchPhase: UITouch.Phase, touchRadius: CGFloat)
    {
        self.callbackTime = timestamp;
        self.actionTime = self.callbackTime;
        self.index = index;
        self.touchMajor = touchRadius * 2;
        self.touchMinor = touchRadius * 2;
        self.action = (touchPhase == .began ? 0 : 1);
        self.actionName = touchPhase == .began ? "ACTION_DOWN" : "ACTION_UP";
    }
}
