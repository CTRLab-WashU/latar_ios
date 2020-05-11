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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String;
        
        self.versionLabel.text = "Ver \(version)";
        
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
            
            vc.modalPresentationStyle = .fullScreen;
            self.present(vc, animated: true) {
                vc.handleStart(notification: notification);
            }
        }
    }
    
    
    @objc func setupDisplayLatency(notification:Notification)
    {
        DispatchQueue.main.async {
           
            let vc = DisplayLatencyViewController.init(nibName: "DisplayLatencyViewController", bundle: nil);
            
            vc.modalPresentationStyle = .fullScreen;
            self.present(vc, animated: true) {
                vc.handleStart(notification: notification);
            }
        }
    }
    
    
    @objc func setupTouchCalibration(notification:Notification)
    {
        DispatchQueue.main.async {
            let vc = TouchCalibrationViewController.init(nibName: "TouchCalibrationViewController", bundle: nil);
            
            vc.modalPresentationStyle = .fullScreen;
            self.present(vc, animated: true) {
                vc.handleStart(notification: notification);
            }
        }
    }
    
    @objc func setupDisplayCalibration(notification:Notification)
    {
        DispatchQueue.main.async {
            let vc = DisplayCalibrationViewController.init(nibName: "DisplayCalibrationViewController", bundle: nil);
            
            vc.modalPresentationStyle = .fullScreen;
            self.present(vc, animated: true) {
                vc.handleStart(notification: notification);
            }
        }
    }
    
    @objc func teardown(notification:Notification)
    {
        DispatchQueue.main.async {
            if let vc = self.presentedViewController as? LatarViewController
            {
                vc.handleStop(notification: notification);
            }
        self.dismiss(animated: true) {
            guard let cmd:UInt8 = notification.userInfo?["command"] as? UInt8 else { return; }
            LaTARSocket.shared.acknowledgeCommand(cmd_byte(rawValue: cmd)!);
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
}

