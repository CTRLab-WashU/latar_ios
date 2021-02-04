//
// LAScreenAction.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

import Foundation
import UIKit

public struct LAScreenAction: Codable
{
    public var index:Int;               // 0-based count of how many touches there've been
    public var color:Int;               // 0/1 => black/white
    public var colorName: String;       // BLACK/WHITE
    public var callbackTime: UInt64;    // microsecond time before the call to update screen color is made
    public var displayTime: UInt64;     // microsecond time after the call to update screen color returns
    
    
    init(index:Int, color:Int, callbackTime:UInt64, displayTime:UInt64)
    {
        self.index = index;
        self.callbackTime = callbackTime;
        self.displayTime = displayTime;
        self.color = color;
        self.colorName = color == 1 ? "WHITE" : "BLACK";
    }
}

