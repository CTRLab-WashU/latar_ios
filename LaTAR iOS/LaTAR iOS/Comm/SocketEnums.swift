//
//  SocketEnums.swift
//  cameraball
//
//  Created by Michael Votaw on 12/12/18.
//  Copyright © 2018 happyMedum. All rights reserved.
//

import Foundation

enum frame_byte:UInt8
{
    case soh = 0x01     //start of header
    case stx = 0x02     //start of text
    case etx = 0x03     //end of text
    case eot = 0x04     //end of transmission
}

enum ctl_byte: UInt8
{
    case enq = 0x05     //request
    case ack = 0x06     //acknowledge
    case bel = 0x07     //broadcast
    case nak = 0x15     //not acknowledged
}

enum cmd_byte: UInt8
{
    case CLOCK_SYNC             = 0x42;
    case CLOCK_UPDATE           = 0x43;
    case DEVICE_INFO            = 0x44;
    case DEVICE_IDENTIFY        = 0x45;
    case RESET                  = 0x46;
    case CALIBRATION_SETUP      = 0x47;
    case CALIBRATION_DISPLAY    = 0x48;
    case CALIBRATION_TOUCH      = 0x49;
    case CALIBRATION_TEARDOWN   = 0x4B;
    case DISPLAY_SETUP          = 0x4C;
    case DISPLAY_START          = 0x4D;
    case DISPLAY_DATA           = 0x4E;
    case DISPLAY_STOP           = 0x4F;
    case DISPLAY_TEARDOWN       = 0x50;
    case TAP_SETUP              = 0x51;
    case TAP_START              = 0x52;
    case TAP_DATA               = 0x53;
    case TAP_STOP               = 0x54;
    case TAP_TEARDOWN           = 0x55;
    
    static func fromString(_ str:String) -> cmd_byte?
    {
        if let b = str.utf8.first
        {
            return cmd_byte(rawValue: b);
        }
        
        return nil;
    }
}


// NotificationCenter notifications
let tapLatenceySetupNotification:Notification.Name = Notification.Name(rawValue: "tapLatencySetup");
let tapLatenceyStartNotification:Notification.Name = Notification.Name(rawValue: "tapLatencyStart");
let tapLatenceyStopNotification:Notification.Name = Notification.Name(rawValue: "tapLatencyStop");
let tapLatenceyTeardownNotification:Notification.Name = Notification.Name(rawValue: "tapLatencyTeardown");

let displayLatenceySetupNotification:Notification.Name = Notification.Name(rawValue: "displayLatencySetup");
let displayLatenceyStartNotification:Notification.Name = Notification.Name(rawValue: "displayLatencyStart");
let displayLatenceyStopNotification:Notification.Name = Notification.Name(rawValue: "displayLatencyStop");
let displayLatenceyTeardownNotification:Notification.Name = Notification.Name(rawValue: "displayLatencyTeardown");




