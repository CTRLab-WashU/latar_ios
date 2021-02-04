//
// SocketRequest.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

// The request_data structure should be as follows:

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

class SocketRequest: CustomStringConvertible
{
    var cmd:cmd_byte = .CLOCK_SYNC;
    var ctl: ctl_byte = .enq;
    var body:String?;
    var comment: String?;
    var request_data: Data?;
    var response_handler: ((SocketResponse) -> Void)?;
    
    var description: String {
        return String(describing: self.cmd) + " " + String(describing: self.ctl) + " " + String(describing: self.body) + " " + String(describing: self.comment);
    }
    
    static func createRequest(cmd: cmd_byte, ctl: ctl_byte, body: String? = nil, comment: String? = nil, response_handler: ((SocketResponse) -> Void)? = nil) -> SocketRequest
    {
        let request:SocketRequest = SocketRequest();
        request.cmd = cmd;
        request.ctl = ctl;
        request.body = body;
        request.comment = comment;
        request.response_handler = response_handler;
        request.request_data = SocketRequest.buildRequestData(request: request);
        return request;
    }
    
    static func buildRequestData(request:SocketRequest) -> Data {
        
        var bytes:Data = Data();
        bytes.append(frame_byte.soh.rawValue);
        bytes.append(request.cmd.rawValue);
        bytes.append(request.ctl.rawValue);
        
        if let b = request.body, b != "", let bodyData = b.data(using: .utf8)
        {
            bytes.append(bodyData);
        }
        
        if let c = request.comment, c != "", let commentData = c.data(using: .utf8)
        {
            bytes.append(frame_byte.stx.rawValue);
            bytes.append(commentData);
            bytes.append(frame_byte.etx.rawValue);
        }
        
        bytes.append(frame_byte.eot.rawValue);
        return bytes
    }
}
