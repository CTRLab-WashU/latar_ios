//
// LATouchCalibrationData.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

import Foundation
import UIKit

public struct LATouchCalibrationData: Codable
{
    public var startTime:UInt64;
    public var stopTime:UInt64;
    public var occurences:Array<UInt64>;
    
    init(startTime:UInt64, stopTime:UInt64, occurences:Array<UInt64>)
    {
        self.startTime = startTime;
        self.stopTime = stopTime;
        self.occurences = occurences;
    }
}
