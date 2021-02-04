//
// SocketEnums.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

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
    case BROADCAST              = 0x20;
    case CLOCK_SYNC             = 0x21;
    case CLOCK_UPDATE           = 0x22;
    
    case DEVICE_INFO            = 0x24;
    case DEVICE_IDENTIFY        = 0x25;
    case APP_ERROR              = 0x26;
    case RESET                  = 0x27;
    
    case DISPLAY_START          = 0x28;
    case DISPLAY_DATA           = 0x29;
    case DISPLAY_STOP           = 0x2A;
    
    case TAP_START              = 0x2B;
    case TAP_DATA               = 0x2C;
    case TAP_STOP               = 0x2D;

    case CALIBRATION_TOUCH_START    = 0x2E;
    case CALIBRATION_TOUCH_STOP     = 0x2F;
    case CALIBRATION_DISPLAY_START  = 0x30;
    case CALIBRATION_DISPLAY_STOP   = 0x31;
    
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

let tapLatenceyStartNotification:Notification.Name = Notification.Name(rawValue: "tapLatencyStart");
let tapLatenceyStopNotification:Notification.Name = Notification.Name(rawValue: "tapLatencyStop");

let displayLatenceyStartNotification:Notification.Name = Notification.Name(rawValue: "displayLatencyStart");
let displayLatenceyStopNotification:Notification.Name = Notification.Name(rawValue: "displayLatencyStop");

let displayCalibrationStartNotification:Notification.Name = Notification.Name(rawValue: "displayCalibrationStart");
let displayCalibrationStopNotification:Notification.Name = Notification.Name(rawValue: "displayCalibrationStop");

let touchCalibrationStartNotification:Notification.Name = Notification.Name(rawValue: "touchCalibrationStart");
let touchCalibrationStopNotification:Notification.Name = Notification.Name(rawValue: "touchCalibrationStop");

let teardownNotification:Notification.Name = Notification.Name(rawValue: "teardownNotification");


