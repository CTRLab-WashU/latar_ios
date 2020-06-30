//
//  LALogging.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 1/20/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import Foundation

public enum LogLevel: Int
{
    case Error = 10
    case Warning = 5
    case Notification = 3
    case Info = 2
    case Verbose = 1
}

class LALogging: NSObject
{
    static public let loggedNotification = Notification.Name("loggedNotification");
    
    static public let sharedInstance = LALogging();
    
    public var logToFile:Bool = true;
    
    public var fh: FileHandle?;
    public var fm = FileManager.default;
    public var logName:String;
    public var logLevel:LogLevel = .Info
    public var fileLogLevel:LogLevel = .Info
    public override init()
    {
        let df = DateFormatter();
        df.dateFormat = "yyyy-MM-dd-HH-mm-ss";
        let logDate = df.string(from:Date());
        self.logName = "LaTAR-log-\(logDate).log";
        super.init();
    }
    
    public init(logName:String)
    {
        self.logName = logName;
        super.init();
    }
    
    public func setLogToFile(log: Bool, fileLogLevel:LogLevel = .Info)
    {
        self.logToFile = log;
        self.fileLogLevel = fileLogLevel;
    }
    
    public func setLogLevel(_ ll:LogLevel)
    {
        self.logLevel = ll;
    }


    public func logToFile(_ s:String, logLevel:LogLevel = .Info)
    {
        if logToFile == false
        {
            return;
        }

        let documentsDirecotry = fm.urls(for: .documentDirectory, in: .userDomainMask)[0];
        let filepath = documentsDirecotry.appendingPathComponent(logName);
        
        let logDate = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short);
        let line = "\(logDate) [\(logLevel)]: \(s)\n";

        do
        {
            if fm.fileExists(atPath: filepath.path) == false
            {
                try line.write(to: filepath, atomically: true, encoding: .utf8);
            }
            else
            {
                if fh == nil
                {
                    self.fh = try FileHandle(forWritingTo: filepath);
                }

                if let fileHandle = fh
                {
                    _ = fileHandle.seekToEndOfFile();
                    if let data = line.data(using: String.Encoding.utf8) {
                        fileHandle.write(data)
                    }
                }
            }
        }
        catch
        {
            print("error writing to log: \(error)");
        }
    }
    
}

public func HMLog(_ s: String, logLevel:LogLevel = .Info)
{

    if logLevel.rawValue >= LALogging.sharedInstance.fileLogLevel.rawValue
    {
        LALogging.sharedInstance.logToFile(s, logLevel: logLevel);
    }

    if logLevel.rawValue >= LALogging.sharedInstance.logLevel.rawValue
    {
        print("[\(logLevel)]: \(s)")
        NotificationCenter.default.post(name: LALogging.loggedNotification, object: nil, userInfo: ["log": s, "logLevel": logLevel]);
    }
    
}

