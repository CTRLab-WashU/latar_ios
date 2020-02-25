//
//  LAScreenAction.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 2/19/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import Foundation
import UIKit

public struct LAScreenAction: Codable
{
    /*
     
     {
       "callbackTime": 386995509706,
       "color": 1,
       "colorName": "WHITE",
       "displayTime": 386995510556,
       "index": 20
     }
     */
    
    public var index:Int;
    public var color:Int;
    public var colorName: String;
    public var actionTime: UInt64;
    public var callbackTime: UInt64;
    
    init(index:Int, color:Int, timestamp:UInt64)
    {
        self.index = index;
        self.callbackTime = timestamp;
        self.actionTime = self.callbackTime;
        self.color = color;
        self.colorName = color == 1 ? "WHITE" : "BLACK";
    }
}

