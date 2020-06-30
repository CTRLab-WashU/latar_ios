//
//  ViewController.swift
//  LaTAR iOS
//
//  Created by Michael Votaw on 1/20/20.
//  Copyright © 2020 healthyMedium. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var textLog: UITextView!
    
    public var logText:String = "";
    private var load:SyntheticLoad?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String;
        
        self.versionLabel.text = "Ver \(version)";
        
        LALogging.sharedInstance.setLogLevel(.Info);
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayLog(notification:)),
                                               name: LALogging.loggedNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupTapLatency(notification:)),
                                               name: tapLatenceyStartNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(setupDisplayLatency(notification:)),
                                               name: displayLatenceyStartNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(setupDisplayCalibration(notification:)),
                                               name: displayCalibrationStartNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(setupTouchCalibration),
                                               name: touchCalibrationStartNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(teardown(notification:)),
                                               name: teardownNotification, object: nil);
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        _ = LaTARSocket.shared;
    }
    
    @objc func setupTapLatency(notification:Notification)
    {
        DispatchQueue.main.async {
            let vc = TapLatencyViewController.init(nibName: "TapLatencyViewController", bundle: nil);
            self.setup(notification: notification, vc: vc);
        }
    }
    
    
    @objc func setupDisplayLatency(notification:Notification)
    {
        DispatchQueue.main.async {
            let vc = DisplayLatencyViewController.init(nibName: "DisplayLatencyViewController", bundle: nil);
            self.setup(notification: notification, vc: vc);
        }
    }
    
    
    @objc func setupTouchCalibration(notification:Notification)
    {
        DispatchQueue.main.async {
            let vc = TouchCalibrationViewController.init(nibName: "TouchCalibrationViewController", bundle: nil);
            self.setup(notification: notification, vc: vc);
        }
    }
    
    @objc func setupDisplayCalibration(notification:Notification)
    {
        DispatchQueue.main.async {
            let vc = DisplayCalibrationViewController.init(nibName: "DisplayCalibrationViewController", bundle: nil);
            self.setup(notification: notification, vc: vc);
        }
    }
    
    @objc func setup(notification:Notification, vc:LatarViewController)
    {
        self.setupLoad(notification:notification);
        vc.modalPresentationStyle = .fullScreen;
        self.present(vc, animated: true) {
            vc.handleStart(notification: notification);
        }
    }
    
    @objc func teardown(notification:Notification)
    {
        DispatchQueue.main.async {
            if let vc = self.presentedViewController as? LatarViewController
            {
                vc.handleStop(notification: notification);
            }
            let loadResult:String? = self.stopLoad();
            
        self.dismiss(animated: true) {
            guard let cmd:UInt8 = notification.userInfo?["command"] as? UInt8 else { return; }
            let cmdByte = cmd_byte(rawValue: cmd)!;
            LaTARSocket.shared.acknowledgeCommand(cmdByte, body: nil, comment: loadResult);
            }
        }
    }
    

    @objc func displayLog(notification:Notification)
    {
        guard var log:String = notification.userInfo?["log"] as? String else { return;}
            log = log.replacingOccurrences(of: "\\n", with: "\n");
        self.logText += log + "\n";
        DispatchQueue.main.async{
            if !(self.viewIfLoaded?.isHidden ?? true)
            {
                self.textLog.text = self.logText;
            }
        }
    }
    
    @IBAction func ConnectPressed(_ sender: UIButton) {
        
        if LaTARSocket.shared.udpAddress == nil
        {
            return;
        }
        
        if LaTARSocket.shared.isConnected
        {
            LaTARSocket.shared.closeSocket();
            sender.setTitle("Connect", for: .normal);
        }
        else
        {
            LaTARSocket.shared.setupTcp();
            sender.setTitle("Disconnect", for: .normal);
        }
    
    }
    
    func setupLoad(notification:Notification)
    {
        guard let response = notification.object as? SocketResponse,
        let commentData = response.comment?.data(using: .utf8)
        else { return; }
        HMLog("Loading SyntheticLoad parameters", logLevel: .Verbose)
        do
        {
            let params:LoadParameters = try LaTARSocket.shared.decoder.decode(LoadParameters.self, from: commentData)
            HMLog("Loading SyntheticLoad with params \(params)", logLevel: .Verbose)
            self.load = SyntheticLoad(params: params);
        }
        catch
        {
            HMLog("Error loading LoadParameters \(error)", logLevel: .Error)
            return;
        }
    }
    
    func startLoad()
    {
        HMLog("Starting SyntheticLoad", logLevel: .Verbose)
        self.load?.start();
    }
    
    func stopLoad() -> String?
    {
        guard let load = self.load else { return nil; }
        HMLog("Stopping SyntheticLoad", logLevel: .Verbose)
        do
        {
            let result = load.stop();
            let resultData = try LaTARSocket.shared.encoder.encode(result)
            let resultStr = String(data: resultData, encoding: .utf8);
            self.load = nil;
            return resultStr;
        }
        catch
        {
            HMLog("Error encoding load results \(error)", logLevel: .Error);
            return nil;
        }
    }
}

