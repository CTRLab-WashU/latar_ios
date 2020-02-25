//
//  LaTARSocket.swift
//

import Foundation
import Socket

/*
 
 LaTARSocket
 
 This object manages sending and receiving data from a server over TCP.
 Data is encapsulated in either a SocketRequest or SocketReponse stuct. These structures have essentially the same, well, structure, but are differentiated mostly for our own sanity.
 
 The LaTARSocket object will handle some of the different commands received from the server. Any that it doesn't explicitly handle will be passed off through NSNotifications.
 */

class LaTARSocket {
    
    // MARK: Varaibles
    static public var shared:LaTARSocket = LaTARSocket();
    
    var encoder = JSONEncoder();
    var decoder = JSONDecoder();
    
    var socket: Socket? = nil;
    var host: String? = nil;
    let port: Int32 = 4032
    var isConnected:Bool = false;
    
    var currMessage: Data = Data()
    var localBuffer: Data = Data()
    
    
    var sendQueue:Array<SocketRequest> = Array();       // queue of SocketRequests waiting to be sent
    var awaitingResponse:Array<SocketRequest> = Array();    // queue of SocketRequests waiting for a response
    
    var verbose:Bool = true;
    var dontActuallyDoStuff:Bool = false;
    
    init() {
        
        
    }
    
    deinit {
        self.socket?.close();
        
    }
    
    static func initShared()
    {
        LaTARSocket.shared = LaTARSocket();
    }
    
    func closeSocket()
    {
        self.isConnected = false;
        self.socket?.close();
    }
    
    func initSocket(host: String) {
        if self.dontActuallyDoStuff
        {
            return;
        }
        
        do {
            self.host = host
            self.socket = try Socket.create()
            HMLog("Created socket for host \(host) port \(self.port)");
            try connect()
        }
        catch {
            HMLog("Error creating socket: \(error)")
            return
        }
        
        do {
            try self.socket?.setBlocking(mode: false)
        }
        catch {
            HMLog("Error setting socket to non-blocking mode: \(error)")
            return;
        }
        
        // clear any queues that we may have before now.
        self.sendQueue.removeAll();
        self.awaitingResponse.removeAll();
        self.isConnected = true;
        DispatchQueue.global(qos: .background).async {
            while(self.socket?.isConnected ?? false) {
                self.receive()
                self.sendNextEvent()
            }
        }
        
    }
    
    // Connects the socket
    func connect() throws {
        try self.socket?.connect(to: host!, port: port)
        HMLog("Connected to socket.")
    }
    
    // Adds the request to the send queue.
    func enqueue(request:SocketRequest)
    {
//        HMLog("Enqueued request:");
//        HMLog(request.description);
        self.sendQueue.append(request);
    }
    
    // Writes a byte array to the socket
    // returns the number of bytes written to socket
    
    func send(event: Data) -> Int {
        do {
            let readOrWrite = try self.socket?.isReadableOrWritable(waitForever: false, timeout: 1000)
            if readOrWrite?.writable == true
            {
                if let result = try self.socket?.write(from: event)
                {
                    return result;
                }
            }
        }
        catch {
            HMLog("Error writing event to socket: \(error)")
            return 0;
        }
        
        return 0;
    }
    
