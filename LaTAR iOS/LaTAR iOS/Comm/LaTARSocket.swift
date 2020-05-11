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
    
    var tcpSocket: Socket? = nil;
    var udpSocket: Socket? = nil;
    let tcpPort: Int32 = 4032
    let udpPort: Int32 = 4172;
    var isConnected:Bool = false;
    var listenForUdp:Bool = true;
    var udpAddress:Socket.Address? = nil;
    
    var currMessage: Data = Data()
    var localBuffer: Data = Data()
    
    
    var sendQueue:Array<SocketRequest> = Array();       // queue of SocketRequests waiting to be sent
    var awaitingResponse:Array<SocketRequest> = Array();    // queue of SocketRequests waiting for a response
    
    var verbose:Bool = true;
    var dontActuallyDoStuff:Bool = false;
    var clockUpdates:Array<ClockUpdate> = Array();
    
    init() {
        self.setupUdp();
        
    }
    
    deinit {
        self.tcpSocket?.close();
        self.udpSocket?.close();
        
    }
    
    static func initShared()
    {
        LaTARSocket.shared = LaTARSocket();
    }
    
    func closeSocket()
    {
        self.isConnected = false;
        self.tcpSocket?.close();
        HMLog("Disconnected socket.");
    }
    
    func setupTcp() {
        HMLog("Connecting");
        if self.dontActuallyDoStuff
        {
            return;
        }
        guard let address = self.udpAddress, let (remoteHost, _) = Socket.hostnameAndPort(from: address) else { return; }
        
        do {
            self.tcpSocket = try Socket.create()
            try self.tcpSocket?.connect(to: remoteHost, port: self.tcpPort)
            try self.tcpSocket?.setBlocking(mode: false)
        }
        catch {
            HMLog("Error creating socket: \(error)")
            return
        }
        
        // clear any queues that we may have before now.
        self.sendQueue.removeAll();
        self.awaitingResponse.removeAll();
        self.isConnected = true;
        DispatchQueue.global(qos: .default).async {
            while(self.tcpSocket?.isConnected ?? false) {
                self.receive()
                self.sendNextEvent()
            }
        }
        
    }
    
    func setupUdp()
    {
        do {
            self.udpSocket = try Socket.create(family: .inet, type: .datagram, proto: .udp);
            try self.udpSocket?.listen(on: Int(self.udpPort));
        }
        catch {
            HMLog("Error creating socket: \(error)")
            return
        }
        HMLog("Waiting to receive broadcast...");
        DispatchQueue.global(qos: .default).async {
            while(self.listenForUdp){
                self.handleUdp();
            }
        }
        
    }
    
    // Adds the request to the send queue.
    func enqueue(request:SocketRequest)
    {
        self.sendQueue.append(request);
    }
    
    // Writes a byte array to the socket
    // returns the number of bytes written to socket
    
    func send(event: Data) -> Int {
        do {
            let readOrWrite = try self.tcpSocket?.isReadableOrWritable(waitForever: false, timeout: 1000)
            if readOrWrite?.writable == true
            {
                if let result = try self.tcpSocket?.write(from: event)
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
            try _ = self.tcpSocket?.read(into: receivedPtr, bufSize: 1, truncate: true)
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
                
            case .CLOCK_UPDATE:
                self.handleClockUpdate(response);
                return;
            case .DEVICE_INFO:
                self.handleDeviceInfo(response);
                return;
            case .DEVICE_IDENTIFY:
                self.handleDeviceIdentify(response);
                return;
  
            case .RESET:
                self.handleReset(response);
                return;
                
         
            case .DISPLAY_START:
                
				guard let response_data:Data = response.body?.data(using: .utf8) else { return; }
                
                do{
                    let displayParams:Dictionary<String, Int> = try self.decoder.decode(Dictionary<String, Int>.self, from: response_data)
					
                    NotificationCenter.default.post(Notification(name:displayLatenceyStartNotification, object:displayParams));
                }
                catch
                {
					HMLog("Error trying to decode response data: \(error) \(response)");
                }
                
                return;
            case .DISPLAY_DATA:
                return;
            case .DISPLAY_STOP:
                NotificationCenter.default.post(Notification(name:teardownNotification, object:response,
                                                             userInfo: ["command": cmd_byte.DISPLAY_STOP.rawValue]));
                return;
        
            case .TAP_START:
                NotificationCenter.default.post(Notification(name:tapLatenceyStartNotification, object:response));
                return;
            case .TAP_DATA:
                return;
            case .TAP_STOP:
                NotificationCenter.default.post(Notification(name:teardownNotification, object:response,
                                                             userInfo: ["command": cmd_byte.TAP_STOP.rawValue ]));
                return;
            
            case .CALIBRATION_DISPLAY_START:
                NotificationCenter.default.post(Notification(name:displayCalibrationStartNotification, object:response));
                return;
            case .CALIBRATION_DISPLAY_STOP:
                NotificationCenter.default.post(Notification(name:teardownNotification, object:response,
                userInfo: ["command": cmd_byte.CALIBRATION_DISPLAY_STOP.rawValue ]));
                return;
            case .CALIBRATION_TOUCH_START:
                NotificationCenter.default.post(Notification(name:touchCalibrationStartNotification, object:response));
                return;
            case .CALIBRATION_TOUCH_STOP:
                NotificationCenter.default.post(Notification(name:teardownNotification, object:response,
                                                             userInfo: nil )); //["command": cmd_byte.CALIBRATION_TOUCH_STOP.rawValue ]));
                return;
            
            default:
                return;
            }

        }
        
        
    }
    
    
    //MARK: Handling specific commands
    
    func handleClockUpdate(_ response:SocketResponse)
    {
        HMLog("Sending Clock Update info");
        do
        {
            let jsonData:Data = try self.encoder.encode(self.clockUpdates);
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
    
    
    @objc func handleUdp()
    {
        
        let receivedPtr = UnsafeMutablePointer<CChar>.allocate(capacity: 1)
        receivedPtr.initialize(to: 0);
        guard let socket = self.udpSocket else { return; }
        var received: Data = Data()
        do {
            
            let (_, addr) = try socket.readDatagram(into: &received)
            guard let address = addr else { return; }
            
            if received.count == 0
            {
                return;
            }
            switch received[0]
            {
            case cmd_byte.BROADCAST.rawValue:
                if self.udpAddress == nil
                {
                    self.udpAddress = address;
                    HMLog("Received broadcast, ready to connect.");
                }
                break;
            case cmd_byte.CLOCK_SYNC.rawValue:
                DeviceClock.zero();
                self.clockUpdates = Array();
                try socket.write(from: received, to: address)
                HMLog("Received clock sync");
                break;
            default:
                let timestamp = DeviceClock.getCurrentTime();
                try socket.write(from: received, to: address);
                let update:ClockUpdate = ClockUpdate(timestamp: timestamp, index: Int(received[0]));
                self.clockUpdates.append(update);
                break;
                
            }
        }
        catch {
          HMLog("Error reading data from socket: \(error)")
          return
        }
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
    
    func sendTouchCalibration(_ touch:LATouchCalibrationData)
    {
        do
        {
            let jsonData:Data = try self.encoder.encode(touch);
            guard let json:String = String(data:jsonData, encoding:.utf8) else {
                HMLog("Could not convert json data to string");
                return;
            }
            
            let request = SocketRequest.createRequest(cmd: .CALIBRATION_TOUCH_STOP, ctl: .enq, body: json, comment: nil, response_handler: nil);
            self.enqueue(request: request);
            
        }
        catch
        {
            HMLog("Error trying to send LATouch: \(error)");
        }
    }
    
}
