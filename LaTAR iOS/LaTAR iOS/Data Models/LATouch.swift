//
//  LATouch.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 1/20/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import Foundation
import UIKit

public struct LATouch: CustomStringConvertible
{
    public var timestamp:TimeInterval;
    public var touchPhase:UITouch.Phase;
    public var touchLocation:CGPoint;
    public var touchRadius:CGFloat;
    public var touchRadiusTolerance:CGFloat;

    
    public var description: String {
        
        return String(format: "timestamp: %f\tlocation: %f,%f\tphase:%@\tradius:%f", timestamp, touchLocation.x, touchLocation.y, "\(phaseString)", touchRadius, touchRadiusTolerance);
    }
    
    public var phaseString: String {
        switch self.touchPhase {
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
