//
// LATouch.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

import Foundation
import UIKit

public struct LATouch: Codable
{
    public var index:Int;               // 0-based count of how many touches there've been
    public var action:Int;              // 0/1 => down/up
    public var actionName: String;      // ACTION_DOWN/ACTION_UP, depending on action
    public var actionTime: UInt64;      // microsecond time from the UIEvent's timestamp
    public var callbackTime: UInt64;    // microsecond time of ProcessInfo's systemUpTime, at the time that the touchesBegan/touchesEnded is called
    public var touchMajor: CGFloat;     // touchRadius * 2
    public var touchMinor: CGFloat;     // touchRadius * 2 (iOS doesn't provide more granular data than just one radius value)
    
    
    init(index: Int, actionTime: UInt64, callbackTime:UInt64, touchPhase: UITouch.Phase, touchRadius: CGFloat)
    {
        self.callbackTime = callbackTime;
        self.actionTime = actionTime;
        self.index = index;
        self.touchMajor = touchRadius * 2;
        self.touchMinor = touchRadius * 2;
        self.action = (touchPhase == .began ? 0 : 1);
        self.actionName = touchPhase == .began ? "ACTION_DOWN" : "ACTION_UP";
    }
}
