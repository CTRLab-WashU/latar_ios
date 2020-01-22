//
//  LATouch.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 1/20/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import Foundation
import UIKit

public struct LATouch: Codable, CustomStringConvertible
{
    public var timestamp:TimeInterval;
    public var touchPhase:String;
    public var touchLocation:CGPoint;
    public var touchRadius:CGFloat;
    public var touchRadiusTolerance:CGFloat;

    
    init(timestamp: TimeInterval, touchPhase: UITouch.Phase, touchLocation: CGPoint, touchRadius: CGFloat, touchRadiusTolerance: CGFloat)
    {
        self.timestamp = timestamp;
        self.touchPhase = "";
        self.touchLocation = touchLocation;
        self.touchRadius = touchRadius;
        self.touchRadiusTolerance = touchRadiusTolerance;
        self.touchPhase = self.phaseString(touchPhase);
    }
    
    public var description: String {
        
        return String(format: "timestamp: %f\tlocation: %f,%f\tphase:%@\tradius:%f", timestamp, touchLocation.x, touchLocation.y, touchPhase, touchRadius, touchRadiusTolerance);
    }
    
    public func phaseString(_ phase:UITouch.Phase) -> String {
        switch phase {
        case .began:
            return "Touch Began";
        case .ended:
            return "Touch Ended";
        case .moved:
            return "Touch Moved";
        case .cancelled:
            return "Touch Cancelled";
        case .stationary:
            return "Touch Stationary";
        @unknown default:
            return "Touch Unknown";
        }
    }
}
