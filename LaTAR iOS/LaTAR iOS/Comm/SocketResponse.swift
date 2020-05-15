//
//  SocketResponse.swift
//  cameraball
//
//  Created by Michael Votaw on 12/12/18.
//  Copyright © 2018 happyMedum. All rights reserved.
//
// This is a convenience container for a Cameraball API response.
// The response_data structure should be as follows:

//  soh     cmd     ctl     body        stx        comment      etx     eot
//  0x01                                0x02                    0x03    0x04
//
// soh is frame_byte.soh (0x01) notes the start of header
// cmd is any of the cmd_byte values
// ctl is any of the ctl_byte values
// body (optional), depending on the command character
// stx (optional) frame_byte.stx (0x02) notes the start of a comment
// comment (optional)
// etx (optional) frame_byte.etx (0x03) notes the end of a comment
// eot frame_byte.eot (0x04) notes the end of transmission

import Foundation

class SocketResponse: CustomStringConvertible
{
    var cmd:cmd_byte = .CLOCK_SYNC;
    var ctl: ctl_byte = .enq;
    var body:String?;
    var comment: String?;
    var response_data: Data?;
    
    var description: String {
        return String(describing: self.cmd) + " " + String(describing: self.ctl) + " " + String(describing: self.body) + " " + String(describing: self.comment);
    }
    
    
    static func createResponse(from data:Data) -> SocketResponse?
    {
        
        // does it start with a soh, and end with an eot?
        
        guard data.count > 3, let s = data.first, s == frame_byte.soh.rawValue, let e = data.last, e == frame_byte.eot.rawValue  else
        {
            return nil;
        }
        
        // Do the first two bytes (after soh) contain valid cmd and ctl bytes?
        guard let cmd = cmd_byte(rawValue: data[1]), let ctl = ctl_byte(rawValue: data[2]) else { return nil; }
        
        
        let response:SocketResponse = SocketResponse();
        response.cmd = cmd;
        response.ctl = ctl;
        
        // Does it have a comment section?
        if let comment_start = data.firstIndex(of: frame_byte.stx.rawValue), let comment_end = data.firstIndex(of: frame_byte.etx.rawValue)
        {
            let comment_data = data.subdata(in: (comment_start + 1)..<comment_end);
            response.comment = String(data:comment_data, encoding:.utf8);
            let body_data = data.subdata(in: 3..<comment_start);
            response.body = String(data:body_data, encoding:.utf8);
        }
        else    // If not, then just grab the body, if one exists.
        {
            let body_start:Int = 3;
            let body_end:Int = data.count - 1;
            if body_start < body_end
            {
                let body_data = data.subdata(in: body_start..<body_end);
                response.body = String(data:body_data, encoding:.utf8);
            }
        }
        
        response.response_data = data;
        
        return response;
    }
    
}