    // write next enqueued byte array
    func sendNextEvent()
    {
        guard let request = sendQueue.first, let data = request.request_data else { return; }
        
        if self.send(event: data) > 0
        {
//            HMLog("Sent request: \(request)");
            sendQueue.removeFirst();
            if request.response_handler != nil
            {
                self.awaitingResponse.append(request);
            }
        }
    }
    
    
    // Reads from the socket
    @objc func receive() {
        //print("Trying to receive...")
        let receivedPtr = UnsafeMutablePointer<CChar>.allocate(capacity: 1)
        receivedPtr.initialize(to: 0);
        
        var received: Data = Data()
        do {
            //try self.socket?.read(into: &received)
            try _ = self.socket?.read(into: receivedPtr, bufSize: 1, truncate: true)
            //print(receivedPtr.pointee)
            //receivedPtr[0] = -1
            if (receivedPtr.pointee != 0) {
                //print(UInt8(bitPattern: receivedPtr[0]))
                received.append(UInt8(bitPattern: receivedPtr[0]))
            }
            receivedPtr.deallocate()
            //rawPtr.deallocate()
            //print("Received data...")
        }
        catch {
            HMLog("Error reading data from socket: \(error)")
            return
        }
        
        if (!received.isEmpty) {
            self.currMessage.append(received[0]);
        }
        
        if (currMessage.last == frame_byte.eot.rawValue) {
            let completeMessage = currMessage
            currMessage = Data() // clear buffer
            DispatchQueue.global(qos: .utility).async {
                self.handleResponse(data: completeMessage)
            }
        }
    }
    

    
    func handleResponse(data: Data) {
        guard let response = SocketResponse.createResponse(from: data) else { return; }
//        HMLog("Received response: \(response)");
        
        // Let's see if there are any requests awaiting this response.
        if let index = self.awaitingResponse.firstIndex(where: { (request) -> Bool in return request.cmd == response.cmd; })
        {
            let request = self.awaitingResponse[index];
            request.response_handler?(response);
            self.awaitingResponse.remove(at: index);
        }
        else
        {
            switch response.cmd
            {
                
            case .CLOCK_SYNC:
                self.handleClockSync(response);
                return;
            case .CLOCK_UPDATE:
                self.handleClockUpdate(response);
                return;
            case .DEVICE_INFO:
                self.handleDeviceInfo(response);
                return;
            case .DEVICE_IDENTIFY:
                self.handleDeviceIdentify(response);
                return;
                
            case .DEVICE_ERROR:
                return;
            case .RESET:
                self.handleReset(response);
                return;
                
         
            case .DISPLAY_START:
                NotificationCenter.default.post(Notification(name:displayLatenceyStartNotification, object:response));
                return;
            case .DISPLAY_DATA:
                return;
            case .DISPLAY_STOP:
                NotificationCenter.default.post(Notification(name:displayLatenceyStopNotification, object:response));
                return;
        
        
            case .TAP_START:
                guard let response_data:Data = response.response_data else { return; }
                
                do{
                    let displayParams:Dictionary<String, Int> = try self.decoder.decode(Dictionary<String, Int>.self, from: response_data)
                    NotificationCenter.default.post(Notification(name:tapLatenceyStartNotification, object:displayParams));
                }
                catch
                {
                    HMLog("Error trying to decode response data: \(error)");
                }
                return;
            case .TAP_DATA:
                return;
            case .TAP_STOP:
                NotificationCenter.default.post(Notification(name:tapLatenceyStopNotification, object:response));
                return;
            
            }

        }
        
        
    }
    
    
    //MARK: Handling specific commands
    
    func handleClockSync(_ response:SocketResponse)
    {
        DeviceClock.zero();
        let request = SocketRequest.createRequest(cmd: response.cmd, ctl: .ack, body: nil, comment: nil, response_handler: nil);
        self.enqueue(request: request);
        
    }
    
    func handleClockUpdate(_ response:SocketResponse)
    {
        do
        {
            var body:Dictionary<String, UInt64> = Dictionary();
            body["timestamp"] = DeviceClock.getCurrentTime();
        
            let jsonData:Data = try self.encoder.encode(body);
            guard let json:String = String(data:jsonData, encoding:.utf8) else {
                HMLog("Could not convert json data to string");
                return;
            }
            
           let request = SocketRequest.createRequest(cmd: response.cmd, ctl: .ack, body: json, comment: nil, response_handler: nil);
            self.enqueue(request: request);
            
        }
        catch
        {
            HMLog("Error trying to send LATouch: \(error)");
        }
        
        
        
    }
    
    func handleDeviceInfo(_ response:SocketResponse)
    {
        let deviceInfo = LADeviceInfo();
        let request = SocketRequest.createRequest(cmd: response.cmd, ctl: .ack, body: deviceInfo.jsonString(), comment: nil, response_handler: nil);
        self.enqueue(request: request);
    }
    
    func handleDeviceIdentify(_ response:SocketResponse)
    {
        
    }
    
    func handleReset(_ response:SocketResponse)
    {
        
    }
    
    
    //MARK: Sending Data
    
    
    func acknowledgeCommand(_ cmd:cmd_byte)
    {
        let request = SocketRequest.createRequest(cmd: cmd, ctl: .ack, body: nil, comment: nil, response_handler: nil);
        self.enqueue(request: request);
    }
    
    func sendTouch(_ touch:LATouch)
    {
        do
        {
            let jsonData:Data = try self.encoder.encode(touch);
            guard let json:String = String(data:jsonData, encoding:.utf8) else {
                HMLog("Could not convert json data to string");
                return;
            }
            
            let request = SocketRequest.createRequest(cmd: .TAP_DATA, ctl: .enq, body: json, comment: nil, response_handler: nil);
            self.enqueue(request: request);
            
        }
        catch
        {
            HMLog("Error trying to send LATouch: \(error)");
        }
    }
    
    func sendScreenAction(_ screenAction:LAScreenAction)
    {
        do
        {
            let jsonData:Data = try self.encoder.encode(screenAction);
            guard let json:String = String(data:jsonData, encoding:.utf8) else {
                HMLog("Could not convert json data to string");
                return;
            }
            
            let request = SocketRequest.createRequest(cmd: .DISPLAY_DATA, ctl: .enq, body: json, comment: nil, response_handler: nil);
            self.enqueue(request: request);
            
        }
        catch
        {
            HMLog("Error trying to send LAScreenAction: \(error)");
        }
    }
    
}
