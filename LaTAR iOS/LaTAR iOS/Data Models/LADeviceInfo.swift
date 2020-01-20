//
//  LADeviceInfo.swift
//
//  Created by Michael Votaw on 11/11/19.
//  Copyright © 2019 healthyMedium. All rights reserved.
//

import Foundation
import UIKit

public struct AppInfo: Codable
{
    public var launcherName:String = "";
    public var packageName:String = "";
    public var versionCode:String = "";
    public var versionName:String = "";
    
    init() {

        self.launcherName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String;
        self.packageName = Bundle.main.infoDictionary![kCFBundleIdentifierKey as String] as! String;
        self.versionCode = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as! String;
        self.versionName = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String;
    }
}

public struct HardwareInfo: Codable
{
    public var brand:String = "";
    public var id:String = "";
    public var manufacturer:String = "";
    public var model:String = "";
    public var name:String = "";
    
    init() {
        self.brand = "Apple";
        self.manufacturer = "Apple";
        self.model = deviceIdentifier();
        self.name = UIDevice.current.systemName;
    }
}

public struct OSInfo: Codable
{
    public var name:String = "";
    public var release:String = "";
    public var sdk:String = "";
    public var securityPatch:String = "";
    
    init() {
        self.name = "iOS";
        self.release = UIDevice.current.systemVersion;
        self.sdk = "";
        self.securityPatch = "";
    }
}


class LADeviceInfo: Codable
{
    
    
    public var app:AppInfo;
    public var hardware:HardwareInfo;
    public var os:OSInfo;
    
    init() {
        
        self.app = AppInfo();
        self.hardware = HardwareInfo();
        self.os = OSInfo();
    }
    
    public func jsonString() -> String
    {
        let encoder = JSONEncoder();
        encoder.outputFormatting = .prettyPrinted;
        
        do {
            let jsonData = try encoder.encode(self);
            return String(data:jsonData, encoding:.utf8) ?? "";
        }
        catch
        {
            print("Error encoding device info: \(error)");
        }
        return "";
    }
}



public func deviceIdentifier() -> String
{
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    return identifier;
}
