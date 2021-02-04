//
// UDPSocket.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

import Foundation
import Socket

protocol UDPProtocol {
    func setHost(remoteHost: String)
}

class UDPSocket {
    
    // MARK: Varaibles
    var socket: Socket? = nil
    let host = "192.168.10.255"
    let port: Int32 = 4172
    var timer = Timer()
    var remoteHost: String? = nil
    
    var delegate: UDPProtocol?
    
    // MARK: Functions
    init() {
        do {
            self.socket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
            print("Created UDP socket...")
            //connect()
        }
        catch {
            print("Error creating UDP socket...")
            return
        }
        
        do {
            try self.socket?.setBlocking(mode: false)
        }
        catch {
            print("Error setting UDP socket to non-blocking mode...")
        }
    }
    
    func startListening() {
        // Try to read the UDP socket once per second
        // TODO: Possibly raise or lower this interval
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.receive), userInfo: nil, repeats: true)
    }
    
    func stopListenting() {
        timer.invalidate()
    }
    
    // Reads from the socket
    @objc func receive() {
        print("Trying to receive...")
        var received: Data = Data()
        do {
            let (bytesRead, hostAddress) = (try self.socket?.listen(forMessage: &received, on: Int(port)))!
            //let (bytesRead, hostAddress) = (try self.socket?.readDatagram(into: &received))!
            print("Received data...")
            print(received)
            print(bytesRead)
            print(hostAddress)
            
            
            if (hostAddress != nil) {
                let (remoteHost, remotePort) = Socket.hostnameAndPort(from: hostAddress!)!
                print(remoteHost)
                print(remotePort)
                delegate?.setHost(remoteHost: remoteHost)
            }
        }
        catch {
            print("Error reading data from socket...")
            return
        }
    }
}
